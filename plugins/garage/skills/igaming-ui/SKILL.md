---
name: igaming-ui
description: >
  Use when building or styling sportsbook, betting, or casino (iGaming) interfaces: odds displays,
  betslips, live-event states, suspended markets, casino game grids, or wallet and money surfaces.
---

# iGaming UI patterns

Read `references/igaming-design-patterns.md` before designing. Non-negotiables:

- **Odds**: tabular numerals; brief direction cue with text or glyph plus a semantic color token; respect reduced motion; layout never reflows on odds updates.
- **Market/event states are first-class**: open, suspended (visibly locked, never hidden), settled, void - each with a distinct token, not an ad-hoc style.
- **Live indicators**: distinct badge treatment; latency-tolerant updates - no spinner storms on every tick.
- **Money surfaces are sacred**: a wallet/balance tile never presents stale data as authoritative. Mark cached values as stale, offer recovery, and disable bet, deposit, withdrawal, or transfer actions until authoritative state returns unless an approved offline mutation design exists.
- **Testability**: expose accessible names and semantics first. Add a stable test ID only when a semantic locator is insufficient, per `../../references/ui-selector-conventions.md`.

If the external `impeccable` plugin is installed, compose with it for visual critique.
