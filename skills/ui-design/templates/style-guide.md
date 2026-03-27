# Style Guide — <Product Name>

## Brand Colors

| Token | Hex | Usage |
|---|---|---|
| `brand-primary` | #___ | Primary actions, links, active states |
| `brand-secondary` | #___ | Supporting elements, secondary actions |
| `accent` | #___ | Highlights, badges, callouts |
| `surface-default` | #___ / #___ (dark) | Card backgrounds, content areas |
| `surface-elevated` | #___ / #___ (dark) | Elevated cards, modals, dropdowns |
| `text-primary` | #___ / #___ (dark) | Headings, body text |
| `text-muted` | #___ / #___ (dark) | Captions, hints, secondary text |
| `border-default` | #___ / #___ (dark) | Dividers, input borders |
| `success` | #___ | Confirmation, positive states |
| `warning` | #___ | Alerts, attention needed |
| `error` | #___ | Errors, destructive actions |

## Typography Scale

| Name | Size | Weight | Line Height | Use Case |
|---|---|---|---|---|
| `display-xl` | ___px | ___ | ___ | Hero sections, marketing |
| `heading-lg` | ___px | ___ | ___ | Page titles |
| `heading-md` | ___px | ___ | ___ | Section headings |
| `heading-sm` | ___px | ___ | ___ | Card titles, sub-sections |
| `body-md` | ___px | ___ | ___ | Default body text |
| `body-sm` | ___px | ___ | ___ | Compact UI, tables |
| `caption` | ___px | ___ | ___ | Labels, hints, timestamps |

Font stack: `<primary>, <fallback>, sans-serif`

## Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `spacing-1` | 4px | Tight gaps (icon + text) |
| `spacing-2` | 8px | Within compact components |
| `spacing-3` | 12px | Within standard components |
| `spacing-4` | 16px | Default component padding |
| `spacing-6` | 24px | Between related elements |
| `spacing-8` | 32px | Between sections |
| `spacing-12` | 48px | Major section gaps |

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 4px | Inputs, small buttons |
| `radius-md` | 8px | Cards, buttons |
| `radius-lg` | 12px | Modals, panels |
| `radius-full` | 9999px | Pills, avatars |

## Component Examples

### Buttons
- **Primary**: `brand-primary` bg, white text, `radius-md`, h-10 (40px)
- **Secondary**: transparent bg, `brand-primary` border + text
- **Ghost**: transparent bg, `text-muted` text, no border
- **Destructive**: `error` bg, white text
- States: hover (darken 10%), active (darken 15%), disabled (opacity 50%)

### Inputs
- Height: 40px (md), 36px (sm), 44px (lg)
- Border: `border-default`, 1px
- Focus: `border-focus` + ring (2px, `brand-primary` at 20% opacity)
- Error: `error` border + inline error message below
- Always use `<label>`, not just placeholder

### Cards
- Background: `surface-default`
- Elevated: `surface-elevated` + `shadow-sm`
- Border: `border-default`, 1px (optional)
- Radius: `radius-md` (8px)
- Padding: `spacing-4` (16px)

## Do / Don't

| Do | Don't |
|---|---|
| Use semantic color tokens | Use raw hex values |
| Use spacing from the scale | Use arbitrary pixel values |
| Design all states (loading, empty, error) | Only design the happy path |
| Use minimum 44px touch targets on mobile | Make tiny tap targets |
| Use real content in designs | Use Lorem Ipsum everywhere |
| Test contrast ratios | Assume colors are accessible |
