//! `ezim-table-builder` — build the binary EZ table and aux data files.
//!
//! ```text
//! ezim-table-builder stats          <ez.orig-utf8.txt>
//! ezim-table-builder build          <ez.orig-utf8.txt> <out.dat>
//! ezim-table-builder weights        <85rest01.csv> <char-weights.dat>
//! ezim-table-builder phrase-weights <85rest02.csv> <phrase-weights.dat>
//! ```
//!
//! For inspecting an existing `.dat` file, use the `ezim` CLI in the
//! `ezim-cli` crate.

use std::collections::HashMap;
use std::env;
use std::fs;
use std::process::ExitCode;

use ezim_core::char_weights;
use ezim_core::format;
use ezim_core::phrase_weights;
use ezim_core::SourceTable;

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let result = match args.as_slice() {
        [cmd, p] if cmd == "stats" => run_stats(p),
        [cmd, src, out] if cmd == "build" => run_build(src, out),
        [cmd, src, out] if cmd == "weights" => run_weights(src, out),
        [cmd, src, out] if cmd == "phrase-weights" => run_phrase_weights(src, out),
        _ => {
            eprintln!(
                "usage:\n  ezim-table-builder stats          <ez.orig-utf8.txt>\n  ezim-table-builder build          <ez.orig-utf8.txt> <out.dat>\n  ezim-table-builder weights        <85rest01.csv> <char-weights.dat>\n  ezim-table-builder phrase-weights <85rest02.csv> <phrase-weights.dat>"
            );
            return ExitCode::from(2);
        }
    };
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {e}");
            ExitCode::FAILURE
        }
    }
}

fn run_stats(path: &str) -> ezim_core::Result<()> {
    let t = SourceTable::open(path)?;
    print_source_stats(path, &t);
    Ok(())
}

fn run_build(src: &str, out: &str) -> ezim_core::Result<()> {
    let raw_bytes = fs::read(src)?;
    let t = SourceTable::open(src)?;
    let buf = format::write(&t, &raw_bytes);
    fs::write(out, &buf)?;
    println!(
        "wrote {} ({} bytes, {} entries, source_hash_lo=0x{:016x})",
        out,
        buf.len(),
        t.entries.len(),
        format::fnv1a64(&raw_bytes),
    );
    Ok(())
}

/// Build `char-weights.dat` from the MOE 85年常用語詞調查報告 字頻總表 CSV
/// (Big5-encoded). Columns expected:
///   字頻序號, 字, 部首, 筆畫, 出現頻次, 累積頻次, 累積百分比
/// We extract `字` (col 1) and use `字頻序號` (col 0) as the u32 rank.
fn run_weights(csv_path: &str, out: &str) -> ezim_core::Result<()> {
    let raw = fs::read(csv_path)?;
    let (decoded, _, had_errors) = encoding_rs::BIG5.decode(&raw);
    if had_errors {
        eprintln!("warning: Big5 decode produced replacement characters");
    }

    let mut entries: Vec<(char, u32)> = Vec::new();
    let mut skipped_header = false;
    let mut bad_lines = 0usize;

    for (lineno, line) in decoded.lines().enumerate() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if !skipped_header {
            // The header begins with non-digits ("字頻序號"). Detect by
            // checking whether col 0 parses as a number.
            let first = line.split(',').next().unwrap_or("");
            if first.parse::<u32>().is_err() {
                skipped_header = true;
                continue;
            }
            skipped_header = true; // first data row will be processed below
        }
        let cols: Vec<&str> = line.split(',').collect();
        if cols.len() < 2 {
            bad_lines += 1;
            continue;
        }
        let rank: u32 = match cols[0].trim().parse() {
            Ok(n) => n,
            Err(_) => {
                bad_lines += 1;
                eprintln!("line {}: bad rank {:?}", lineno + 1, cols[0]);
                continue;
            }
        };
        let mut chars = cols[1].trim().chars();
        let Some(ch) = chars.next() else {
            bad_lines += 1;
            continue;
        };
        if chars.next().is_some() {
            // Multi-char in 字 column — unexpected; record only the first.
            bad_lines += 1;
        }
        entries.push((ch, rank));
    }

    let buf = char_weights::write(&entries, &raw);
    fs::write(out, &buf)?;
    println!(
        "wrote {} ({} bytes, {} entries, {} skipped, source_hash_lo=0x{:016x})",
        out,
        buf.len(),
        entries.len(),
        bad_lines,
        format::fnv1a64(&raw),
    );
    Ok(())
}

/// Build `phrase-weights.dat` from the MOE 85年常用語詞調查報告 詞頻總表 CSV
/// (Big5-encoded). Columns expected:
///   序號, 詞目, 詞頻, 累計詞頻, 百分比, 累計百分比
/// We extract `詞目` (col 1) and use `序號` (col 0) as the u32 rank.
fn run_phrase_weights(csv_path: &str, out: &str) -> ezim_core::Result<()> {
    let raw = fs::read(csv_path)?;
    let (decoded, _, had_errors) = encoding_rs::BIG5.decode(&raw);
    if had_errors {
        eprintln!("warning: Big5 decode produced replacement characters");
    }

    let mut rows: Vec<(String, u32)> = Vec::new();
    let mut skipped_header = false;
    let mut bad_lines = 0usize;

    for (lineno, line) in decoded.lines().enumerate() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if !skipped_header {
            let first = line.split(',').next().unwrap_or("");
            if first.parse::<u32>().is_err() {
                skipped_header = true;
                continue;
            }
            skipped_header = true;
        }
        let cols: Vec<&str> = line.split(',').collect();
        if cols.len() < 2 {
            bad_lines += 1;
            continue;
        }
        let rank: u32 = match cols[0].trim().parse() {
            Ok(n) => n,
            Err(_) => {
                bad_lines += 1;
                eprintln!("line {}: bad rank {:?}", lineno + 1, cols[0]);
                continue;
            }
        };
        let phrase = cols[1].trim();
        if phrase.is_empty() {
            bad_lines += 1;
            continue;
        }
        rows.push((phrase.to_string(), rank));
    }

    let entries: Vec<(&str, u32)> = rows.iter().map(|(s, r)| (s.as_str(), *r)).collect();
    let buf = phrase_weights::write(&entries, &raw);
    fs::write(out, &buf)?;
    println!(
        "wrote {} ({} bytes, {} entries, {} skipped, source_hash_lo=0x{:016x})",
        out,
        buf.len(),
        rows.len(),
        bad_lines,
        format::fnv1a64(&raw),
    );
    Ok(())
}

fn print_source_stats(path: &str, t: &SourceTable) {
    let total = t.len();
    let mut singles = 0usize;
    let mut phrases = 0usize;
    let mut all_numeric = 0usize;
    let mut max_phrase_chars = 0usize;
    let mut max_code_len = 0usize;

    let mut codes_per_char: HashMap<char, usize> = HashMap::new();
    let mut chars_per_code: HashMap<&str, usize> = HashMap::new();

    for e in &t.entries {
        if e.is_phrase() {
            phrases += 1;
            max_phrase_chars = max_phrase_chars.max(e.char_len());
        } else {
            singles += 1;
            let ch = e.text.chars().next().unwrap();
            *codes_per_char.entry(ch).or_insert(0) += 1;
        }
        if e.code_is_all_numeric() {
            all_numeric += 1;
        }
        max_code_len = max_code_len.max(e.code.len());
        *chars_per_code.entry(e.code.as_str()).or_insert(0) += 1;
    }

    let distinct_chars = codes_per_char.len();
    let multi_code_chars = codes_per_char.values().filter(|&&c| c > 1).count();
    let avg_codes_per_char = if distinct_chars > 0 {
        codes_per_char.values().sum::<usize>() as f64 / distinct_chars as f64
    } else {
        0.0
    };
    let max_chars_for_one_code = chars_per_code.values().copied().max().unwrap_or(0);

    println!("source: {path}");
    println!("  total entries        : {total}");
    println!("  single-char entries  : {singles}");
    println!("  phrase entries       : {phrases}");
    println!("  all-numeric codes    : {all_numeric}");
    println!("  longest phrase       : {max_phrase_chars} chars");
    println!("  longest code         : {max_code_len} keys");
    println!("  distinct chars       : {distinct_chars}");
    println!("  chars w/ multi codes : {multi_code_chars}");
    println!("  avg codes per char   : {avg_codes_per_char:.2}");
    println!("  max entries per code : {max_chars_for_one_code}");
}
