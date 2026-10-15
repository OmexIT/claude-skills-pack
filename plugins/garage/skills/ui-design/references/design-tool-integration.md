# Design tool integration

Read when Phase 1.5 runs (a Stitch or Figma MCP server is available, a `DESIGN.md` exists, or the
user passed `--stitch`, `--figma`, or `--design-md`). Tools generate or import; the skill's roles
then refine. Tool names and endpoints change: use the tools the session actually lists, and treat
the names below as a guide.

## Detection order

1. Stitch MCP tools present (`generate_screen_from_text`, `create_project`): can generate.
2. Figma MCP tools present (official server: `get_metadata`, `get_design_context`): can extract.
3. `DESIGN.md` or `design/DESIGN.md` exists: import as the design-system base.
4. Otherwise manual: ASCII wireframes and token specs from the spec.

| Scenario | Use |
|---|---|
| No designs yet, need fast exploration | Stitch |
| Designs already exist in Figma, or pixel accuracy matters | Figma |
| Both available on a greenfield project | Stitch to explore, Figma to refine |

## Stitch MCP

Setup (confirm the current endpoint in Stitch's docs). Claude Code:
`claude mcp add --transport sse stitch https://stitch.googleapis.com/v1/mcp/sse --header "x-goog-api-key: $STITCH_API_KEY"`.
Codex, in `~/.codex/config.toml`:

```toml
[mcp_servers.stitch]
url = "https://stitch.googleapis.com/v1/mcp/sse"
env_http_headers = { "x-goog-api-key" = "STITCH_API_KEY" }
```

| Tool | Purpose | Key parameters |
|---|---|---|
| `create_project` / `get_project` / `list_projects` | Project container; `get_project` returns screen instances | `title`; `name` = `projects/{id}` |
| `create_design_system` / `update_design_system` / `list_design_systems` | Theme tokens | `projectId`, `designSystem{displayName, theme{colorMode, headlineFont, bodyFont, roundness, customColor, colorVariant, overrides}}` |
| `apply_design_system` | Apply theme to screens | `projectId`, `selectedScreenInstances[{id, sourceScreen}]`, `assetId` |
| `generate_screen_from_text` | Generate a screen (takes minutes) | `projectId`, `prompt`, `deviceType` (MOBILE, DESKTOP, TABLET, AGNOSTIC), `modelId` |
| `edit_screens` / `generate_variants` | Refine or explore | `selectedScreenIds[]`, `prompt`, `variantOptions{aspects[], creativeRange, variantCount}` |
| `get_screen` / `list_screens` | Screen structure (not code, not images) | `name`, `projectId`, `screenId` |

Workflow:

1. `create_project(title)`; keep `projectId`.
2. Map spec or existing tokens to the theme: `colorMode` LIGHT or DARK, nearest font enums,
   `roundness` (ROUND_FOUR, ROUND_EIGHT, ROUND_TWELVE, ROUND_FULL), `customColor` hex,
   `colorVariant` (default TONAL_SPOT), optional primary/secondary/tertiary overrides.
   `create_design_system`, keep `assetId`, then call `update_design_system` to apply it.
3. Per screen or screen group: `generate_screen_from_text` with a prompt built from the UX
   inventory (layout, data fields, actions, style, platform). `deviceType`: MOBILE for Flutter,
   React Native, or `--mobile-first`; otherwise DESKTOP (TABLET when the spec targets it). Do not retry on timeout or connection error; check with `get_screen` later.
   Present any suggestions in `output_components` to the user.
4. `get_project` for screen instance IDs (`apply_design_system` needs instance IDs, not the screen
   IDs from `list_screens`), then `apply_design_system`.
5. Per screen, `get_screen` and write `design/stitch-screens/SCR-XXX.md`: screen name, resource
   name, component structure, layout, Stitch screen ID.
6. Write `design/visual-spec/tokens.md` from the theme you configured in step 2.
7. Optional: `generate_variants` (aspects LAYOUT, COLOR_SCHEME) or `edit_screens`, user picks.

Limits the skill's roles must cover: no code or image export (downstream uses screen IDs as
reference, never as scaffolding), happy-path state only (UI_DESIGNER adds empty, loading, error),
no accessibility (A11Y is mandatory), generic structure (COMP_ARCH restructures to codebase
patterns), a limited font enum, and web rendering only (Flutter and React Native use the structure
as reference).

## Figma MCP

Prefer the official Figma MCP server (Figma plugin, or the remote server per Figma's docs).
Community servers expose the same capabilities under different tool names.

| Capability | Official tool | Writes to |
|---|---|---|
| Page and frame structure | `get_metadata` | `design/ux/ux-inventory.md` |
| Variables and styles (incl. light and dark modes) | `get_variable_defs` | `design/visual-spec/tokens.md` |
| Component structure and code hints for a node | `get_design_context` | `design/components/component-tree.md`, COMP_ARCH input |
| Existing library components | `search_design_system` | reuse list in component specs |
| Frame image | `get_screenshot` | `design/wireframes/SCR-XXX-figma.png` |

Get the file key and node IDs from the URL the user gives (`node-id=1-2` becomes `1:2`). Treat
generated code hints as a reference to adapt to the project's components and tokens.

## DESIGN.md (cross-tool format)

Import: read `DESIGN.md` from the root or `design/`, map colors, type, spacing, component patterns,
and layout rules into the token schema, and pass them to UI_DESIGNER and COMP_ARCH as constraints.

Export (at the end of a full run): write `design/DESIGN.md` so Stitch and other tools can import it.

```markdown
# DESIGN.md
## Colors       Primary, Secondary, Error, Success with hex and token name
## Typography   Heading, Body, Mono families and weights
## Spacing      Base unit and scale
## Components   Buttons, Cards, Inputs: radius, heights, padding
## Layout       Max content width, sidebar width, mobile base width
```
