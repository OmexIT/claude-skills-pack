---
name: figma-to-code
description: >
  Convert Figma designs into production code using Figma MCP. Triggers include:
  "convert Figma design", "build from Figma frame", "implement this design",
  "generate code from Figma", "turn Figma selection into component",
  "extract design tokens", "build UI from design file", "read my Figma and build it",
  "clone this Figma frame", "implement design system from Figma",
  "sync design tokens", "set up Code Connect", "push to Figma",
  "capture my UI to Figma", "build from Figma link", "Figma to React",
  "Figma to Tailwind", "implement this Figma screen", "Figma MCP".
  Covers: selection-based conversion, link-based conversion, write-to-canvas,
  design token extraction, Code Connect setup, multi-screen flows, and reverse capture.
argument-hint: "[figma URL or 'selection' or 'tokens' or 'code-connect'] [--scaffold | --pixel-perfect]"
context: fork
effort: high
---

# Figma-to-Code: Design → Production Code

Converts Figma designs into production-quality React/TypeScript components using the Figma MCP server. Handles single components, full screens, multi-screen flows, design token extraction, Code Connect setup, and reverse UI capture.

---

## 0. Phase 0 — MCP Connection Check

Before any Figma work, verify the MCP connection:

```
FIGMA MCP CHECK
===============
1. Check available MCP tools for "figma" in the tool list
2. Determine mode:
   - Remote MCP (preferred): https://mcp.figma.com/mcp
   - Desktop MCP (fallback): http://127.0.0.1:3845/mcp

If NOT connected:
  Suggest: claude plugin install figma@claude-plugins-official

  WSL users — if Desktop MCP fails:
    1. In Windows PowerShell (admin):
       netsh interface portproxy add v4tov4 listenport=3845 listenaddress=0.0.0.0 connectport=3845 connectaddress=127.0.0.1
    2. Add to %UserProfile%\.wslconfig:
       [wsl2]
       networkingMode=mirrored
    3. Run: wsl --shutdown
    4. Restart WSL

Rate limits:
  Free plan:                6 calls/month
  Professional Dev seat:    Tier 1 per-minute limits
```

Report connection status before proceeding:
```
✅ Figma MCP: Connected (Remote)
   Mode: Remote MCP (mcp.figma.com)
```

---

## 1. Phase 1 — Input Mode Detection

Parse $ARGUMENTS to determine input mode:

```
$ARGUMENTS parsed:
  ├─ contains Figma URL (figma.com/design/...)  → MODE B: Link-based
  ├─ "selection" or no URL                      → MODE A: Selection-based
  ├─ "create", "add", "push", "capture"         → MODE C: Write-to-canvas
  ├─ "tokens", "design tokens", "sync"          → PHASE 5: Token extraction
  ├─ "code-connect", "Code Connect"             → PHASE 4: Code Connect setup
  └─ multiple URLs                              → PHASE 7: Multi-screen flow
```

### Mode A: Selection-Based

User selects a frame in Figma Desktop. Claude reads the live selection automatically via MCP.

```
1. Call Figma MCP to read current selection
2. Extract node data (properties, styles, children, variables)
3. Proceed to Phase 2 (Design Manifest)
```

### Mode B: Link-Based

User pastes a Figma URL. Claude extracts the node-id and fetches design data.

```
1. Parse URL to extract file key and node-id
   Format: https://figma.com/design/<file-key>/<name>?node-id=<node-id>
2. Call Figma MCP to read the specific node
3. Extract node data (properties, styles, children, variables)
4. Proceed to Phase 2 (Design Manifest)
```

### Mode C: Write-to-Canvas (Remote MCP only)

Claude creates or modifies frames directly in Figma.

Trigger phrases: "create a frame in Figma", "add a component to Figma", "update this Figma frame", "push to Figma", "capture my UI".

```
1. Verify Remote MCP is connected (Desktop MCP cannot write)
2. Determine action: create new frame | modify existing | capture from browser
3. If capture: proceed to Phase 6 (UI → Figma Capture)
4. If create/modify: use Figma MCP write tools
```

---

## 2. Phase 2 — Design Manifest Extraction

**Before writing any code**, extract and output a structured Design Manifest.

### Extraction Checklist

From the Figma node data, extract:
- Component name and variant props
- Color values → map to design tokens / CSS custom properties
- Typography: font-family, size, weight, line-height, letter-spacing
- Spacing: padding, margin, gap from auto-layout
- Border radius, border width, border color, shadow / effects
- Layout mode: auto-layout direction, wrap, alignment, constraints
- Frame dimensions and responsive constraints
- Figma variables → CSS custom property names
- Text content (real strings, not placeholder Lorem Ipsum)
- Interactive states: hover, focus, active, disabled, error, loading, empty
- Child components and composition structure
- Code Connect status: `mapped` (use existing component) or `unmapped` (generate from scratch)
- Ambiguities list

### Output Format

```
DESIGN MANIFEST
===============
Source:     <Figma file name / node name>
Component: <component name>
Variants:  <list of variant props and their values>

TOKENS FOUND:
  Colors:     <token-name: #hex or var(--token)>
  Typography: <font-family / font-size / weight / line-height / letter-spacing>
  Spacing:    <gap / padding values>
  Radius:     <border-radius values>
  Shadows:    <box-shadow values>
  Effects:    <blur, backdrop-filter, etc.>

LAYOUT:
  Mode:         <auto-layout | fixed | absolute | none>
  Direction:    <horizontal | vertical>
  Gap:          <value>
  Padding:      <top right bottom left>
  Alignment:    <primary axis: start/center/end/between> × <counter axis: start/center/end/stretch>
  Constraints:  <left / right / top / bottom / scale / center>
  Responsive:   <frame widths found: 375px, 768px, 1440px, etc.>

CHILDREN:
  1. <ChildName> — <type: component | instance | frame | text | vector>
     Props: <extracted props>
     Code Connect: ✅ mapped to <ExistingComponent> | ✗ unmapped
  2. ...

CODE CONNECT STATUS:
  ✅ Mapped   — use existing <ComponentName> import (path: <import path>)
  ✗ Unmapped — generate from scratch

INTERACTIVE STATES:
  Default:  ✅ present
  Hover:    <present | missing>
  Focus:    <present | missing>
  Active:   <present | missing>
  Disabled: <present | missing>
  Error:    <present | missing>
  Loading:  <present | missing>
  Empty:    <present | missing>

AMBIGUITIES:
  1. <unclear design decisions that need confirmation>
```

**Always pause after producing the Design Manifest:**

> "Does this match what you want? Any changes before I generate?"

---

## 3. Phase 3 — Code Generation

### Tech Stack Defaults

| Layer | Default | Override Trigger |
|---|---|---|
| Framework | React + TypeScript | User mentions Next.js, Vue, Angular, Svelte |
| Styling | Tailwind CSS | User mentions CSS Modules, styled-components, vanilla CSS |
| Component lib | None (pure Tailwind) | User mentions shadcn/ui, MUI, Ant Design, Radix |
| Icons | lucide-react | User specifies other library |
| Animation | Framer Motion | Only if design has transitions/animations |
| State | useState / props | Complex state → Zustand or Context |

**Always check the existing codebase first.** Scan for:
- Package.json dependencies (framework, styling, component library)
- Existing component patterns (naming, file structure, exports)
- Tailwind config or CSS variable conventions
- Test framework in use

Match what's already there. Never introduce a new pattern when an existing one covers the need.

### Fidelity Levels

| Level | Trigger Keywords | What's Generated |
|---|---|---|
| `PIXEL_PERFECT` | "exact", "pixel-perfect", "match exactly" | Full styles, all states, exact spacing, shadows, animations |
| `PRODUCTION` | Default (no keywords) | Accurate layout + styles, clean code, accessible, responsive |
| `SCAFFOLD` | "scaffold", "skeleton", "rough", "quick" | Structure + props + TODO comments only |

### Figma → Tailwind Value Mapping

See `references/component-patterns.md` for the full mapping table. Key conversions:

| Figma Property | Tailwind Class |
|---|---|
| Auto-layout horizontal | `flex flex-row` |
| Auto-layout vertical | `flex flex-col` |
| Space between | `justify-between` |
| Gap 4/8/12/16/24/32px | `gap-1` / `gap-2` / `gap-3` / `gap-4` / `gap-6` / `gap-8` |
| Padding 8/16/24px | `p-2` / `p-4` / `p-6` |
| Fill container | `flex-1` or `w-full` |
| Hug contents | `w-fit` |
| No Tailwind match | `[Xpx]` arbitrary value |
| Frame 375px | mobile (no prefix) |
| Frame 768px | `md:` prefix |
| Frame 1024px | `lg:` prefix |
| Frame 1280px | `xl:` prefix |
| Frame 1440px | `2xl:` prefix |

### Output Format

For every component, produce:

```
--- FILE: src/components/<Name>/<Name>.tsx ---
[TypeScript component with:
 - Typed Props interface (never `any`)
 - cn() for className merging
 - All Figma-extracted Tailwind classes
 - Named export (not default)
 - aria-* attributes for interactive elements
 - All interactive states from the manifest]
---

--- FILE: src/components/<Name>/index.ts ---
[Barrel export: export { <Name> } from './<Name>']
---

--- FILE: src/components/<Name>/<Name>.test.tsx ---
[Vitest + React Testing Library tests:
 - Renders without crashing
 - Renders with each variant
 - Prop types are correct
 - Accessibility: interactive elements have labels]
---

--- TOKENS: tailwind.config.ts additions ---
[Any new design tokens under theme.extend — only if not already present]
---

--- CSS: globals.css additions ---
[CSS custom properties in :root and [data-theme="dark"] — only if not already present]
---

--- USAGE EXAMPLE ---
[How to use the component with real props from the Figma design]
---
```

### Accessibility Requirements

Every generated component must have:

- `aria-label` or visible `<label>` for all interactive elements
- Focus management for modals and dropdowns (focus trap with `@radix-ui/react-focus-scope` or equivalent)
- WCAG AA color contrast: 4.5:1 for normal text, 3:1 for large text and UI components
- Keyboard navigation: Tab to focus, Enter/Space to activate, Escape to dismiss, Arrow keys for lists
- `aria-live` regions for dynamic content (toasts, loading states, live data)
- Empty `alt=""` for decorative images, descriptive `alt` for meaningful images
- `role` attributes where semantic HTML is insufficient

---

## 4. Phase 4 — Code Connect Setup

**Trigger:** user has an existing component library, or is building multiple components from the same Figma file.

### Setup Commands

```bash
# Install Code Connect
npm install --save-dev @figma/code-connect

# Generate mapping files from a Figma file
npx @figma/code-connect create \
  --figma-url "https://figma.com/design/YOUR_FILE_ID/" \
  --dir src/components

# Publish mappings to Figma (so developers see code in Inspect panel)
npx @figma/code-connect publish

# Validate without publishing
npx @figma/code-connect publish --dry-run
```

### Mapping Workflow

1. For each component generated in Phase 3, create a `.figma.tsx` file:

```tsx
// src/components/Button/Button.figma.tsx
import figma from '@figma/code-connect'
import { Button } from './Button'

figma.connect(Button, 'FIGMA_COMPONENT_URL', {
  props: {
    variant: figma.enum('Variant', {
      Primary: 'primary',
      Secondary: 'secondary',
      Ghost: 'ghost',
    }),
    size: figma.enum('Size', {
      Small: 'sm',
      Medium: 'md',
      Large: 'lg',
    }),
    disabled: figma.boolean('Disabled'),
    label: figma.string('Label'),
    icon: figma.children('Icon'),
  },
  example: ({ variant, size, disabled, label }) => (
    <Button variant={variant} size={size} disabled={disabled}>
      {label}
    </Button>
  ),
})
```

2. Publish all mappings: `npx @figma/code-connect publish`

See `references/code-connect-guide.md` for the full prop type mapping reference.

---

## 5. Phase 5 — Design Token Extraction

**Trigger phrases:** "extract design tokens", "sync design system", "generate tailwind config from Figma", "create CSS variables from Figma", "sync tokens".

### Extraction Workflow

```
1. Read Figma file variables and styles via MCP:
   - Color variables (primitives + semantic aliases)
   - Typography styles (font family, size, weight, line-height, letter-spacing)
   - Spacing variables
   - Border radius variables
   - Shadow / elevation styles
   - Color modes (light/dark collections)

2. Map to code:
   - Figma color variables → CSS custom properties + Tailwind theme
   - Figma typography → CSS custom properties + Tailwind fontSize
   - Figma spacing → CSS custom properties + Tailwind spacing
   - Figma radius → CSS custom properties + Tailwind borderRadius

3. Output token files
```

### Token Output Format

**tailwind.config.ts additions:**

```ts
export default {
  theme: {
    extend: {
      colors: {
        'brand-primary':    'var(--color-brand-primary)',
        'brand-secondary':  'var(--color-brand-secondary)',
        'surface-default':  'var(--color-surface-default)',
        'surface-elevated': 'var(--color-surface-elevated)',
        'text-primary':     'var(--color-text-primary)',
        'text-muted':       'var(--color-text-muted)',
        'border-default':   'var(--color-border-default)',
      },
      spacing: {
        'xs': 'var(--spacing-xs)',    // 4px
        'sm': 'var(--spacing-sm)',    // 8px
        'md': 'var(--spacing-md)',    // 16px
        'lg': 'var(--spacing-lg)',    // 24px
        'xl': 'var(--spacing-xl)',    // 40px
      },
      borderRadius: {
        'sm': 'var(--radius-sm)',     // 4px
        'md': 'var(--radius-md)',     // 8px
        'lg': 'var(--radius-lg)',     // 12px
        'xl': 'var(--radius-xl)',     // 16px
      },
    }
  }
}
```

**globals.css additions:**

```css
:root {
  /* Colors — from Figma Light mode collection */
  --color-brand-primary:    #<hex>;
  --color-brand-secondary:  #<hex>;
  --color-surface-default:  #<hex>;
  --color-surface-elevated: #<hex>;
  --color-text-primary:     #<hex>;
  --color-text-muted:       #<hex>;
  --color-border-default:   #<hex>;

  /* Spacing — from Figma spacing variables */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 40px;

  /* Radius — from Figma radius variables */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
}

[data-theme="dark"] {
  /* Colors — from Figma Dark mode collection */
  --color-brand-primary:    #<dark-hex>;
  --color-brand-secondary:  #<dark-hex>;
  --color-surface-default:  #<dark-hex>;
  --color-surface-elevated: #<dark-hex>;
  --color-text-primary:     #<dark-hex>;
  --color-text-muted:       #<dark-hex>;
  --color-border-default:   #<dark-hex>;
}
```

Token naming convention: `--<category>-<semantic-name>` where category is `color`, `spacing`, `radius`, `shadow`, `font`.

---

## 6. Phase 6 — UI → Figma Capture (Reverse Flow)

**Trigger phrases:** "capture my UI to Figma", "push to Figma", "send my app to Figma", "capture localhost to Figma".

### Capture Workflow

```
1. START LOCAL DEV SERVER (if not running)
   Check: curl -sf http://localhost:3000 || npm run dev &
   Wait for server to be healthy

2. CAPTURE AT MULTIPLE VIEWPORTS
   Capture at 375px (mobile) and 1440px (desktop) separately:
   - Use Figma MCP capture_to_figma tool
   - Name frames clearly: "<Page Name> — Mobile" / "<Page Name> — Desktop"

3. CAPTURE INTERACTIVE STATES
   For each key component, capture:
   - Default state
   - Hover state (simulate with DevTools)
   - Focus state
   - Error state (trigger validation errors)
   - Loading state (throttle network)
   - Empty state (clear data)

4. RETURN FIGMA LINK
   Provide the URL to the created Figma file/frame
```

### Best Practices

- Name HTML elements clearly before capture — they become Figma layer names
- Capture full pages, not just viewports (scroll capture)
- Set `data-figma-name` attributes on key containers for meaningful layer names
- Capture both light and dark mode if the app supports it
- Use the Figma capture toolbar to select specific pages/flows

---

## 7. Phase 7 — Multi-Screen Flow

When building multiple connected screens from Figma, always produce a **Screen Manifest** first.

### Screen Manifest Format

```
SCREEN MANIFEST
===============
Shell/Layout:  <figma-frame-link> → layout.tsx or _app.tsx
Screen 1:      <figma-frame-link> → /dashboard
Screen 2:      <figma-frame-link> → /sports
Screen 3:      <figma-frame-link> → /casino
Screen 4:      <figma-frame-link> → /account

Shared components (build first):
  NavBar:       <figma-frame-link>
  BetSlipCard:  <figma-frame-link>
  OddsCard:     <figma-frame-link>
  Footer:       <figma-frame-link>

Routing: <React Router | Next.js App Router | Next.js Pages Router>
```

### Build Order

1. **Shared components first** — appear in multiple screens (run Phase 2-3 for each)
2. **Shell / layout** — wraps all screens (navigation, footer, sidebar)
3. **Individual screens** — reuse shared components, generate page-level components
4. **Routing / navigation** — wire up routes and navigation links last

### Screen-Level Output

For each screen, in addition to Phase 3 output, produce:

```
--- FILE: src/app/<route>/page.tsx (Next.js) or src/pages/<Route>.tsx (React Router) ---
[Full page component composing shared components + screen-specific components]
---

--- ROUTING ---
[Route definitions or Next.js App Router file structure]
---
```

---

## 8. Common Prompts Reference

Ready-to-use prompts for the user:

### Selection-Based
```
"Convert my current Figma selection to a React + Tailwind component"
"Build the component I have selected in Figma. Use TypeScript and shadcn/ui."
"My Figma selection is a modal — generate it with a11y and focus trap"
```

### Link-Based
```
"Build this from Figma: [url] — use our existing design system components"
"Implement the sports betting dashboard: [url]. Dark theme, mobile-first."
"Generate the complete onboarding flow from these frames: [url1] [url2] [url3]"
```

### Design Tokens
```
"Extract all color and spacing variables from this Figma file and create tailwind.config.ts"
"Sync the typography styles from Figma to our CSS custom properties"
"Generate dark mode tokens from the Figma dark mode frame"
```

### Code Connect
```
"Set up Code Connect between our component library and this Figma file"
"Map all Button variants in Figma to our Button component"
"Publish our Code Connect mappings to Figma"
```

### Reverse Flow
```
"Capture my localhost:3000 app and push it to a new Figma file for design review"
"Start my dev server and capture the dashboard at mobile and desktop breakpoints"
"Push all my app screens to Figma so the designer can review"
```

### Full Page / Multi-Screen
```
"Build the full home page from this Figma frame. Use our existing Nav and Footer."
"Implement all 4 screens from this Figma flow: [url]. Wire up React Router."
```

---

## Anti-patterns to flag

- **Guessing at design values** — never invent colors, spacing, or typography. Use the manifest.
- **Ignoring existing codebase patterns** — always scan first. Don't introduce a new component library when one exists.
- **Skipping accessibility** — every interactive element must have labels, focus management, and keyboard support.
- **Hardcoding colors/spacing** — use CSS custom properties or Tailwind theme tokens, not raw hex/px values.
- **Default exports** — always use named exports for tree-shaking and refactoring safety.
- **Monolithic components** — break complex Figma frames into focused sub-components.
- **Missing states** — if Figma has hover/disabled/error variants, implement all of them.

## Quality bar

- All extracted values match the Figma design (no guessing)
- TypeScript types are complete (no `any`)
- Accessibility checklist passes (see `agents/ui-agent.md`)
- Component renders correctly with all variant combinations
- Tests cover render + each variant + accessibility basics
- Responsive breakpoints match Figma frame widths
- Design tokens use CSS custom properties (not hardcoded values)
- Code follows existing codebase conventions

## Workflow context

- Typically follows: `/prd`, `/design-doc`, `/ui-design` (Figma mode)
- Feeds into: `/verify-impl` (Playwright tests against testIDs), `/finalize` (commit + PR)
- Related: `/ui-design` (generates design artifacts when no Figma file exists), `/code-audit` (review generated code)
- Handoff: produces `claudedocs/handoff-figma-to-code-<timestamp>.yaml` with component list, token changes, and Code Connect status

## Reference Files

| File | When to Read |
|---|---|
| `agents/ui-agent.md` | Dispatching the UI generation agent |
| `references/component-patterns.md` | Full TypeScript patterns, auto-layout mapping, responsive breakpoints |
| `references/code-connect-guide.md` | Setting up and publishing Code Connect |
| `templates/component-template.tsx` | Component scaffold template |
| `templates/figma-connect-template.tsx` | Code Connect mapping template |

## Learning & Memory

After completing a figma-to-code conversion, persist the following to project memory for future skill invocations:

- **Component extraction patterns**: How Figma frame structures mapped to component hierarchies for this project's design system
- **Token mapping approaches**: Which Figma variables mapped to which CSS custom properties or Tailwind theme tokens, including naming conventions adopted
- **Code generation patterns**: Framework-specific patterns, accessibility implementations, and codebase conventions that should be reused in future conversions

Store in: `claudedocs/memory/figma-to-code.md`

## Output contract

```yaml
produces:
  - type: react-components
    format: tsx
    path: "src/components/<Name>/<Name>.tsx"
    sections: [types, component, display_name]
  - type: component-tests
    format: tsx
    path: "src/components/<Name>/<Name>.test.tsx"
  - type: design-tokens
    format: ts+css
    path: "tailwind.config.ts + globals.css"
    conditional: "when new tokens extracted"
  - type: code-connect-mappings
    format: tsx
    path: "src/components/<Name>/<Name>.figma.tsx"
    conditional: "when Code Connect is set up"
  - type: design-manifest
    format: markdown
    path: "claudedocs/<feature>-figma-manifest.md"
  - type: handoff
    format: yaml
    path: "claudedocs/handoff-figma-to-code-<timestamp>.yaml"
    sections: [source_skill, artifacts, components, tokens, code_connect_status]
```
