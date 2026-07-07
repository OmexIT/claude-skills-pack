# iGaming Design Patterns Reference

Patterns specific to sports betting and casino products.

---

## Odds Display

- Use **monospaced font** for odds numbers (prevents layout shift when odds update)
- Always show odds with **consistent decimal places** (1.50 not 1.5)
- Flash **green** briefly when odds increase (#22C55E, 300ms fade)
- Flash **red** briefly when odds decrease (#EF4444, 300ms fade)
- Selected odds state: filled background with brand primary color
- Minimum tap target for odds buttons: **44x44px** (48px preferred on mobile)
- Odds button layout: use CSS Grid for consistent sizing regardless of value length

### Semantic Tokens for Odds
```
--color-odds-default:     <neutral bg>
--color-odds-increased:   #22C55E (green flash)
--color-odds-decreased:   #EF4444 (red flash)
--color-odds-selected:    <brand primary>
--color-odds-suspended:   <muted, with "SUSP" text>
```

---

## Live Indicators

- **"LIVE" badge**: always red (#EF4444), pulsing animation (2s ease-in-out infinite)
- **Live score**: monospaced, prominent, updates without layout shift
- **Live event card**: subtle left border accent in red (3px solid)
- **Live timer**: show elapsed time, update every second, monospaced
- **Live event count**: show number of live events in nav badge

---

## Bet Slip

- Always accessible from any screen (floating FAB or persistent right panel)
- Show **running total** prominently
- **Potential return** calculation visible at all times
- Remove individual bet: clear X button, minimum 44x44px touch target
- **Place Bet CTA**: full-width, high contrast, never disabled without clear reason shown
- Bet type tabs: Single / Accumulator / System (if supported)
- Stake input: large, numeric keyboard on mobile, pre-set stake buttons
- Error state: inline below the offending bet (e.g. "odds changed", "event suspended")

### Bet Status Tokens
```
--color-bet-pending:  <amber/yellow>
--color-bet-won:      <green>
--color-bet-lost:     <red/muted>
--color-bet-void:     <gray>
--color-bet-cashout:  <brand accent>
```

---

## Casino Grid

- Game cards: aspect ratio **3:4** (portrait) or **16:9** (landscape)
- Hover state: slight `scale(1.03)` + overlay with "Play" button
- **New/Hot/Jackpot** badges: top-left corner, high contrast, small rounded pill
- Provider name: small, muted, below game name
- Loading skeleton: match exact card dimensions
- Lazy load game thumbnails with blur-up placeholder
- Category tabs: horizontally scrollable on mobile, no wrapping

### Jackpot Display
```
--color-jackpot: <gold — #F59E0B or similar>
```
- Jackpot amount: large, monospaced, with currency symbol
- Counter animation: count up to current value on first appearance

---

## Responsible Gambling

- Always place **limits/help link in footer** — never hidden
- **Never use urgency language** in UI ("Last chance!", "Hurry!", "Don't miss out!")
- **Deposit limits UI**: clear, prominent, never buried in settings
- **Self-exclusion**: always accessible from account settings, one-click
- **Session timer**: optional display, configurable by user
- **Reality check**: periodic popup reminding of time/spend (configurable interval)
- **Cool-off periods**: clear UI for temporary self-exclusion

---

## Mobile-First Rules for iGaming

- **Bottom navigation** (not top) — thumbs reach bottom naturally
- Bet slip accessible via **bottom sheet**, not full-page nav
- **Swipeable card stacks** for quick game/event browsing
- Large, thumb-friendly odds buttons (min **48px height** on mobile)
- **Pull-to-refresh** for live event updates
- Quick bet: single-tap to add to slip (configurable)
- **Haptic feedback** on bet placement (native apps)

---

## Navigation Patterns

### Sportsbook
```
Bottom tabs: Home | Sports | Live | My Bets | Account
Sports nav:  Horizontal scrollable pills (Football, Basketball, Tennis, ...)
Sub-nav:     Today | Tomorrow | All | Outright
```

### Casino
```
Bottom tabs: Home | Casino | Live Casino | Promotions | Account
Category:    Horizontal scrollable (Slots, Table, Live, Jackpot, New, Popular)
```

### Combined Platform
```
Bottom tabs: Home | Sports | Casino | My Bets | Account
Home:        Featured events + game highlights + promotions carousel
```
