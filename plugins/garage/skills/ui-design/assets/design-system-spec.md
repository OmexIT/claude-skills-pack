# Design System Specification

## Brand Foundation

```
Name:        <product/brand name>
Personality: <3-5 adjectives - e.g. bold, trustworthy, fast, modern>
Voice:       <how the brand sounds in UI copy - e.g. confident, friendly, concise>
Audience:    <primary user persona and context>
```

## Color System

### Primitive Palette

<!-- Generate 50-950 shades for each brand hue -->

```
<PrimaryHue>:
  50: #___  100: #___  200: #___  300: #___  400: #___
  500: #___ (primary)  600: #___ (hover)  700: #___
  800: #___  900: #___ (text on light)  950: #___

<SecondaryHue>:
  50: #___  ... 950: #___

<NeutralGray>:
  50: #___  ... 950: #___
```

### Semantic Tokens (light / dark)

```
SURFACES:
  --color-surface-page:       #___ / #___
  --color-surface-default:    #___ / #___
  --color-surface-elevated:   #___ / #___
  --color-surface-subtle:     #___ / #___
  --color-surface-overlay:    #___ / #___

TEXT:
  --color-text-primary:       #___ / #___
  --color-text-secondary:     #___ / #___
  --color-text-muted:         #___ / #___
  --color-text-disabled:      #___ / #___
  --color-text-inverse:       #___ / #___
  --color-text-link:          #___ / #___

BORDERS:
  --color-border-default:     #___ / #___
  --color-border-strong:      #___ / #___
  --color-border-focus:       #___ / #___

BRAND:
  --color-brand-primary:       #___ / #___
  --color-brand-primary-hover: #___ / #___
  --color-brand-primary-subtle: #___ / #___
  --color-brand-secondary:     #___ / #___

STATUS (each paired with a text label or icon, never color alone):
  --color-{success|warning|error|info}-bg:     #___ / #___
  --color-{success|warning|error|info}-text:   #___ / #___
  --color-{success|warning|error|info}-border: #___ / #___
```

Contrast checked for every text and background pair in both themes: ___

## Typography System

```
Font families:
  Display: ___  Heading: ___  Body: ___  Mono: ___

Type scale:
  display-2xl:  ___px / ___  weight-___
  display-xl:   ___px / ___  weight-___
  heading-xl:   ___px / ___  weight-___
  heading-lg:   ___px / ___  weight-___
  heading-md:   ___px / ___  weight-___
  heading-sm:   ___px / ___  weight-___
  body-lg:      ___px / ___  weight-___
  body-md:      ___px / ___  weight-___  (default)
  body-sm:      ___px / ___  weight-___
  caption:      ___px / ___  weight-___
  overline:     ___px / ___  weight-___  UPPERCASE tracking-___
```

## Spacing System

```
Base unit: 4px

--spacing-0:  0     --spacing-1:  4px   --spacing-2:  8px
--spacing-3:  12px  --spacing-4:  16px  --spacing-5:  20px
--spacing-6:  24px  --spacing-8:  32px  --spacing-10: 40px
--spacing-12: 48px  --spacing-16: 64px  --spacing-20: 80px

Semantic:
  --spacing-component-xs: var(--spacing-2)
  --spacing-component-sm: var(--spacing-3)
  --spacing-component-md: var(--spacing-4)
  --spacing-component-lg: var(--spacing-6)
  --spacing-section-sm:   var(--spacing-8)
  --spacing-section-md:   var(--spacing-12)
  --spacing-section-lg:   var(--spacing-16)
  --spacing-page:         var(--spacing-20)
```

## Shape & Elevation

```
Border radius:
  --radius-none: 0    --radius-xs: 2px   --radius-sm: 4px
  --radius-md: 8px    --radius-lg: 12px  --radius-xl: 16px
  --radius-2xl: 24px  --radius-full: 9999px

Shadows:
  --shadow-xs:  0 1px 2px rgba(0,0,0,0.05)
  --shadow-sm:  0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)
  --shadow-md:  0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06)
  --shadow-lg:  0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)
  --shadow-xl:  0 20px 25px rgba(0,0,0,0.1), 0 10px 10px rgba(0,0,0,0.04)
Dark theme: express elevation with lighter surfaces rather than stronger shadows.
```

## Motion

```
--motion-duration-fast: ___ms   --motion-duration-base: ___ms   --motion-duration-slow: ___ms
--motion-easing-standard: ___
Reduced motion: ___ (durations to 0 or opacity-only fade; no pulse, parallax, or count-up)
```

## Component Inventory

<!-- Add a Component Card for each component -->

```
COMPONENT: <Name>
  Purpose:   ___
  Category:  atoms | molecules | organisms
  Variants:  [___]
  States:    [default, hover, focus, active, disabled, loading, error, empty]
  Sizes:     [sm, md, lg]
  Props:     { ___ }
  Used in:   [___]
  Status:    designed | in-review | approved | in-development | live

  ANATOMY:   <internal structure>
  USAGE:     Do: ___  |  Don't: ___
  RESPONSIVE: Mobile: ___  |  Desktop: ___
```
