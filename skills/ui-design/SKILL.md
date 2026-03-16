---
name: ui-design
description: >
  Use this skill to produce complete UI/UX design artifacts from a specification document or panel analysis. Triggers include: "design the UI for this spec", "create wireframes", "design this panel", "UX design from spec", "generate component specs", "design tokens", "create the UI design for", "design system for", "wireframe this feature", or any time a spec/panel analysis document needs to be transformed into actionable UI/UX deliverables before implementation. Orchestrates a multi-agent design team (UX Lead, UI Designer, Component Architect, Accessibility Reviewer) in parallel waves. Outputs feed directly into spec-to-impl's FE agent. Always use this skill when the user wants design artifacts, wireframes, component breakdowns, or a design system from a spec — even if they say "just a quick design" or "rough wireframe".
arguments: >
  One or more space-separated paths to spec/panel analysis documents.
  Examples:
    /ui-design claudedocs/MONEY_REQUEST_PANEL_ANALYSIS.md
    /ui-design claudedocs/MONEY_REQUEST_PANEL_ANALYSIS.md claudedocs/PAYMENT_LINK_PAGE_PANEL_ANALYSIS.md
    /ui-design path/to/PRD.md --tokens-only
    /ui-design path/to/spec.md --mobile-first
    /ui-design path/to/spec.md --platform flutter
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
  --tokens-only      → run only the TOKENS agent (Section 4)
  --no-wireframes    → skip wireframe generation
  --no-a11y          → skip accessibility review
  --mobile-first     → prioritize mobile wireframes (375px primary viewport)
  --platform <p>     → target platform: react (default) | flutter | react-native | angular
  --output-dir <dir> → save artifacts to <dir> (default: design/)
```

**Step 2 — Check for handoff artifacts** from upstream skills:
```bash
ls -t claudedocs/handoff-*.yaml 2>/dev/null | head -5
```
If upstream handoff artifacts exist (from /prd, /design-doc, /flow-map), consume them to pre-fill context and skip redundant questions.

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
📐 UI-DESIGN LOADED
  Files: <n>
    ✅ <file1> — <panel name> (<n> screens, <n> flows)
    ✅ <file2> — <panel name> (<n> screens, <n> flows)

  Detected:
    Screens:    <n> total
    Components: ~<n> estimated
    User flows: <n>
    Tech stack: <React + Tailwind | Flutter | React Native | AngularJS> (inferred / confirmed)
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

## 3. Phase 2 — DESIGN

**Parallel wave — UI_DESIGNER + COPY run concurrently after UX_LEAD completes.**

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
🎨 UI-DESIGN COMPLETE — HANDOFF SUMMARY
========================================
Project: <name>
Screens: <n> | Components: <n> | Test IDs: <n>

FOR THE FE AGENT (spec-to-impl):
  Read these files in order:
  1. design/visual-spec/tokens.md        ← implement as CSS vars / Tailwind config / ThemeExtension
  2. design/components/component-tree.md ← file structure to create
  3. design/components/component-specs.md← props, state, classes per component
  4. design/copy/copy-spec.md            ← all strings — do not invent copy
  5. design/wireframes/                  ← visual reference per screen

FOR VERIFY-IMPL:
  design/components/testid-registry.md  ← use these as Playwright selectors

OPEN ISSUES TO RESOLVE BEFORE IMPLEMENTATION:
  ⚠️  [HIGH A11Y] Primary colour contrast — darken before coding
```

Write handoff artifact:
```yaml
# claudedocs/handoff-ui-design-<timestamp>.yaml
source_skill: "ui-design"
artifacts:
  - path: "design/components/component-tree.md"
    type: "component-tree"
  - path: "design/components/testid-registry.md"
    type: "testid-registry"
  - path: "design/visual-spec/tokens.md"
    type: "design-tokens"
  - path: "design/a11y/a11y-spec.md"
    type: "a11y-spec"
quality_assessment: "Complete, <n> a11y issues to resolve"
suggested_next:
  - skill: "spec-to-impl"
    context: "Design artifacts ready, <n> components, <n> test IDs"
  - skill: "verify-impl"
    context: "testid-registry.md has <n> selectors for Playwright"
```

---

## 10. Design Output Manifest

```
design/
├── ux/
│   ├── ia-map.md               ← UX_LEAD: information architecture
│   ├── flows.md                ← UX_LEAD: user flow diagrams
│   └── ux-inventory.md         ← UX_LEAD: screen + field inventory
├── wireframes/
│   ├── SCR-001-list.md         ← UI_DESIGNER: ASCII wireframes per screen
│   ├── SCR-002-create.md
│   └── SCR-003-detail.md
├── visual-spec/
│   ├── tokens.md               ← design tokens (colours, type, spacing)
│   └── visual-spec.md          ← spacing, elevation, motion rules
├── copy/
│   └── copy-spec.md            ← COPY: all UI strings per screen
├── components/
│   ├── component-tree.md       ← COMP_ARCH: full component breakdown
│   ├── component-specs.md      ← COMP_ARCH: per-component props/state/testids
│   ├── state-model.md          ← COMP_ARCH: client + server state
│   └── testid-registry.md      ← COMP_ARCH: all data-testids (→ verify-impl)
└── a11y/
    └── a11y-spec.md            ← A11Y: contrast, ARIA, keyboard, issues
```

---

## 11. Reference Files

| File | When to Read |
|---|---|
| `agents/ux-lead.md`       | Dispatching the UX_LEAD agent |
| `agents/ui-designer-comp-arch-a11y-copy.md` | Dispatching UI_DESIGNER, COMP_ARCH, A11Y, COPY agents |
| `references/token-schema-and-wireframe-notation.md` | Design token naming + ASCII wireframe symbols |
| `templates/component-spec.md` | Per-component spec template |

---

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
```
