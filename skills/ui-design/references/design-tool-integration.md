# Design Tool Integration Reference

This document defines how the ui-design skill integrates with external design tools (Stitch AI, Figma) via MCP, with graceful fallback to manual generation.

---

## 1. Tool Detection Priority

The skill auto-detects available design tools in this order:

```
DETECTION ORDER
===============
1. Stitch MCP server available?  -> Use for rapid generation
2. Figma MCP server available?   -> Use for design system extraction
3. Neither available?            -> Manual generation (ASCII wireframes + token specs)

Detection method:
  - Check for MCP tools matching "stitch" or "figma" in available tool list
  - Check for DESIGN.md in project root (Stitch export)
  - Check for .figma/ or figma.config.* files (Figma project)
  - Check for design/ directory with existing artifacts
```

## 2. Stitch MCP Integration

### Setup

The Stitch MCP server exposes generation tools to Claude Code. Setup in `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "stitch": {
      "type": "url",
      "url": "https://stitch.googleapis.com/v1/mcp/sse",
      "headers": {
        "x-goog-api-key": "${STITCH_API_KEY}"
      }
    }
  }
}
```

Alternative: Use the community CLI wrapper (`stitch-mcp` from github.com/davideast/stitch-mcp) for local development.

### Available MCP Tools

| Tool | Purpose | Input | Output |
|---|---|---|---|
| `build_site` | Generate multi-screen UI from text prompt | Text description + style preferences | Screen designs on Stitch canvas |
| `get_screen_code` | Export code for a screen | Screen ID + format (html/tailwind/react) | HTML/CSS, Tailwind, or React/JSX code |
| `get_screen_image` | Export screen as image | Screen ID + format | PNG/SVG screenshot |

### Generation Workflow

```
1. PROMPT CONSTRUCTION
   From the UX inventory (Phase 1), construct Stitch prompts:

   Per screen:
   "Design a [screen type] for [app name].
    Layout: [description from UX inventory]
    Data: [fields from data inventory]
    Actions: [buttons/interactions from spec]
    States: [empty, loading, error, success]
    Style: [design tokens if already defined, or 'modern, clean, professional']
    Platform: [web | mobile]"

2. GENERATION
   Call build_site with the combined prompt for all screens in a flow.
   Stitch generates up to 5 connected screens per call.

3. CODE EXPORT
   For each generated screen:
   - get_screen_code(format="react")  -> React/JSX + Tailwind
   - get_screen_code(format="html")   -> Semantic HTML/CSS (fallback)
   - get_screen_image(format="png")   -> Visual reference screenshot

4. DESIGN.MD EXTRACTION
   If Stitch produces a DESIGN.md, consume it as the design system spec.
   Map DESIGN.md tokens to the ui-design token schema.

5. REFINEMENT
   Stitch output is 60-80% complete. The skill's agents then:
   - COMP_ARCH: Restructures into proper component hierarchy
   - A11Y: Audits and adds accessibility annotations
   - COPY: Replaces placeholder text with spec-accurate copy
   - UI_DESIGNER: Validates spacing, hierarchy, token compliance
```

### Stitch Output Mapping

| Stitch Output | Maps To | ui-design Artifact |
|---|---|---|
| Generated screens | Wireframe reference | `design/wireframes/SCR-XXX-stitch.png` |
| React/JSX export | Component scaffolding | `design/stitch-export/SCR-XXX.tsx` |
| Tailwind classes | Token candidates | `design/visual-spec/tokens.md` (validated) |
| DESIGN.md | Design system spec | `design/stitch-design.md` (consumed) |

### Limitations to Handle

- **Generation limits**: 350 standard / 200 pro per month. Batch screens into flows (5 per call).
- **Generic output**: Stitch designs tend generic — COMP_ARCH must restructure to match codebase patterns.
- **No state variants**: Stitch generates the happy-path state. UI_DESIGNER must produce empty/loading/error states.
- **No design tokens**: Stitch doesn't enforce a token system. UI_DESIGNER must extract tokens from generated CSS.
- **React/Tailwind only**: No Flutter, React Native, or AngularJS export. For non-React platforms, use screenshots as reference and generate code manually.
- **No accessibility**: Stitch output lacks ARIA roles, keyboard nav, and screen reader support. A11Y agent is mandatory.

---

## 3. Figma MCP Integration

### Setup

The Figma MCP server exposes design data to Claude Code. Setup in `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--figma-api-key=YOUR_KEY"]
    }
  }
}
```

### Available MCP Tools

| Tool | Purpose | Input | Output |
|---|---|---|---|
| `get_file` | Read Figma file structure | File key | Page/frame hierarchy |
| `get_file_styles` | Extract styles | File key | Colors, text styles, effects |
| `get_file_components` | Extract components | File key | Component properties, variants |
| `get_images` | Export frames as images | Node IDs + format | PNG/SVG exports |
| `get_code` | Get code for a node | Node ID + format | CSS/iOS/Android code snippets |

### Consumption Workflow

```
1. FILE DISCOVERY
   - User provides Figma file URL or key
   - Or: detect from project config (figma.config.json, .figmarc)

2. STRUCTURE EXTRACTION
   get_file -> page hierarchy -> map to screens

3. STYLE EXTRACTION
   get_file_styles -> colors, typography, spacing, effects
   Map to ui-design token schema (design/visual-spec/tokens.md)

4. COMPONENT EXTRACTION
   get_file_components -> component names, variants, properties
   Map to component tree (design/components/component-tree.md)

5. VISUAL REFERENCE
   get_images -> PNG screenshots per frame
   Save to design/wireframes/SCR-XXX-figma.png

6. CODE HINTS
   get_code -> CSS/layout hints per component
   Used by COMP_ARCH for accurate spacing and styling
```

### Figma Output Mapping

| Figma Output | Maps To | ui-design Artifact |
|---|---|---|
| Frame hierarchy | Screen inventory | `design/ux/ux-inventory.md` |
| Styles | Design tokens | `design/visual-spec/tokens.md` |
| Components | Component tree | `design/components/component-tree.md` |
| Frame images | Wireframe reference | `design/wireframes/SCR-XXX-figma.png` |
| Code snippets | Styling hints | Used inline by COMP_ARCH |
| Variables | Theme/mode tokens | `design/visual-spec/tokens.md` (light/dark) |

### When to Use Figma vs Stitch

| Scenario | Use |
|---|---|
| No designs exist, need rapid exploration | **Stitch** |
| Designs already exist in Figma | **Figma MCP** |
| Need design system compliance | **Figma** (has tokens/variables) |
| Quick prototype, speed over polish | **Stitch** |
| Production UI, pixel-perfect needed | **Figma** |
| Both available, greenfield project | **Stitch** (generate) -> **Figma** (refine) |

---

## 4. DESIGN.md Format (Cross-Tool)

DESIGN.md is Stitch's agent-friendly design system format. The ui-design skill can both consume and produce it as a universal handoff format.

### Consuming DESIGN.md

If a DESIGN.md exists in the project root or design/ directory:
```bash
# Check for existing DESIGN.md
[ -f "DESIGN.md" ] && echo "Found DESIGN.md in root"
[ -f "design/DESIGN.md" ] && echo "Found DESIGN.md in design/"
```

Parse it to extract:
- Color palette -> map to token schema
- Typography scale -> map to token schema
- Spacing system -> map to token schema
- Component patterns -> inform COMP_ARCH
- Layout rules -> inform UI_DESIGNER

### Producing DESIGN.md

After all phases complete, produce a DESIGN.md compatible with Stitch import:
```markdown
# DESIGN.md

## Colors
- Primary: #2563EB (blue-600)
- Secondary: #7C3AED (violet-600)
- Error: #DC2626 (red-600)
- Success: #16A34A (green-600)

## Typography
- Heading: Inter, 600 weight
- Body: Inter, 400 weight
- Mono: JetBrains Mono

## Spacing
- Base unit: 4px
- Scale: 4, 8, 12, 16, 24, 32, 48, 64

## Components
- Buttons: rounded-lg, h-10 default, h-8 sm, h-12 lg
- Cards: rounded-xl, shadow-sm, p-6
- Inputs: rounded-md, h-10, border-gray-300

## Layout Rules
- Max content width: 1280px
- Sidebar: 256px fixed
- Mobile-first: 375px base
```

This enables round-tripping between Stitch and the skill — import Stitch's DESIGN.md, refine in the skill, export back.

---

## 5. Fallback: Manual Generation

When no design tools are available, the skill generates all artifacts manually:
- ASCII wireframes (existing Phase 2 workflow)
- Token specs from spec analysis
- Component trees from wireframe analysis
- A11y specs from component analysis

This is the existing workflow documented in the main SKILL.md — no external tools required.

---

## 6. Combined Workflow (Stitch + Figma + Manual)

The recommended production workflow uses all three:

```
PHASE 0: DETECT TOOLS
  Stitch MCP available? -> flag: can_generate
  Figma MCP available?  -> flag: can_extract
  Neither?              -> flag: manual_only

PHASE 1: ANALYSE (always manual — UX_LEAD)
  UX inventory, IA map, screen inventory, flows
  This phase is always manual — AI generation needs human-validated requirements

PHASE 2: GENERATE / IMPORT
  IF can_generate (Stitch):
    Build prompts from UX inventory
    Call Stitch MCP to generate screens
    Export React/Tailwind code + screenshots
    Extract tokens from generated CSS
  ELIF can_extract (Figma):
    Extract file structure, styles, components
    Map to ui-design artifacts
    Export frame images as wireframe reference
  ELSE (manual):
    UI_DESIGNER produces ASCII wireframes
    UI_DESIGNER defines tokens manually from spec

PHASE 3: REFINE (always manual — agents)
  COMP_ARCH: Structure into proper component hierarchy
  A11Y: Audit and annotate accessibility
  COPY: Replace placeholder text with spec copy
  UI_DESIGNER: Validate tokens, spacing, hierarchy

PHASE 4: REVIEW (always manual — A11Y)
  Accessibility review
  Token compliance check
  Component API review

PHASE 5: EXPORT
  Produce all design/ artifacts
  Produce DESIGN.md (for Stitch round-tripping)
  Produce handoff YAML (for spec-to-impl)
```
