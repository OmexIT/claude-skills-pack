---
name: ui-design
description: >
  Use this skill to produce complete UI/UX design artifacts from a specification document or panel analysis. Triggers include: "design the UI for this spec", "create wireframes", "design this panel", "UX design from spec", "generate component specs", "design tokens", "create the UI design for", "design system for", "wireframe this feature", "design a UI", "create a design system", "design this component", "design the layout", "create a style guide", "design a screen", "UI/UX review", "typography system", "color system", "spacing system", "design this feature", "design the dashboard", "design the onboarding", "create a component library", "design review", "audit the design", "improve the UI", "redesign this", "design system documentation", "create design guidelines", "responsive design", "mobile design", "dark mode design", "design the brand", or any time a spec/panel analysis document needs to be transformed into actionable UI/UX deliverables before implementation. Also triggers for standalone design system creation, component design, design reviews, dark mode/responsive variants, and developer handoff — even before code is involved. Orchestrates a multi-agent design team (UX Lead, UI Designer, Component Architect, Accessibility Reviewer, Design System Engineer, Design Reviewer) in parallel waves. Outputs feed directly into spec-to-impl's FE agent and figma-to-code.
arguments: >
  One or more space-separated paths to spec/panel analysis documents.
  Examples:
    /ui-design claudedocs/MONEY_REQUEST_PANEL_ANALYSIS.md
    /ui-design claudedocs/MONEY_REQUEST_PANEL_ANALYSIS.md claudedocs/PAYMENT_LINK_PAGE_PANEL_ANALYSIS.md
    /ui-design path/to/PRD.md --tokens-only
    /ui-design path/to/spec.md --mobile-first
    /ui-design path/to/spec.md --platform flutter
context: fork
agent: general-purpose
effort: high
---

# UI-Design: Multi-Agent UI/UX Design Skill

Transforms a spec or panel analysis document into a complete set of UI/UX design artifacts — ready to hand off to the FE agent in `spec-to-impl`.

---

## 0. Input Handling — Read This First

```
/ui-design $ARGUMENTS
```

**Step 1 — Parse** `$ARGUMENTS` for file paths and flags:
```
flags:
  --tokens-only      -> run only the TOKENS agent (Section 4)
  --no-wireframes    -> skip wireframe generation
  --no-a11y          -> skip accessibility review
  --mobile-first     -> prioritize mobile wireframes (375px primary viewport)
  --platform <p>     -> target platform: react (default) | flutter | react-native | angular
  --output-dir <dir> -> save artifacts to <dir> (default: design/)
  --stitch           -> force Stitch MCP generation (skip auto-detection)
  --figma <url|key>  -> import from Figma file via MCP (skip auto-detection)
  --manual           -> force manual generation (no external tools)
  --design-md <path> -> import an existing DESIGN.md as design system base
  --brief            -> start with design brief capture (Phase 0.5)
  --design-system    -> create full design system (Phase 4.5)
  --review           -> run design review only (Phase 6)
  --dark-mode        -> generate dark mode variant (Phase 7)
  --handoff          -> produce developer handoff document (Phase 8)
```

### Quick Decision Tree

```
Input received?
  ├─ "design a screen / feature / page" or spec path
  │     └─ → Phase 0.5: BRIEF → Phase 1: ANALYSE → Phase 1.5: GENERATE → Phase 2-4: DESIGN
  ├─ "create a design system / style guide / tokens"
  │     └─ → Phase 4.5: DESIGN SYSTEM CREATION
  ├─ "design this component"
  │     └─ → Phase 5: COMPONENT DESIGN
  ├─ "review / audit / critique this design"
  │     └─ → Phase 6: DESIGN REVIEW
  ├─ "dark mode" / "responsive" / "mobile"
  │     └─ → Phase 7: DESIGN VARIANTS
  └─ "handoff" / "ready for dev" / "spec for engineers"
        └─ → Phase 8: DESIGN HANDOFF
```

**Step 2 — Check for handoff artifacts** from upstream skills:
```bash
ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -5
```
If upstream handoff artifacts exist (from /prd, /design-doc, /flow-map), consume them to pre-fill context and skip redundant questions.

**Step 2.1 — Detect available design tools** (unless `--stitch`, `--figma`, or `--manual` flag is set):
```
DESIGN TOOL DETECTION
=====================
1. Check for Stitch MCP:  look for "stitch" or "generate_screen_from_text" in available MCP tools
2. Check for Figma MCP:   look for "figma" or "get_file" in available MCP tools
3. Check for DESIGN.md:   [ -f "DESIGN.md" ] || [ -f "design/DESIGN.md" ]
4. Check for Figma config: [ -f "figma.config.json" ] || [ -f ".figmarc" ]
5. Default:                manual generation (no external tools needed)

Result:
  design_mode: stitch | figma | design-md | manual
  Report to user:
    "Design tool: Stitch MCP detected -- will generate screens from spec"
    "Design tool: Figma MCP detected -- will extract from Figma file"
    "Design tool: DESIGN.md found -- will use as design system base"
    "Design tool: manual -- will generate ASCII wireframes + token specs"
```
See `references/design-tool-integration.md` for full setup and workflow per tool.

**Step 3 — Read each file** sequentially. For each:
- Identify: screens / panels / flows described
- Identify: user roles / actors
- Identify: data fields, states, interactions, error cases
- Identify: existing tech stack hints (React? Flutter? Tailwind? Design system?)

**Step 4 — MANDATORY: Scan for existing design patterns** in the codebase:
```bash
# Check for existing design system / components
find . -name "*.tsx" -path "*/components/*" -o -name "*.dart" -path "*/widgets/*" | head -30
# Check for existing design tokens / theme
find . -name "tailwind.config*" -o -name "theme.ts" -o -name "tokens.*" -o -name "colors.dart" | head -10
# Check for existing component library
find . -name "Button.tsx" -o -name "Modal.tsx" -o -name "Avatar.tsx" | head -10
```
If existing design patterns are found, the design MUST extend them — not create parallel systems.

**Step 5 — Merge** multiple files as panels of the same product. Identify shared components and consistent patterns across panels.

**Step 6 — Confirm:**
```
UI-DESIGN LOADED
  Files: <n>
    <file1> -- <panel name> (<n> screens, <n> flows)
    <file2> -- <panel name> (<n> screens, <n> flows)

  Detected:
    Screens:      <n> total
    Components:   ~<n> estimated
    User flows:   <n>
    Tech stack:   <React + Tailwind | Flutter | React Native | AngularJS> (inferred / confirmed)
    Design tool:  <Stitch MCP | Figma MCP | DESIGN.md import | manual>
    Existing design system: <found / not found>

  Agents activating: UX_LEAD, UI_DESIGNER, COMP_ARCH, A11Y
  Proceeding to Phase 1: ANALYSE...
```

---

## 0.1 Quick Decision Tree

```
Input?
  ├─ Spec / panel analysis files  → Phase 1: ANALYSE → Phase 2: DESIGN → Phase 3: SPEC → Phase 4: REVIEW
  ├─ "status" / "what's done?"    → STATUS REPORT (Section 7)
  ├─ --tokens-only                → Section 4 (Design Tokens) only
  ├─ --platform flutter           → Use Flutter-specific patterns in COMP_ARCH
  └─ "revise <screen>"            → REVISION MODE (Section 8)
```

---

## 1. Agent Roster

| Agent ID     | Role                   | Primary Output                                  |
|---|---|---|
| `UX_LEAD`    | UX Lead / IA           | User flows, IA map, screen inventory, UX decisions |
| `UI_DESIGNER`| UI Designer            | Wireframes, visual spec, spacing, color, typography |
| `COMP_ARCH`  | Component Architect    | Component tree, props API, state model, data-testids |
| `A11Y`       | Accessibility Reviewer | ARIA spec, keyboard flows, contrast ratios, WCAG audit |
| `COPY`       | UX Copywriter          | Labels, placeholders, error messages, empty states, tooltips |

**Always activate `UX_LEAD` and `COMP_ARCH`. Activate others based on spec scope.**

### Agent Model Routing

Route design agents to optimal models:

| Agent | Model | Rationale |
|---|---|---|
| `UX_LEAD` | `opus` | Strategic UX decisions require deepest reasoning |
| `UI_DESIGNER` | `sonnet` | Visual design generation — best coding model |
| `COMP_ARCH` | `opus` | Component architecture requires structural reasoning |
| `A11Y` | `sonnet` | WCAG checklist evaluation |
| `COPY` | `haiku` | UX copy generation — high-volume, lower complexity |
| `DESIGN_SYSTEM` | `sonnet` | Token and system design |
| `DESIGN_REVIEWER` | `opus` | Critical design review |

---

## 2. Phase 1 — ANALYSE

**Agent: UX_LEAD**
**Goal:** Extract the full UX surface from the spec before any design decisions are made.

### 2.1 Extract UX Inventory

From each spec file, extract:

```
UX INVENTORY
============
Project: <name>
Source:  <files>

SCREENS
───────
SCR-001  <Screen Name>
  Entry points:  <how user reaches this screen>
  User goal:     <what user is trying to accomplish>
  Data required: <what data must be loaded/present>
  Actions:       <buttons, links, form submissions>
  Exit points:   <where user goes after>
  States:        [empty | loading | populated | error | success | readonly]

SCR-002  ...

USER FLOWS
──────────
FLOW-001  <Flow Name>
  Actor:   <user role>
  Steps:   SCR-001 → (action) → SCR-002 → (action) → SCR-003
  Happy:   <brief description>
  Errors:  <what can go wrong and where>
  Edge:    <unusual but valid paths>

SHARED COMPONENTS (across screens)
───────────────────────────────────
  - <component name>: appears in SCR-001, SCR-003, SCR-005
  - ...

DATA FIELDS INVENTORY
─────────────────────
  Screen / Form      Field Name       Type        Validation         Required
  ─────────────────────────────────────────────────────────────────────────
  Money Request      amount           currency    > 0, max 999999    yes
  Money Request      recipient        text        phone/email        yes
  ...

AMBIGUITIES
───────────
  [UX-AMB-001] <question that needs product decision before design>
```

> ⚠️ Surface any UX ambiguities to the user before proceeding to Phase 2. Critical ambiguities (navigation model, primary CTA, auth gate) must be resolved first.

### 2.2 Information Architecture

UX_LEAD produces a navigation / IA map:

```
IA MAP
══════
App Root
├── Dashboard
│   ├── Money Requests Panel     ← SCR-001, SCR-002
│   │   ├── List View
│   │   ├── Create Flow          ← SCR-003 (modal / page?)
│   │   └── Detail View
│   └── Payment Links Panel      ← SCR-004, SCR-005
│       ├── List View
│       └── Create Flow
└── Settings
```

---

## 2.5 Phase 1.5 — GENERATE / IMPORT (conditional)

**Runs after Phase 1 ANALYSE, before Phase 2 DESIGN. Skipped in `--manual` mode.**

This phase uses external design tools when available to accelerate screen generation. The UX inventory from Phase 1 drives the prompts/imports — the tool generates, the agents refine.

### Mode A: Stitch MCP (design_mode = stitch)

```
1. CREATE PROJECT:
   create_project(title="<app name> UI Design")
   -> save projectId for all subsequent calls

2. CONFIGURE DESIGN SYSTEM from spec/existing tokens:
   Map spec design values to Stitch theme enums:
     colorMode:     LIGHT | DARK
     headlineFont:  nearest match from [INTER, MANROPE, PLUS_JAKARTA_SANS, GEIST, DM_SANS, ...]
     bodyFont:      nearest match from font enum
     roundness:     ROUND_FOUR | ROUND_EIGHT | ROUND_TWELVE | ROUND_FULL
     customColor:   primary brand color (hex, e.g. "#2563EB")
     colorVariant:  TONAL_SPOT (default), VIBRANT, MONOCHROME, etc.
     overrides:     overridePrimaryColor, overrideSecondaryColor, overrideTertiaryColor (hex)

   create_design_system(projectId, designSystem={displayName, theme})
   -> save assetId (design system ID)
   Immediately call update_design_system to apply and display (per Stitch API).

3. GENERATE SCREENS from UX inventory:
   For each screen (or screen group):
   generate_screen_from_text(
     projectId,
     prompt=<from UX inventory: layout, data fields, actions, style>,
     deviceType=DESKTOP|MOBILE|TABLET (from --platform flag),
     modelId=GEMINI_3_1_PRO
   )
   -> save screen IDs
   NOTE: May take several minutes. Do NOT retry on connection error.
   If output_components contains suggestions, present to user.

4. RETRIEVE SCREEN INSTANCES:
   get_project(name="projects/{projectId}")
   -> extract screen instances [{id, sourceScreen}]

   list_screens(projectId)
   -> get all screen IDs and resource names

5. APPLY DESIGN SYSTEM for visual consistency:
   apply_design_system(
     projectId,
     selectedScreenInstances=[{id: instanceId, sourceScreen: "projects/{p}/screens/{s}"}, ...],
     assetId
   )
   NOTE: Requires instance IDs from get_project, not screen IDs.

6. EXTRACT SCREEN STRUCTURE:
   Per screen: get_screen(name, projectId, screenId)
   -> write design/stitch-screens/SCR-XXX.md with:
     - Screen name and Stitch resource name
     - Component structure from response
     - Layout description
     - Stitch screen ID for downstream reference

7. WRITE TOKENS from our design system config:
   We defined the tokens in step 2 -- write design/visual-spec/tokens.md
   from our known config (colorMode, fonts, roundness, colors).
   No parsing needed -- we know exactly what we configured.

8. OPTIONAL: VARIANT EXPLORATION:
   generate_variants(projectId, screenIds, prompt,
     variantOptions={aspects: [LAYOUT, COLOR_SCHEME],
     creativeRange: EXPLORE, variantCount: 3})
   Present variants to user for selection.
```

**What Stitch provides:** Rapid visual exploration, layout generation, design system token application, screen structure data via `get_screen()`, variant generation for design exploration.
**What Stitch does NOT provide:** Code export (no TSX/HTML/CSS), image export (no PNG/SVG), state variants (empty/loading/error), accessibility, proper component hierarchy, spec-accurate copy. The agents in Phase 2-4 fill these gaps. Downstream FE agents reference Stitch screens by ID rather than using exported code as scaffolding.

### Mode B: Figma MCP (design_mode = figma)

```
1. EXTRACT file structure:
   get_file(file_key) -> page/frame hierarchy -> map to screen inventory

2. EXTRACT styles:
   get_file_styles(file_key) -> colors, typography, spacing, effects
   Map to design/visual-spec/tokens.md

3. EXTRACT components:
   get_file_components(file_key) -> component names, variants, properties
   Feed to COMP_ARCH as input (Phase 3)

4. EXPORT visual references:
   get_images(node_ids, format="png") -> design/wireframes/SCR-XXX-figma.png

5. EXTRACT code hints:
   get_code(node_id, format="css") -> CSS snippets for accurate spacing/styling
```

**What Figma provides:** Precise design specifications, design system tokens, component variants, pixel-perfect visual reference.
**What Figma does NOT provide:** Runnable code, auto-generated layouts, rapid exploration.

### Mode C: DESIGN.md Import (design_mode = design-md)

```
1. READ DESIGN.md from project root or design/ directory
2. PARSE: extract colors, typography, spacing, component patterns
3. MAP to ui-design token schema (design/visual-spec/tokens.md)
4. FEED to UI_DESIGNER and COMP_ARCH as constraints
```

### Mode D: Manual (design_mode = manual)

Skip this phase entirely. Proceed to Phase 2 where UI_DESIGNER generates ASCII wireframes and tokens from the spec alone.

### Post-Generation Checkpoint

After any generation/import mode:
```
GENERATION COMPLETE
  Source:         <Stitch MCP | Figma MCP | DESIGN.md | manual>
  Screens:        <n> generated/imported
  Tokens:         <n> extracted/configured
  Stitch project: <project ID> [Stitch only]
  Stitch screens: <n> screen IDs saved [Stitch only]
  Design system:  <asset ID> applied to all screens [Stitch only]
  Screen specs:   <n> design/stitch-screens/*.md files written [Stitch only]

  Next: Phase 2 agents will REFINE these outputs:
    - UI_DESIGNER: validate layout, add state variants, enforce tokens
    - COMP_ARCH: restructure into proper component hierarchy
    - A11Y: audit and annotate accessibility
    - COPY: replace placeholder text with spec-accurate copy
    - FE agents (downstream): will reference Stitch screen IDs via get_screen() for live structure data
```

---

## 3. Phase 2 — DESIGN

**Parallel wave — UI_DESIGNER + COPY run concurrently after Phase 1.5 completes (or Phase 1 if manual mode).**

### Parallel Wave Execution

Design agents execute in coordinated parallel waves:

```
Wave 1 (sequential): UX_LEAD — surface extraction, IA mapping, user flows
    ↓
Wave 2 (parallel):   UI_DESIGNER + COPY — wireframes + UX copy simultaneously
    ↓
Wave 3 (parallel):   COMP_ARCH + A11Y — component specs + accessibility review simultaneously
    ↓
Wave 4 (sequential): UX_LEAD — synthesis and design handoff document
```

- Wave 2 agents are independent: UI_DESIGNER works on visual layout while COPY generates microcopy
- Wave 3 agents are independent: COMP_ARCH defines component tree while A11Y reviews accessibility
- Use `run_in_background: true` for COPY agent — UX copy doesn't block visual design
- Each wave completes before the next starts (dependency gating)

When Stitch or Figma outputs exist from Phase 1.5, UI_DESIGNER **validates and refines** them rather than generating from scratch. When in manual mode, UI_DESIGNER **generates** wireframes.

### 3.1 UI_DESIGNER: Wireframes

For each screen in the inventory, produce:
1. **ASCII wireframe** — layout skeleton with proportional regions
2. **Visual spec** — spacing, color roles, type scale, elevation

**Wireframe format:**
```
┌─────────────────────────────────────────────────────────┐  SCR-001: Money Request List
│  ╔═══════════════════════════════════════════════════╗  │  Viewport: 375px mobile / 1280px desktop
│  ║  [←]  Money Requests              [+ New Request] ║  │
│  ╚═══════════════════════════════════════════════════╝  │  Regions:
│                                                         │    A: Top nav bar    — 56px, bg-surface-2
│  ┌─ FILTER BAR ─────────────────────────────────────┐  │    B: Filter bar     — 48px, bg-surface-1
│  │  [All ▾]  [Pending ▾]  [Date ▾]     [🔍 Search]  │  │    C: List area      — flex-col, scroll
│  └──────────────────────────────────────────────────┘  │    D: FAB            — fixed bottom-right
│                                                         │
│  ┌─ LIST ITEM (repeat) ─────────────────────────────┐  │  States:
│  │  [Avatar]  John Doe             KES 5,000  →     │  │    loading:  skeleton rows ×3
│  │            +254 700 000 000                      │  │    empty:    illustration + CTA
│  │            Oct 12 · PENDING  [●]                 │  │    error:    inline error banner
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│                          ╔═══╗                          │
│                          ║ + ║  ← FAB                   │
│                          ╚═══╝                          │
└─────────────────────────────────────────────────────────┘
```

**State wireframes** — produce a separate frame for each state:
```
[EMPTY STATE]                [LOADING STATE]             [ERROR STATE]
┌──────────────────┐         ┌──────────────────┐        ┌──────────────────┐
│                  │         │ ░░░░░░░░░░░░░░░░ │        │ ╔══════════════╗ │
│   [illustration] │         │ ░░░░░░░░░░       │        │ ║ ⚠ Could not  ║ │
│                  │         │ ░░░░░░░░░░░░░░░░ │        │ ║   load data  ║ │
│  No requests yet │         │ ░░░░░░░░░         │       │ ╚══════════════╝ │
│  [+ New Request] │         │ ░░░░░░░░░░░░░░░░ │        │  [Retry]         │
└──────────────────┘         └──────────────────┘        └──────────────────┘
```

### 3.2 UI_DESIGNER: Visual Spec

Produce a full design token set covering: color roles, typography scale, spacing, elevation, border radius, motion. See `references/token-schema-and-wireframe-notation.md` for the complete token schema and Tailwind config mapping.

### 3.3 COPY: UX Copy Spec

Per screen, produce all UI strings: page title, empty state (title + body + CTA), error state, success state, form labels, placeholders, error messages, button labels, tooltips.

---

## 4. Phase 3 — COMPONENT SPEC

**Agent: COMP_ARCH**
**Runs after Phase 2 completes.**

### 4.1 Platform-Specific Component Patterns

COMP_ARCH adapts output to the target platform:

**React (default):**
- Component tree with `.tsx` files
- Props as TypeScript interfaces
- React Query for server state, useState/Zustand for client state
- Tailwind utility classes
- `data-testid` attributes for Playwright

**Flutter:**
- Widget tree with `.dart` files
- Widget parameters as named constructor args
- Riverpod/BLoC for state management
- Theme tokens as `ThemeExtension`
- `Key` values for widget testing (`ValueKey('money-request-list')`)

**React Native:**
- Component tree with `.tsx` files
- Platform-specific files where needed (`.ios.tsx` / `.android.tsx`)
- React Query + Zustand for state
- StyleSheet or NativeWind for styling
- `testID` prop for Detox/RNTL

**AngularJS:**
- Component tree with `.component.js` + `.template.html` files
- Component bindings as API
- Services for shared state
- CSS classes (not Tailwind)
- `data-testid` attributes for Protractor/Karma

### 4.2 Component Tree

```
COMPONENT TREE
==============
<FeatureName>/
├── pages/
│   └── <FeaturePage>.tsx               ← route entry point, data fetching
├── components/
│   ├── <Feature>List/
│   │   ├── <Feature>List.tsx            ← list container
│   │   ├── <Feature>ListItem.tsx        ← single row
│   │   ├── <Feature>ListSkeleton.tsx    ← loading state
│   │   ├── <Feature>EmptyState.tsx      ← empty state
│   │   └── <Feature>FilterBar.tsx       ← filters + search
│   ├── <Feature>Form/
│   │   ├── <Feature>Form.tsx            ← create/edit form
│   │   ├── <Feature>FormModal.tsx       ← modal wrapper
│   │   └── <Feature>FormFields.tsx      ← individual fields
│   └── <Feature>Detail/
│       ├── <Feature>Detail.tsx          ← detail view
│       └── <Feature>StatusBadge.tsx     ← reusable status badge
└── hooks/
    ├── use<Feature>List.ts              ← list query + filters
    ├── use<Feature>Create.ts            ← mutation
    └── use<Feature>Detail.ts            ← detail query
```

### 4.3 Per-Component Spec

Use the template from `templates/component-spec.md`. Each component gets: props interface, states, data-testids, Tailwind classes, interactions, and dependencies.

### 4.4 Data-TestID Convention

All test IDs follow: `[feature]-[component]-[element]`

Rules:
- kebab-case only, no generated/dynamic parts
- Every interactive element gets a testid
- Every meaningful display element (amount, status, name) gets a testid
- These are a CONTRACT with `verify-impl` — listed in `testid-registry.md`
- Changing a testid requires updating `e2e/test-plan.yaml`

---

## 5. Phase 4 — ACCESSIBILITY REVIEW

**Agent: A11Y**
**Runs in parallel with COMP_ARCH after Phase 2.**

Produces:
1. **Colour contrast audit** — ratio for each foreground/background pair (WCAG 2.1 AA: 4.5:1 normal, 3:1 large)
2. **Keyboard nav spec** — Tab order, Enter/Space/Escape/Arrow key behaviours per screen
3. **ARIA spec** — role, label, describedby, live regions per component
4. **Focus management** — modals, drawers, toasts: trap focus, restore on close
5. **Screen reader copy** — aria-labels, alt text, hidden decorative elements
6. **Issues list** — HIGH / MEDIUM / LOW with remediation

### Mobile Accessibility (Flutter / React Native / Android)
- VoiceOver (iOS) + TalkBack (Android) compatibility
- Semantics labels on all interactive widgets (Flutter: `Semantics()`)
- `accessibilityLabel` on all touchable elements (React Native)
- `contentDescription` on all clickable views (Android)
- Minimum touch target: 48x48dp
- No information conveyed by colour alone

---

## 6. Best Practices

### 6.1 Atomic Design Hierarchy

Structure components in layers — don't mix responsibilities:

| Level | Examples | Rule |
|---|---|---|
| **Atoms** | Button, Input, Badge, Avatar, Icon | Pure, no business logic, fully reusable |
| **Molecules** | SearchBar, FormField, StatusBadge | Compose atoms, minimal local state |
| **Organisms** | ListItem, FilterBar, Form, DetailCard | Feature-aware, may fetch data |
| **Templates** | ListPage, DetailPage, FormModal | Layout containers, wire organisms |
| **Pages** | MoneyRequestsPage, PaymentLinksPage | Route entry points, data fetching orchestration |

### 6.2 Design Token Best Practices

- **Semantic over literal**: `--color-error` not `--color-red`. Enables theming.
- **Single source of truth**: Tokens defined in ONE file, consumed by Tailwind config (React), ThemeExtension (Flutter), StyleSheet (RN).
- **Dark mode**: Every semantic token has a light and dark variant. Use CSS `prefers-color-scheme` or Flutter `ThemeMode`.
- **No magic numbers**: Every spacing, font size, radius, shadow, and duration value comes from a token. Zero exceptions.
- **Token naming convention**: `--{category}-{property}-{variant}` e.g. `--color-surface-2`, `--spacing-md`, `--radius-lg`.

### 6.3 Responsive Design

| Breakpoint | Width | Target |
|---|---|---|
| `xs` | 0–374px | Small phones (edge case) |
| `sm` | 375px | Mobile (primary for mobile-first) |
| `md` | 768px | Tablet |
| `lg` | 1024px | Small desktop |
| `xl` | 1280px | Desktop (primary for desktop apps) |

Rules:
- **Mobile-first**: Start at 375px, enhance upward with `@media (min-width: ...)`
- **Content drives breakpoints**: If content breaks at 680px, add a breakpoint at 680px
- **Never hide critical actions behind breakpoints**: If it's important on mobile, it's important on desktop
- **Touch targets**: 44px minimum on mobile (Apple HIG), 48dp (Material)
- **Flutter**: Use `LayoutBuilder` and `MediaQuery` — never hardcode pixel widths
- **React Native**: Use `Dimensions` API and `flexbox` — never absolute positioning for layout

### 6.4 Component API Design

- **Props should be minimal**: Pass only what the component needs. Avoid "kitchen sink" interfaces.
- **Composition over configuration**: Prefer `<Card><CardHeader/><CardBody/></Card>` over `<Card header="..." body="..." />`.
- **Controlled by default**: All form inputs receive value + onChange. No internal state for form values.
- **Children for content, props for config**: Content goes in children/slots, behavior goes in props.
- **Consistent callback naming**: `onAction` pattern: `onClick`, `onSubmit`, `onChange`, `onClose`.

### 6.5 Performance-Aware Design

- **Skeleton screens over spinners**: Show layout shape during loading, not a generic spinner.
- **Virtualized lists**: For lists >50 items, design for windowed rendering (React: `react-window`, Flutter: `ListView.builder`, RN: `FlatList`).
- **Image optimization**: Specify dimensions in wireframes. Use `loading="lazy"` for below-fold images.
- **Animation budget**: Max 3 concurrent animations. Prefer opacity/transform (GPU-composited). No layout-triggering animations (width, height, margin).
- **Optimistic UI**: For mutations, show success state immediately and reconcile on server response. Design the reconciliation-failure state.

### 6.6 Form Design Best Practices

- **Inline validation**: Validate on blur, not on every keystroke. Show error below the field, not in a toast.
- **Error recovery**: When a form submission fails, preserve all entered data. Never clear the form on error.
- **Progressive disclosure**: Show optional fields behind a "More options" toggle.
- **Smart defaults**: Pre-fill what you can (currency from user profile, date as today).
- **Submit state**: Disable button during submission, show progress indicator, prevent double-submit.
- **Multi-step forms**: Show progress indicator (step 2 of 4). Allow back navigation without data loss.

### 6.7 Empty & Error State Design

Every screen MUST design for:

| State | Design rule |
|---|---|
| **Empty** | Illustration + explanation + primary CTA. Never just "No data." |
| **Loading** | Skeleton matching the layout shape. No spinner-only screens. |
| **Error** | What went wrong (user-friendly) + what to do (retry CTA). No stack traces. |
| **Success** | Confirmation + what happens next. Auto-dismiss after 3-5s or on action. |
| **Partial** | Partial data loaded, some failed. Show what you have + error banner for the rest. |
| **Offline** | Show cached data if available + subtle offline indicator. Queue mutations. |

### 6.8 Design System Reuse Mandate

Before creating ANY new component:
1. Check if the design system already has it
2. Check if a similar component exists that can be extended
3. Check if a third-party library (shadcn/ui, Material, Cupertino) provides it

⛔ Creating a new Button, Modal, Input, Avatar, Badge, Card, or Toast when one already exists is a BLOCKING issue. Reuse. Extend only if the existing component genuinely lacks what you need.

---

## 7. Status Reporting

```
═══════════════════════════════════════════════
  UI-DESIGN STATUS — <Project>
  <Timestamp> | Phase: <N>/4
═══════════════════════════════════════════════

📊 PROGRESS
  Screens designed:     <n>/<n>
  Components specced:   <n>
  Copy strings:         <n>
  A11y issues:          <n> high / <n> medium / <n> low

✅ COMPLETE
  • UX inventory + IA map (UX_LEAD)
  • Wireframes: SCR-001, SCR-002 (UI_DESIGNER)

🔄 IN PROGRESS
  • Component specs: 3/<n> done (COMP_ARCH)
  • A11y review: in progress (A11Y)

⚠️  DECISIONS NEEDED
  • [UX-AMB-001] Is the create flow a modal or full page?
═══════════════════════════════════════════════
```

---

## 8. Revision Mode

When user says "revise SCR-001" or "change the status badge design":

1. Identify which agents and artifacts are affected
2. Re-run only those agents with the revised brief
3. Update the affected files in `design/`
4. Check if the change cascades (e.g. colour token change → all wireframes, a11y contrast re-check)
5. Report what changed and what downstream artifacts need updating (e.g. if testids changed → update test-plan.yaml)

---

## 9. Handoff Package

When all phases complete, produce a **handoff summary** and **handoff artifact** for downstream skills:

```
UI-DESIGN COMPLETE -- HANDOFF SUMMARY
========================================
Project: <name>
Screens: <n> | Components: <n> | Test IDs: <n>
Design source: <Stitch MCP | Figma MCP | DESIGN.md | manual>

FOR THE FE AGENT (spec-to-impl):
  Read these files in order:
  1. design/visual-spec/tokens.md        -- implement as CSS vars / Tailwind config / ThemeExtension
  2. design/components/component-tree.md -- file structure to create
  3. design/components/component-specs.md-- props, state, classes per component
  4. design/copy/copy-spec.md            -- all strings -- do not invent copy
  5. design/wireframes/                  -- visual reference per screen (PNG from Figma if available, ASCII always)
  6. design/stitch-screens/              -- screen structure from Stitch get_screen() (Stitch mode only -- reference, not code)
  7. design/DESIGN.md                    -- portable design system spec

FOR VERIFY-IMPL:
  design/components/testid-registry.md  -- use these as Playwright selectors

FOR STITCH LIVE REFERENCE:
  Stitch project ID: <id>              -- downstream agents can call get_screen() directly
  Stitch design system: <asset ID>     -- tokens are already applied in Stitch
  Stitch screen IDs: [<id>, ...]       -- per-screen references for FE agents

OPEN ISSUES TO RESOLVE BEFORE IMPLEMENTATION:
  [HIGH A11Y] Primary colour contrast -- darken before coding
```

Write handoff artifact:
```yaml
# claudedocs/handoff-ui-design-<timestamp>.yaml
source_skill: "ui-design"
design_source: "<stitch | figma | design-md | manual>"
artifacts:
  - path: "design/components/component-tree.md"
    type: "component-tree"
  - path: "design/components/testid-registry.md"
    type: "testid-registry"
  - path: "design/visual-spec/tokens.md"
    type: "design-tokens"
  - path: "design/a11y/a11y-spec.md"
    type: "a11y-spec"
  - path: "design/DESIGN.md"
    type: "design-md"
    note: "Portable design system spec -- importable by Stitch and other tools"
  - path: "design/stitch-screens/"
    type: "stitch-screen-specs"
    note: "Screen structure from get_screen() (Stitch mode only)"
    conditional: "only if design_source == stitch"
stitch:                                    # present only when design_source == stitch
  project_id: "<Stitch project ID>"
  design_system_id: "<Stitch design system asset ID>"
  screens:
    - screen_id: "<Stitch screen ID>"
      instance_id: "<Stitch screen instance ID>"
      ref: "SCR-XXX"
      resource_name: "projects/{p}/screens/{s}"
quality_assessment: "Complete, <n> a11y issues to resolve"
suggested_next:
  - skill: "spec-to-impl"
    context: "Design artifacts ready. Stitch project <id> has <n> screens. FE agents can call get_screen() for live structure data. <n> components, <n> test IDs."
  - skill: "figma:figma-generate-design"
    context: "Design artifacts ready for Figma generation. <n> screens with wireframes, <n> tokens, <n> components. Consume design/ artifacts to populate Figma file."
  - skill: "verify-impl"
    context: "testid-registry.md has <n> selectors for Playwright. Stitch screen IDs available for structural reference."
```

---

## 10. Design Output Manifest

```
design/
├── ux/
│   ├── ia-map.md               -- UX_LEAD: information architecture
│   ├── flows.md                -- UX_LEAD: user flow diagrams
│   └── ux-inventory.md         -- UX_LEAD: screen + field inventory
├── wireframes/
│   ├── SCR-001-list.md         -- UI_DESIGNER: ASCII wireframes per screen
│   ├── SCR-001-figma.png       -- Figma-exported screenshot (if Figma mode)
│   ├── SCR-002-create.md
│   └── SCR-003-detail.md
├── visual-spec/
│   ├── tokens.md               -- design tokens (colours, type, spacing)
│   └── visual-spec.md          -- spacing, elevation, motion rules
├── copy/
│   └── copy-spec.md            -- COPY: all UI strings per screen
├── components/
│   ├── component-tree.md       -- COMP_ARCH: full component breakdown
│   ├── component-specs.md      -- COMP_ARCH: per-component props/state/testids
│   ├── state-model.md          -- COMP_ARCH: client + server state
│   └── testid-registry.md      -- COMP_ARCH: all data-testids (-> verify-impl)
├── stitch-screens/             -- (Stitch mode only) screen structure from Stitch API
│   ├── SCR-001.md              -- screen structure + Stitch IDs from get_screen()
│   ├── SCR-002.md
│   └── SCR-003.md
├── a11y/
│   └── a11y-spec.md            -- A11Y: contrast, ARIA, keyboard, issues
└── DESIGN.md                   -- portable design system spec (cross-tool)
```

---

## 11. Phase 0.5 — DESIGN BRIEF (standalone entry point)

*(Runs when user says "design a screen/feature" without a spec, or with `--brief` flag)*

Before designing anything, capture the brief. Batch all questions into one ask:

```
DESIGN BRIEF
============
Product:      <name and type>
Screen/Flow:  <what we are designing>
User:         <primary persona>
Platform:     <web | mobile | desktop>
Primary goal: <the single most important thing this design must do>
Visual tone:  <description — professional, playful, minimal, bold, dark, light>
Constraints:  <existing tech stack, accessibility, RTL, etc.>
References:   <links or descriptions of inspiration>
Design system: <existing | to be created | none>
```

**Questions to ask (all at once):**
1. What is this for? (product type, industry, use case)
2. Who is the user? (persona, technical level, context of use)
3. What is the primary action this screen/component must support?
4. What platform? (web, mobile web, native iOS/Android, desktop app)
5. Is there an existing design system or brand to follow?
6. Any reference designs or inspiration?
7. What is the visual tone?
8. Any hard constraints?

Confirm brief with user before proceeding to Phase 1 ANALYSE.

---

## 12. Phase 4.5 — DESIGN SYSTEM CREATION (standalone entry point)

*(Runs with `--design-system` flag or triggers: "create a design system", "build a style guide", "define design tokens")*

A full design system has these layers. Output each as a section in `design/design-system-spec.md`:

### 12.1 Brand Foundation

```
BRAND FOUNDATION
================
Name:        <product/brand name>
Personality: <3-5 adjectives>
Voice:       <how the brand sounds in UI copy>
Audience:    <who uses this product>
```

### 12.2 Color System

**Primitive palette** (50-950 shades per hue):
```
<ColorName>:
  50: #<hex>  100: #<hex>  200: #<hex>  300: #<hex>  400: #<hex>
  500: #<hex> — primary   600: #<hex> — hover   700: #<hex>
  800: #<hex>  900: #<hex> — text on light  950: #<hex>
```

**Semantic tokens** (light → dark):
```
SURFACES:
  --color-surface-page:       <light> / <dark>
  --color-surface-default:    <light> / <dark>
  --color-surface-elevated:   <light> / <dark>
  --color-surface-overlay:    <light> / <dark>

TEXT:
  --color-text-primary:       <light> / <dark>
  --color-text-secondary:     <light> / <dark>
  --color-text-muted:         <light> / <dark>
  --color-text-disabled:      <light> / <dark>
  --color-text-link:          <light> / <dark>

BORDERS:
  --color-border-default:     <light> / <dark>
  --color-border-strong:      <light> / <dark>
  --color-border-focus:       <light> / <dark>

BRAND:
  --color-brand-primary:      <light> / <dark>
  --color-brand-primary-hover: <light> / <dark>
  --color-brand-secondary:    <light> / <dark>

STATUS:
  --color-success-bg/text/border:  <light> / <dark>
  --color-warning-bg/text:         <light> / <dark>
  --color-error-bg/text:           <light> / <dark>
  --color-info-bg/text:            <light> / <dark>
```

For iGaming products, add semantic tokens from `references/igaming-design-patterns.md`.

### 12.3 Typography System

```
Font families:
  Display: <font> — hero text, large headings
  Heading: <font> — UI headings
  Body:    <font> — all body text and UI
  Mono:    <font> — odds, scores, codes, numbers

Type scale:
  display-2xl / display-xl / display-lg
  heading-xl / heading-lg / heading-md / heading-sm
  body-lg / body-md (default) / body-sm
  caption / overline (UPPERCASE + tracking)

Responsive: Mobile body-md = 15px, Desktop body-md = 16px
```

### 12.4 Spacing System

```
Base unit: 4px
Scale: 0 | 4 | 8 | 12 | 16 | 20 | 24 | 32 | 40 | 48 | 64 | 80 | 96

Semantic spacing:
  --spacing-component-xs/sm/md/lg — within components
  --spacing-section-sm/md/lg      — between sections
  --spacing-page                  — page-level padding
```

### 12.5 Shape & Elevation

```
Border radius: none | xs(2) | sm(4) | md(8) | lg(12) | xl(16) | 2xl(24) | full(9999)
Shadows:       xs | sm | md | lg | xl
Dark mode:     reduce shadow opacity by 40%
```

### 12.6 Component Inventory

For each component, output a **Component Card** (see `templates/component-spec.md`):
```
COMPONENT: <Name>
  Purpose | Category (atoms/molecules/organisms) | Variants | States | Sizes
  Props | Used in | Figma node | Status
  Anatomy | Usage rules (do/don't) | Responsive behavior
```

See `templates/design-system-spec.md` for the full blank template.

---

## 13. Phase 5 — COMPONENT DESIGN (standalone entry point)

*(Runs when user says "design this component" or "design the [component]")*

### Step 1 — Component Brief
```
COMPONENT BRIEF
===============
Name:        <ComponentName>
Purpose:     <single sentence>
Used where:  <screens or contexts>
User action: <what the user does with this>
Data:        <what data it displays or collects>
Constraints: <size limits, existing design system, tech stack>
```

### Step 2 — Variant Matrix
```
PRIMARY DIMENSION: <e.g. "size">    Values: [sm, md, lg]
SECONDARY DIMENSION: <e.g. "state"> Values: [default, hover, active, disabled, loading]
TERTIARY DIMENSION: <e.g. "theme">  Values: [light, dark]
Total variants: <n × n × n> — flag if > 12 (simplify)
```

### Step 3 — Component Spec
Use the Component Card format from Phase 12.6 and fill all fields.

### Step 4 — Interaction Design
```
<State>:
  Visual change: <what changes>
  Transition:    <duration, easing>
  Trigger:       <user action or system event>
  ARIA change:   <any aria-* attribute changes>
```

### Step 5 — Edge Cases
Always design for:
- Very long text (overflow, truncation, wrapping rules)
- Very short/empty text
- Numbers with many digits (odds: 1000.00 vs 1.5)
- Right-to-left text (if applicable)
- Missing images/avatars (fallback)
- Loading state (skeleton shape)
- Error state (inline error placement)

---

## 14. Phase 6 — DESIGN REVIEW (standalone entry point)

*(Runs with `--review` flag or triggers: "review this design", "audit the UI", "design feedback")*

Run through all lenses and output a **Design Review Report**:

### Review Lenses
1. **Visual hierarchy** — Is the primary action obvious? Natural eye flow?
2. **Consistency** — Spacing from design system? Colors from tokens? Similar elements look similar?
3. **Typography** — Clear hierarchy? Line lengths 45-75 chars? ≤3 font sizes per screen?
4. **Color & contrast** — WCAG AA? Semantic color use? Colorblind safe?
5. **Spacing & layout** — Consistent? Grid intact at all viewports? Touch targets ≥44px?
6. **States** — All designed? (loading, empty, error, partial) Empty state helpful?
7. **Interactions** — Affordance clear? Hover/focus visible? Feedback <100ms? Destructive actions protected?

### Report Format
```
DESIGN REVIEW REPORT
====================
Reviewed: <screen or component>
Overall:  <PASS | NEEDS WORK | FAIL>

━━━ CRITICAL (must fix) ━━━
❌ [CRIT-001] <issue> | Location: <where> | Fix: <recommendation>

━━━ MAJOR (should fix) ━━━
⚠️ [MAJ-001] <issue> | Fix: <recommendation>

━━━ MINOR (nice to fix) ━━━
💡 [MIN-001] <suggestion>

━━━ WHAT WORKS WELL ━━━
✅ <specific praise>

━━━ ACCESSIBILITY SCORE ━━━
Contrast: PASS/FAIL | Keyboard: PASS/FAIL | Touch targets: PASS/FAIL | Screen reader: PASS/FAIL

━━━ PRIORITY FIX LIST ━━━
1. [CRIT-001] — <summary>
2. [MAJ-001]  — <summary>
```

See `templates/design-review-report.md` for the full blank template.

---

## 15. Phase 7 — DESIGN VARIANTS

### Dark Mode Rules
- Never simply invert light mode — dark mode needs its own palette
- Surface hierarchy: page < default < elevated < overlay (each slightly lighter)
- Reduce saturation of brand colors slightly (vibrant looks harsh on dark)
- Never use pure black (#000000) — use #0A0A0A to #141414
- Text primary = near-white (#F5F5F5), not pure white (#FFFFFF)

Output: for each token, specify both values: `--color-surface-default: #FFFFFF / #1A1A1A`

### Responsive Design
For each screen, specify layout changes at each breakpoint:
```
RESPONSIVE SPEC — <ScreenName>
================================
Mobile (< 768px):
  Nav: <hamburger | bottom tab bar>
  Grid: 1 column, 16px padding
  Sidebar: hidden | drawer
  Cards: full width, stacked

Tablet (768px - 1024px):
  Nav: <top nav | side nav>
  Grid: 2 columns
  Sidebar: collapsed | icon-only

Desktop (> 1024px):
  Nav: full horizontal or expanded sidebar
  Grid: 12 columns, max-width 1440px
  Cards: 3-4 up grid
```

---

## 16. Phase 8 — DESIGN HANDOFF

*(Runs with `--handoff` flag or triggers: "ready for dev", "handoff", "spec for engineers")*

Output a **Developer Handoff Document** alongside the existing handoff YAML:

```
DEVELOPER HANDOFF
=================
Feature: <name>
Status:  Ready for development

━━━ WHAT TO BUILD ━━━
<2-3 sentence description>

━━━ SCREENS / COMPONENTS ━━━
<list with Figma links if available, or design spec references>

━━━ DESIGN TOKENS TO USE ━━━
<only the tokens used in this feature>

━━━ NEW COMPONENTS NEEDED ━━━
<list with Component Cards>

━━━ EXISTING COMPONENTS TO REUSE ━━━
<list with variant/prop values for this context>

━━━ INTERACTION NOTES ━━━
<hover states, transitions, animations>

━━━ EDGE CASES ━━━
<loading, empty, error, partial states>

━━━ ACCESSIBILITY REQUIREMENTS ━━━
<specific aria-*, keyboard, contrast for this feature>

━━━ RESPONSIVE NOTES ━━━
<layout changes at each breakpoint>

━━━ OPEN QUESTIONS ━━━
<anything needing designer/PM decision>
```

This document feeds into `/spec-to-impl` (FE agent) and `figma:figma-implement-design` (official plugin).

---

## 17. Reference Files

| File | When to Read |
|---|---|
| `agents/ux-lead.md`       | Dispatching the UX_LEAD agent |
| `agents/ui-designer-comp-arch-a11y-copy.md` | Dispatching UI_DESIGNER, COMP_ARCH, A11Y, COPY agents |
| `agents/design-system-agent.md` | Dispatching the design system creation agent (Phase 4.5) |
| `agents/component-design-agent.md` | Dispatching the component design agent (Phase 5) |
| `agents/design-review-agent.md` | Dispatching the design review agent (Phase 6) |
| `references/token-schema-and-wireframe-notation.md` | Design token naming + ASCII wireframe symbols |
| `references/design-tool-integration.md` | Stitch MCP, Figma MCP, and DESIGN.md integration guide |
| `references/accessibility-standards.md` | WCAG AA/AAA requirements, contrast, keyboard, touch targets |
| `references/igaming-design-patterns.md` | iGaming-specific patterns: odds, live, bet slip, casino, responsible gambling |
| `templates/component-spec.md` | Per-component spec template |
| `templates/design-system-spec.md` | Full design system spec template (Phase 4.5) |
| `templates/design-review-report.md` | Design review report template (Phase 6) |
| `templates/style-guide.md` | Condensed one-page style guide template |

---

### Progress Tracking

Use task management for design progress visibility:
- Create a task per design phase/wave
- Track individual agent completion within each wave
- Report design artifact completion percentage to the user

### Learning & Memory

After design completes, save reusable patterns:
- Design system tokens that proved effective for this project type
- Component patterns that worked well (for reuse in future ui-design runs)
- Accessibility patterns that were particularly relevant to this domain
- Design review findings that informed better initial designs

## Output contract
```yaml
produces:
  - type: ui-design
    format: markdown
    path: "design/"
    sections: [ux_inventory, ia_map, wireframes, tokens, visual_spec, copy, components, testids, a11y]
  - type: testid-registry
    format: markdown
    path: "design/components/testid-registry.md"
    consumed_by: "verify-impl"
  - type: design-tokens
    format: markdown
    path: "design/visual-spec/tokens.md"
    consumed_by: "spec-to-impl FE agent"
  - type: design-md
    format: markdown
    path: "design/DESIGN.md"
    consumed_by: "spec-to-impl FE agent, other design tools"
  - type: stitch-screen-specs
    format: markdown
    path: "design/stitch-screens/"
    consumed_by: "spec-to-impl FE agent (as reference, not scaffolding)"
    conditional: "only when design_source == stitch"
  - type: stitch-reference
    format: yaml
    path: "embedded in handoff YAML (stitch block)"
    consumed_by: "spec-to-impl FE agent, verify-impl"
    conditional: "only when design_source == stitch"
    note: "project_id, design_system_id, screen_ids for live Stitch API queries"
  - type: design-system-spec
    format: markdown
    path: "design/design-system-spec.md"
    consumed_by: "spec-to-impl FE agent, figma:figma-implement-design"
    conditional: "only when --design-system or Phase 4.5 runs"
  - type: design-review-report
    format: markdown
    path: "design/design-review-report.md"
    consumed_by: "spec-to-impl, finalize"
    conditional: "only when --review or Phase 6 runs"
  - type: developer-handoff
    format: markdown
    path: "design/developer-handoff.md"
    consumed_by: "spec-to-impl FE agent, figma:figma-implement-design"
    conditional: "only when --handoff or Phase 8 runs"
```
