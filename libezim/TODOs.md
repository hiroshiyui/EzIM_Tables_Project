# libezim TODOs

> ⚠️ **Work in progress — not production-ready.** libezim is in early
> development; API, `.dat` format, and C ABI may change without notice.

Open follow-ups beyond the design doc's M1–M7 milestones.

- [ ] **Integrate libezim into a real iBus or Fcitx engine.** Build a
  reference engine binary (separate repo) that links against
  `libezim.so` via the C ABI. Validates the session API end-to-end on
  a real desktop IME framework, drives any final ergonomics fixes
  (preedit highlighting, candidate-window paging, mode-switching),
  and gives F-Droid/AUR packagers a concrete consumer to point at.
