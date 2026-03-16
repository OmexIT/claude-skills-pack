# Component Spec Template

Copy this template for each component in the component tree.
Replace all PLACEHOLDER values.

---

```
COMPONENT: PLACEHOLDER_ComponentName
══════════════════════════════════════
File:    src/components/PLACEHOLDER_feature/PLACEHOLDER_ComponentName.tsx
Purpose: PLACEHOLDER one-line description

── REUSED FROM EXISTING ───────────────────────────────────────────────
  (List any existing components/patterns this extends or reuses)
  - <ExistingComponent> from <path> — reused for: <what>
  - (or) None — this is a new component (justify why existing patterns don't fit)

── PROPS ──────────────────────────────────────────────────────────────

interface PLACEHOLDER_ComponentNameProps {
  // Required
  PLACEHOLDER_propName:  PLACEHOLDER_type
  // Optional
  PLACEHOLDER_propName?: PLACEHOLDER_type
  // Events
  on PLACEHOLDER_Event:  (PLACEHOLDER_args) => void
  // Styling (optional override)
  className?:            string
}

── STATES ─────────────────────────────────────────────────────────────

  default   — PLACEHOLDER description
  hover     — PLACEHOLDER description
  focused   — PLACEHOLDER description
  active    — PLACEHOLDER description
  disabled  — PLACEHOLDER description
  loading   — PLACEHOLDER description (or: N/A)
  error     — PLACEHOLDER description (or: N/A)

── DATA-TESTIDS ───────────────────────────────────────────────────────

  [data-testid="PLACEHOLDER-root"]          ← component root element
  [data-testid="PLACEHOLDER-PLACEHOLDER"]   ← PLACEHOLDER element
  [data-testid="PLACEHOLDER-PLACEHOLDER"]   ← PLACEHOLDER element

── TAILWIND CLASSES (key) ─────────────────────────────────────────────

  root:      "PLACEHOLDER tailwind classes"
  PLACEHOLDER_child: "PLACEHOLDER tailwind classes"

── ACCESSIBILITY ──────────────────────────────────────────────────────

  role:              PLACEHOLDER
  aria-label:        PLACEHOLDER
  aria-describedby:  PLACEHOLDER (or: N/A)
  keyboard:          PLACEHOLDER (Tab, Enter, Escape behaviour)

── INTERACTIONS ───────────────────────────────────────────────────────

  PLACEHOLDER_event   → PLACEHOLDER what happens
  PLACEHOLDER_event   → PLACEHOLDER what happens

── DEPENDENCIES ───────────────────────────────────────────────────────

  Local:    PLACEHOLDER_ComponentName (./PLACEHOLDER)
  Shared:   PLACEHOLDER_ComponentName (shared/ui/PLACEHOLDER)
  Hooks:    usePLACEHOLDER (./hooks/usePLACEHOLDER)
  Utils:    PLACEHOLDER (lib/PLACEHOLDER)

── NOTES ──────────────────────────────────────────────────────────────

  PLACEHOLDER any special considerations, known edge cases, decisions
```
