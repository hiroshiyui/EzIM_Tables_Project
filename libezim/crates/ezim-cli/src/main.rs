//! `ezim` — developer CLI for the EZ binary table.
//!
//! Subcommands:
//!
//! ```text
//! ezim info   <table.dat>
//! ezim verify <table.dat>
//! ezim encode <table.dat> <string>
//! ezim pick   <table.dat> <char>
//! ezim lookup <table.dat> <code>
//! ```

use std::env;
use std::process::ExitCode;

use ezim_core::format::BinaryTable;
use ezim_core::{EncodeError, HeadTail};

const USAGE: &str = "\
usage:
  ezim info   <table.dat>           # print header & section sizes
  ezim verify <table.dat>           # full integrity walk
  ezim encode <table.dat> <string>  # encode a UTF-8 string per EZ rules
  ezim pick   <table.dat> <char>    # show picker result for a single char
  ezim lookup <table.dat> <code>    # list all entries for a code (in source order)
";

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let result = match args.as_slice() {
        [c, p] if c == "info" => run_info(p),
        [c, p] if c == "verify" => run_verify(p),
        [c, p, s] if c == "encode" => run_encode(p, s),
        [c, p, s] if c == "pick" => run_pick(p, s),
        [c, p, s] if c == "lookup" => run_lookup(p, s),
        _ => {
            eprint!("{USAGE}");
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

fn run_info(path: &str) -> ezim_core::Result<()> {
    let bt = BinaryTable::open(path)?;
    println!("file: {path}");
    println!("  n_entries     : {}", bt.n_entries());
    println!("  n_strings     : {}", bt.n_strings());
    println!("  n_codes       : {}", bt.n_codes());
    println!("  source_hash_lo: 0x{:016x}", bt.source_hash_lo());
    Ok(())
}

fn run_verify(path: &str) -> ezim_core::Result<()> {
    let bt = BinaryTable::open(path)?;
    let mut walked = 0usize;
    for ev in bt.iter() {
        let _ = ev?;
        walked += 1;
    }
    if walked != bt.n_entries() {
        return Err(ezim_core::Error::Parse {
            line: 0,
            msg: format!(
                "header n_entries={} but only walked {walked}",
                bt.n_entries()
            ),
        });
    }
    println!("ok: {walked} entries decode cleanly");
    Ok(())
}

fn run_encode(path: &str, s: &str) -> ezim_core::Result<()> {
    let bt = BinaryTable::open(path)?;
    match bt.encode(s) {
        Ok(out) => {
            println!("{out}");
            Ok(())
        }
        Err(EncodeError::UnknownChar(c)) => Err(ezim_core::Error::Parse {
            line: 0,
            msg: format!("character {c:?} not in table"),
        }),
        Err(e) => Err(ezim_core::Error::Parse {
            line: 0,
            msg: e.to_string(),
        }),
    }
}

fn run_pick(path: &str, s: &str) -> ezim_core::Result<()> {
    let bt = BinaryTable::open(path)?;
    let mut chars = s.chars();
    let ch = chars.next().ok_or_else(|| ezim_core::Error::Parse {
        line: 0,
        msg: "empty character argument".into(),
    })?;
    if chars.next().is_some() {
        eprintln!("note: 'pick' uses only the first character of the argument");
    }

    let mut buf = [0u8; 4];
    let s = ch.encode_utf8(&mut buf);
    let candidates = bt.entries_for_text(s)?;

    println!("char: {ch:?}");
    if candidates.is_empty() {
        println!("  (not in table)");
        return Ok(());
    }
    println!("  candidates (source order):");
    for ev in &candidates {
        let mark = if ev.code.chars().count() == 1 {
            "single-key"
        } else if ev.code_is_all_numeric() {
            "all-numeric"
        } else {
            ""
        };
        println!("    {:<8}  {mark}", ev.code);
    }
    if let Some(ht) = bt.pick_codes(ch)? {
        println!("  picked: head={:?} tail={:?}", ht.head, ht.tail);
        println!("  encode (1-char): {}{}", ht.head, ht.tail);
        let _ = HeadTail::from_code; // keep import live
    }
    Ok(())
}

fn run_lookup(path: &str, code: &str) -> ezim_core::Result<()> {
    let bt = BinaryTable::open(path)?;
    let hits = bt.entries_for_code(code)?;
    if hits.is_empty() {
        println!("(no entries for code {code:?})");
        return Ok(());
    }
    println!("code: {code:?}  ({} entries, source order)", hits.len());
    for ev in &hits {
        let kind = if ev.is_phrase() { "phrase" } else { "char  " };
        println!("  {kind}  {}", ev.text);
    }
    Ok(())
}
