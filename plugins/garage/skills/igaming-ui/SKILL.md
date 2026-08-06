---
name: igaming-ui
description: >
  Use for UI work in a sportsbook, betting, or casino (iGaming) product, including design review
  or visual critique of one: odds displays, betslips, live-event and suspended-market states,
  game lobbies and grids, and wallet, deposit, and balance surfaces.
---

# iGaming UI patterns

Read `references/igaming-design-patterns.md` before designing. Non-negotiables:

- **Odds**: tabular numerals; brief direction cue with text or glyph plus a semantic color token; respect reduced motion; layout never reflows on odds updates.
- **Market/event states are first-class**: open, suspended (visibly locked, never hidden), settled, void - each with a distinct token, not an ad-hoc style.
- **Live indicators**: distinct badge treatment; latency-tolerant updates - no spinner storms on every tick.
- **Money surfaces are sacred**: a wallet/balance tile never presents stale data as authoritative. Mark cached values as stale, offer recovery, and disable bet, deposit, withdrawal, or transfer actions until authoritative state returns unless an approved offline mutation design exists.
- **Testability**: expose accessible names and semantics first. Add a stable test ID only when a semantic locator is insufficient, per `../../references/ui-selector-conventions.md`.

Compose with whatever general UI or design skill is in use - it owns visual craft, layout, and
critique. These constraints load alongside it and take precedence wherever the two conflict on
odds, market state, or money display.
