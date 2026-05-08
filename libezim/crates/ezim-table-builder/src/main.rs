//! `ezim-table-builder` — build the binary EZ table from `ez.orig-utf8.txt`.
//!
//! ```text
//! ezim-table-builder stats <ez.orig-utf8.txt>
//! ezim-table-builder build <ez.orig-utf8.txt> <out.dat>
//! ```
//!
//! For inspecting an existing `.dat` file, use the `ezim` CLI in the
//! `ezim-cli` crate.

use std::collections::HashMap;
use std::env;
use std::fs;
use std::process::ExitCode;

use ezim_core::format;
use ezim_core::SourceTable;

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let result = match args.as_slice() {
        [cmd, p] if cmd == "stats" => run_stats(p),
        [cmd, src, out] if cmd == "build" => run_build(src, out),
        _ => {
            eprintln!(
                "usage:\n  ezim-table-builder stats <ez.orig-utf8.txt>\n  ezim-table-builder build <ez.orig-utf8.txt> <out.dat>"
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
