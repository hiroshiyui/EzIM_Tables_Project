use std::io::BufReader;

use ezim_core::format::{collect_raw, write, BinaryTable};
use ezim_core::SourceTable;

fn sample_text() -> &'static str {
    "\
'\t是
''\t比
''\t艷
''2x\t比較
'1\t斷
76\t七
j'\t七
m'\t七
m\t一
16\t一
8\t八
86\t八
8/\t公
"
}

#[test]
fn roundtrip_preserves_entries() {
    let src = sample_text();
    let st = SourceTable::from_reader(BufReader::new(src.as_bytes())).unwrap();
    let bytes = write(&st, src.as_bytes());

    let bt = BinaryTable::from_bytes(bytes).unwrap();
    assert_eq!(bt.n_entries(), st.entries.len());

    let recovered = collect_raw(&bt).unwrap();
    assert_eq!(recovered.len(), st.entries.len());
    for (a, b) in st.entries.iter().zip(recovered.iter()) {
        assert_eq!(a.code, b.code);
        assert_eq!(a.text, b.text);
    }
}

#[test]
fn roundtrip_is_deterministic() {
    let src = sample_text();
    let st = SourceTable::from_reader(BufReader::new(src.as_bytes())).unwrap();
    let a = write(&st, src.as_bytes());
    let b = write(&st, src.as_bytes());
    assert_eq!(a, b, "writer must be deterministic");
}

#[test]
fn lookup_by_code_returns_source_order() {
    let src = sample_text();
    let st = SourceTable::from_reader(BufReader::new(src.as_bytes())).unwrap();
    let bytes = write(&st, src.as_bytes());
    let bt = BinaryTable::from_bytes(bytes).unwrap();

    // Code "'": "是" (line 1) is the only match; "''" should not match.
    let hits: Vec<_> = bt
        .entries_for_code("'")
        .unwrap()
        .into_iter()
        .map(|e| e.text.to_string())
        .collect();
    assert_eq!(hits, vec!["是"]);

    // Code "''": three matches in source order.
    let hits: Vec<_> = bt
        .entries_for_code("''")
        .unwrap()
        .into_iter()
        .map(|e| e.text.to_string())
        .collect();
    assert_eq!(hits, vec!["比", "艷"]);
}

#[test]
fn lookup_by_text_returns_codes_in_source_order() {
    let src = sample_text();
    let st = SourceTable::from_reader(BufReader::new(src.as_bytes())).unwrap();
    let bytes = write(&st, src.as_bytes());
    let bt = BinaryTable::from_bytes(bytes).unwrap();

    // 七 appears with codes "76", "j'", "m'" in that order.
    let codes: Vec<_> = bt
        .entries_for_text("七")
        .unwrap()
        .into_iter()
        .map(|e| e.code.to_string())
        .collect();
    assert_eq!(codes, vec!["76", "j'", "m'"]);

    // 一 appears with codes "m", "16" in source-file order
    // (note: file order has 'm' first because we listed "m\t一" first in sample_text).
    let codes: Vec<_> = bt
        .entries_for_text("一")
        .unwrap()
        .into_iter()
        .map(|e| e.code.to_string())
        .collect();
    assert_eq!(codes, vec!["m", "16"]);
}

#[test]
fn flags_are_set_correctly() {
    let src = sample_text();
    let st = SourceTable::from_reader(BufReader::new(src.as_bytes())).unwrap();
    let bytes = write(&st, src.as_bytes());
    let bt = BinaryTable::from_bytes(bytes).unwrap();

    // Find the phrase "比較" and confirm is_phrase.
    let entries: Vec<_> = bt.iter().collect::<Result<Vec<_>, _>>().unwrap();
    let phrase = entries.iter().find(|e| e.text == "比較").unwrap();
    assert!(phrase.is_phrase());

    // "76" code is all-numeric.
    let numeric = entries.iter().find(|e| e.code == "76").unwrap();
    assert!(numeric.code_is_all_numeric());

    // "j'" code is not all-numeric.
    let mixed = entries.iter().find(|e| e.code == "j'").unwrap();
    assert!(!mixed.code_is_all_numeric());
}

#[test]
fn rejects_bad_magic() {
    let mut bytes = vec![0u8; 256];
    bytes[0..8].copy_from_slice(b"NOTAEZIM");
    assert!(BinaryTable::from_bytes(bytes).is_err());
}
