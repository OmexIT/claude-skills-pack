# iGaming interface patterns

Use these with the product's design system, user research, accessibility standard, approved
regulatory requirements, and jurisdiction configuration. They do not replace legal or
responsible-gambling review.

## Semantic tokens

Add these to the product's token set; values come from the theme, never hard-coded hex.

```
--color-odds-default / -increased / -decreased / -selected / -suspended
--color-bet-pending / -won / -lost / -void / -cashout
--color-live-indicator
--color-jackpot
```

Every one of these is paired with a non-color cue (glyph, text label, or shape).

## Odds and market states

- Tabular numerals so changing odds do not reflow the layout.
- Respect the user's configured decimal, fractional, or American odds format.
- Show an odds change with redundant cues: direction glyph or text, semantic color token, and a
  brief non-blocking transition. Color alone is insufficient.
- Under `prefers-reduced-motion` (or the platform equivalent), update the cue without flashing
  or pulsing.
- Keep open, suspended, settled, and void states explicit. A suspended market stays visible,
  clearly locked, and unselectable.
- Touch targets follow the platform baseline, with spacing that prevents accidental selection.

## Live state

- A text or icon cue identifies live content without relying on color.
- Live score, timer, and odds updates reserve layout space and use tabular numerals.
- No spinner per tick. Keep the last confirmed state visible while reconnecting and expose
  delayed or disconnected status.
- Animations are optional, subtle, and off or reduced under the user's motion preference.

## Bet slip

- Discoverable from the main betting journey. Choose panel, sheet, or page from the actual
  responsive layout, not a universal rule.
- Before confirmation show stake, current odds, potential return, currency, and any changed or
  suspended selections.
- On odds change, follow the product's approved acceptance policy and require clear user action
  when needed. Never silently accept worse odds.
- Never show a disabled primary action without an adjacent reason and recovery path.
- Prevent duplicate submission. An unknown placement result stays pending until authoritative
  reconciliation; a client timeout is not a failure.
- Numeric input mode without dropping validation, locale handling, or the accessible label.

## Wallet and balance

- A loading skeleton keeps its size and has accessible status text.
- A cached balance is labeled stale with its last-updated time and a retry path.
- While balance authority is unavailable, disable bet placement, deposit, withdrawal, and transfer
  actions that depend on it unless an approved offline mutation design proves safety.
- Never show a cached value as current or turn a timeout into a zero balance.
- Tabular numerals, explicit currency, and the asset's authoritative scale.

## Casino grids

- Preserve image dimensions to avoid layout shift; lazy-load media with meaningful alt behavior.
- Card ratio, hover, badges, and category layout come from the content and design system.
- Hover-only actions must also be keyboard and touch accessible.
- Virtualized or infinite grids expose loading, end, empty, and failure states and keep focus
  predictable.
- Do not animate jackpot or balance values when motion is reduced. Never imply a guaranteed win
  through animation or copy.

## Responsible gambling and compliance

- Implement the exact approved requirements per jurisdiction and product. Record the legal or
  compliance source of truth; do not invent universal placement, timing, or interaction rules.
- Help, limits, cooling-off, self-exclusion, reality-check, and session controls are findable,
  accessible, and testable wherever the applicable requirement demands them.
- No manipulative urgency ("Last chance!"), concealment, obstructive cancellation, or visual
  pressure to increase spend.
- A control that changes a regulated limit or exclusion state needs clear confirmation, outcome,
  effective time, and recovery or support guidance.
- Localized copy and age, identity, and jurisdiction rules come from approved product and legal
  artifacts, not this reference.

## Navigation and responsive checks

- Common shapes, not mandates: sportsbook tabs (Home, Sports, Live, My Bets, Account), casino tabs
  (Home, Casino, Live Casino, Promotions, Account), horizontally scrollable sport or category
  pills. Use them only when the product's evidence and platform conventions support them.
- Do not mandate bottom navigation, swipe gestures, haptics, pull-to-refresh, or one-tap betting.
  Each one needs an accessible alternative.
- Verify supported breakpoints, zoom, text resizing, keyboard flow, screen-reader names, focus
  order, high contrast, and reduced motion.
- Selector guidance: `ui-selector-conventions.md`.
