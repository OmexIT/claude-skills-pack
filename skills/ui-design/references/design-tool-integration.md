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

| Tool | Purpose | Key Parameters |
|---|---|---|
| `create_project` | Create project container | `title` (optional) |
| `get_project` | Get project details + screen instances | `name` (resource name: `projects/{id}`) |
| `list_projects` | List accessible projects | `filter` (`view=owned` or `view=shared`) |
| `create_design_system` | Define design tokens | `projectId`, `designSystem{displayName, theme{colorMode, headlineFont, bodyFont, roundness, customColor, colorVariant, overrides}}` |
| `update_design_system` | Update design tokens (call after create) | `name` (asset resource: `assets/{id}`), `projectId`, `designSystem` |
| `list_design_systems` | List design systems for project | `projectId` |
| `apply_design_system` | Apply tokens to screens | `projectId`, `selectedScreenInstances[{id, sourceScreen}]`, `assetId` |
| `generate_screen_from_text` | Generate screen from prompt (takes minutes) | `projectId`, `prompt`, `deviceType` (MOBILE/DESKTOP/TABLET/AGNOSTIC), `modelId` (GEMINI_3_1_PRO/GEMINI_3_FLASH) |
| `edit_screens` | Edit existing screens with prompt | `projectId`, `selectedScreenIds[]`, `prompt`, `deviceType` |
| `generate_variants` | Generate design variants | `projectId`, `selectedScreenIds[]`, `prompt`, `variantOptions{aspects[], creativeRange, variantCount}` |
| `get_screen` | Get screen details (structure, NOT code/images) | `name` (resource name), `projectId`, `screenId` |
| `list_screens` | List screens in project | `projectId` |

**Important**: Stitch has NO code export and NO image export tools. Screen data is retrieved via `get_screen()` which returns structure, not React/TSX or PNG.

### Generation Workflow

```
1. PROJECT SETUP
   create_project(title="<app name> UI Design")
   -> save projectId for all subsequent calls

2. DESIGN SYSTEM CONFIGURATION
   Map spec design values to Stitch theme enums:
     colorMode:     LIGHT | DARK (from spec or existing theme)
     headlineFont:  nearest match from Stitch enum (INTER, MANROPE, PLUS_JAKARTA_SANS, etc.)
     bodyFont:      nearest match from Stitch font enum
     roundness:     ROUND_FOUR | ROUND_EIGHT | ROUND_TWELVE | ROUND_FULL
     customColor:   primary brand color in hex (e.g. "#2563EB")
     colorVariant:  TONAL_SPOT (default) | VIBRANT | MONOCHROME | NEUTRAL | etc.
     overrides:     overridePrimaryColor, overrideSecondaryColor, overrideTertiaryColor (hex)
     designMd:      optional markdown design instructions

   create_design_system(projectId, designSystem={displayName, theme})
   -> save assetId (design system ID)

   Immediately call update_design_system to apply and display
   (per Stitch API instructions).

3. SCREEN GENERATION (per screen or screen group)
   For each screen in UX inventory:
   generate_screen_from_text(
     projectId,
     prompt="Design a [screen type] for [app name].
       Layout: [from UX inventory]
       Data: [fields from data inventory]
       Actions: [buttons/interactions from spec]
       Style: [from design system config]
       Platform: [web | mobile]",
     deviceType=DESKTOP|MOBILE|TABLET (from --platform flag),
     modelId=GEMINI_3_1_PRO (default) or GEMINI_3_FLASH (for speed)
   )
   -> save screen IDs
   -> handle output_components (may contain suggestions to present to user)

   IMPORTANT: Generation can take several minutes. Do NOT retry on timeout.
   If connection error, check with get_screen later -- generation may succeed.

4. RETRIEVE SCREEN INSTANCES
   get_project(name="projects/{projectId}")
   -> extract screen instances [{id, sourceScreen}] from project details

   list_screens(projectId)
   -> get all screen IDs and resource names

5. APPLY DESIGN SYSTEM for visual consistency
   apply_design_system(
     projectId,
     selectedScreenInstances=[{id: instanceId, sourceScreen: "projects/{p}/screens/{s}"}, ...],
     assetId
   )
   NOTE: Requires screen INSTANCE IDs from get_project, not screen IDs.

6. EXTRACT SCREEN STRUCTURE
   Per screen: get_screen(name="projects/{p}/screens/{s}", projectId, screenId)
   -> write design/stitch-screens/SCR-XXX.md with:
     - Screen name and Stitch resource name
     - Component structure from response
     - Layout description
     - Stitch screen ID for downstream reference

7. DERIVE TOKENS FROM DESIGN SYSTEM CONFIG
   We defined the design system in step 2 -- write design/visual-spec/tokens.md
   from our known config (colorMode, fonts, roundness, colors, overrides).
   No parsing needed -- we know exactly what we configured.

8. OPTIONAL: VARIANT EXPLORATION
   generate_variants(
     projectId, selectedScreenIds,
     prompt="explore alternative layouts",
     variantOptions={aspects: [LAYOUT, COLOR_SCHEME], creativeRange: EXPLORE, variantCount: 3}
   )
   Present variants to user for selection.

9. OPTIONAL: ITERATE WITH EDITS
   edit_screens(projectId, selectedScreenIds, prompt="<refinement>")
   for user-requested design changes.

10. REFINEMENT (by skill agents, not Stitch)
    Stitch provides screen structure and layout. The skill's agents then:
    - COMP_ARCH: Restructures into proper component hierarchy
    - A11Y: Audits and adds accessibility annotations
    - COPY: Replaces placeholder text with spec-accurate copy
    - UI_DESIGNER: Validates spacing, hierarchy, token compliance
```

### Stitch Output Mapping

| Stitch Data | Source | Local Artifact |
|---|---|---|
| Screen structure | `get_screen()` response | `design/stitch-screens/SCR-XXX.md` |
| Design tokens | Our `create_design_system` input (we set them) | `design/visual-spec/tokens.md` |
| Screen IDs + project ID | `create_project` + `generate_screen_from_text` | `claudedocs/handoff-ui-design-*.yaml` (stitch block) |
| Design system asset ID | `create_design_system` response | `claudedocs/handoff-ui-design-*.yaml` (stitch block) |

### Limitations to Handle

- **No code export**: Stitch cannot export React/TSX, HTML, or CSS. The skill writes screen structure descriptions from `get_screen()` to `design/stitch-screens/*.md`. FE agents use these as reference, not starter code.
- **No image export**: Stitch cannot export PNG/SVG screenshots. No visual artifact to save locally. Users view screens in the Stitch web UI using the project ID.
- **Generation time**: `generate_screen_from_text` can take several minutes. Do not retry on timeout — check with `get_screen` later; the generation may still succeed.
- **Screen instance IDs vs screen IDs**: `apply_design_system` requires screen INSTANCE IDs (from `get_project`), not screen IDs from `list_screens`. Always call `get_project` first to get instance mappings.
- **Font enum constraint**: Only ~29 fonts are available (INTER, MANROPE, PLUS_JAKARTA_SANS, GEIST, DM_SANS, etc.). Map from spec fonts to nearest Stitch enum value.
- **Generic output**: Stitch designs tend generic — COMP_ARCH must restructure to match codebase patterns.
- **No state variants**: Stitch generates the happy-path state. UI_DESIGNER must produce empty/loading/error states.
- **No accessibility**: Stitch output lacks ARIA roles, keyboard nav, and screen reader support. A11Y agent is mandatory.
- **Web rendering only**: Stitch renders as web components internally. For Flutter/RN/Angular, use screen structure as reference and generate code manually. However, Stitch supports MOBILE, TABLET, and DESKTOP device types for layout generation.

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
    create_project + create_design_system from spec tokens
    generate_screen_from_text per screen group (with deviceType)
    get_project to retrieve screen instance IDs
    apply_design_system to ensure token consistency
    get_screen per screen -> write design/stitch-screens/*.md
    write tokens.md from our design system config (we know them — we set them)
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
  Produce DESIGN.md (portable design system spec for other tools)
  Produce handoff YAML with Stitch project/screen IDs (for spec-to-impl)
```
