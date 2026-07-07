---
name: igaming-ui
description: >
  Use when building or styling betting/casino interfaces — odds displays, betslips, live-event
  states, suspended markets, or wallet and money surfaces in gaming products.
argument-hint: "[screen or component]"
---

# iGaming UI patterns

Read `references/igaming-design-patterns.md` before designing. Non-negotiables:

- **Odds**: monospace/tabular numerals; brief flash on change (up/down pairing that stays colorblind-safe); layout never reflows on odds updates.
- **Market/event states are first-class**: open, suspended (visibly locked, never hidden), settled, void — each with a distinct token, not an ad-hoc style.
- **Live indicators**: distinct badge treatment; latency-tolerant updates — no spinner storms on every tick.
- **Money surfaces are sacred**: a wallet/balance tile never ships with a permanent error or a blank state; always a recoverable fallback.
- **Testability**: every interactive element gets a stable `data-testid` per `references/data-testid-conventions.md` — the design→e2e contract.

Compose with `/impeccable` for visual critique.
