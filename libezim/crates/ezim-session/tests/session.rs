use std::io::BufReader;

use ezim_core::char_weights::{self, CharWeights};
use ezim_core::format::{write, BinaryTable};
use ezim_core::phrase_weights::{self, PhraseWeights};
use ezim_core::SourceTable;
use ezim_session::{Key, Session};

const SRC: &str = "\
'\t是
''\t比
''\t艷
''2x\t比較
'1\t斷
8\t八
86\t八
86\t捌
m\t一
16\t一
j'\t七
m'\t七
76\t七
8/\t公
,b\t報
";

fn make_table() -> BinaryTable {
    let st = SourceTable::from_reader(BufReader::new(SRC.as_bytes())).unwrap();
    let bytes = write(&st, SRC.as_bytes());
    BinaryTable::from_bytes(bytes).unwrap()
}

fn type_keys(s: &mut Session, keys: &str) {
    for c in keys.chars() {
        let _ = s.handle_key(Key::Char(c));
    }
}

#[test]
fn typing_a_code_lists_candidates_in_source_order() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "''");
    assert_eq!(s.buffer(), "''");
    assert_eq!(s.candidates(), &["比".to_string(), "艷".to_string()]);
    assert_eq!(s.page_count(), 1);
}

#[test]
fn space_commits_first_candidate_and_returns_to_idle() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "8");
    let out = s.handle_key(Key::Space);
    assert_eq!(out.commit, Some("八".to_string()));
    assert!(out.consumed);
    assert!(s.is_idle());
    assert!(s.candidates().is_empty());
}

#[test]
fn select_picks_a_specific_candidate() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "86");
    // 86 → 八, 捌
    assert_eq!(s.candidates(), &["八".to_string(), "捌".to_string()]);
    let out = s.handle_key(Key::Select(2));
    assert_eq!(out.commit, Some("捌".to_string()));
    assert!(s.is_idle());
}

#[test]
fn select_out_of_range_consumed_but_no_commit() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "8");
    let out = s.handle_key(Key::Select(9));
    assert!(out.consumed);
    assert_eq!(out.commit, None);
    assert_eq!(s.buffer(), "8"); // still composing
}

#[test]
fn backspace_shrinks_buffer_and_refreshes_candidates() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "''2x");
    assert_eq!(s.candidates(), &["比較".to_string()]);
    s.handle_key(Key::Backspace);
    assert_eq!(s.buffer(), "''2");
    assert!(s.candidates().is_empty()); // no entry for "''2"
    s.handle_key(Key::Backspace);
    assert_eq!(s.buffer(), "''");
    assert_eq!(s.candidates(), &["比".to_string(), "艷".to_string()]);
}

#[test]
fn backspace_at_idle_passes_through() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    let out = s.handle_key(Key::Backspace);
    assert!(!out.consumed);
}

#[test]
fn escape_clears_composition() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "''");
    let out = s.handle_key(Key::Escape);
    assert!(out.consumed);
    assert_eq!(out.commit, None);
    assert!(s.is_idle());
}

#[test]
fn invalid_key_at_idle_passes_through() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    let out = s.handle_key(Key::Char('A')); // uppercase not a valid EZ key
    assert!(!out.consumed);
    assert!(s.is_idle());
}

#[test]
fn buffer_caps_at_max_len() {
    let bt = make_table();
    let mut s = Session::new(&bt).with_max_buffer_len(4);
    type_keys(&mut s, "abcde");
    assert_eq!(s.buffer().chars().count(), 4);
}

#[test]
fn paging_wraps_around() {
    let bt = make_table();
    // Force page_size = 1 so 2 candidates → 2 pages.
    let mut s = Session::new(&bt).with_page_size(1);
    type_keys(&mut s, "''");
    assert_eq!(s.page_count(), 2);
    assert_eq!(s.current_page(), &["比".to_string()]);
    s.handle_key(Key::PageNext);
    assert_eq!(s.page(), 1);
    assert_eq!(s.current_page(), &["艷".to_string()]);
    s.handle_key(Key::PageNext);
    assert_eq!(s.page(), 0); // wrap
    s.handle_key(Key::PagePrev);
    assert_eq!(s.page(), 1); // wrap backward
}

#[test]
fn select_uses_current_page_indices() {
    let bt = make_table();
    let mut s = Session::new(&bt).with_page_size(1);
    type_keys(&mut s, "''");
    // page 0 holds 比, select(1) commits 比.
    assert_eq!(s.handle_key(Key::Select(1)).commit, Some("比".to_string()));

    // restart and advance to page 1
    let mut s = Session::new(&bt).with_page_size(1);
    type_keys(&mut s, "''");
    s.handle_key(Key::PageNext);
    // page 1 holds 艷, select(1) commits 艷.
    assert_eq!(s.handle_key(Key::Select(1)).commit, Some("艷".to_string()));
}

#[test]
fn space_with_no_candidates_drops_buffer() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "z"); // 'z' alone is not a code in our SRC
    assert!(s.candidates().is_empty());
    let out = s.handle_key(Key::Space);
    assert!(out.consumed);
    assert_eq!(out.commit, None);
    assert!(s.is_idle());
}

#[test]
fn typing_a_phrase_code_yields_phrase_candidate() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "''2x");
    assert_eq!(s.candidates(), &["比較".to_string()]);
    let out = s.handle_key(Key::Space);
    assert_eq!(out.commit, Some("比較".to_string()));
}

#[test]
fn weights_reorder_candidates_by_ascending_rank() {
    // SRC: code "''" maps to 比, 艷 in source-file order (比 first).
    // Without weights, that ordering wins. With char weights that rank
    // 艷 lower than 比, 艷 should jump ahead.
    let bt = make_table();

    // Build a CharWeights with 艷 higher-priority (lower rank) than 比.
    let cw_bytes = char_weights::write(&[('艷', 1), ('比', 5)], b"src");
    let cw = CharWeights::from_bytes(cw_bytes).unwrap();

    let mut s = Session::new(&bt).with_weights(Some(&cw), None);
    type_keys(&mut s, "''");
    assert_eq!(
        s.candidates(),
        &["艷".to_string(), "比".to_string()],
        "lower rank should win",
    );
}

#[test]
fn weights_place_absent_entries_after_ranked() {
    // 七 has three rows in source order: code "76" (text "七"), "j'" "七", "m'" "七".
    // The matching code is "76" so we test through "''" which has 比 (ranked)
    // and 艷 (absent from corpus). 比 should come first.
    let bt = make_table();
    let cw_bytes = char_weights::write(&[('比', 3)], b"src");
    let cw = CharWeights::from_bytes(cw_bytes).unwrap();

    let mut s = Session::new(&bt).with_weights(Some(&cw), None);
    type_keys(&mut s, "''");
    assert_eq!(
        s.candidates(),
        &["比".to_string(), "艷".to_string()],
        "absent (艷) should sort after ranked (比)",
    );
}

#[test]
fn phrase_weights_apply_to_multi_char_candidates() {
    let bt = make_table();
    // Make 比較 explicitly ranked.
    let pw_bytes = phrase_weights::write(&[("比較", 1)], b"src");
    let pw = PhraseWeights::from_bytes(pw_bytes).unwrap();

    let mut s = Session::new(&bt).with_weights(None, Some(&pw));
    type_keys(&mut s, "''2x");
    assert_eq!(s.candidates(), &["比較".to_string()]);
    // Sanity: phrase rank lookup worked end-to-end.
    let out = s.handle_key(Key::Space);
    assert_eq!(out.commit, Some("比較".to_string()));
}

#[test]
fn set_weights_after_buffer_in_flight_re_sorts_candidates() {
    let bt = make_table();
    let mut s = Session::new(&bt);
    type_keys(&mut s, "''");
    assert_eq!(s.candidates(), &["比".to_string(), "艷".to_string()]);

    let cw_bytes = char_weights::write(&[('艷', 1)], b"src");
    let cw = CharWeights::from_bytes(cw_bytes).unwrap();
    s.set_weights(Some(&cw), None);
    assert_eq!(
        s.candidates(),
        &["艷".to_string(), "比".to_string()],
        "set_weights must refresh ordering on the live buffer",
    );
}
