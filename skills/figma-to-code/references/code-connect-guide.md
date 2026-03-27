# Code Connect Guide

Code Connect links Figma components to their codebase implementations. When a developer selects a component in Figma, they see the actual code snippet instead of auto-generated CSS.

## Setup

```bash
npm install --save-dev @figma/code-connect
```

## Creating Mappings

Generate a mapping file for a Figma component:

```bash
npx @figma/code-connect create --figma-url "https://figma.com/design/YOUR_FILE_ID/" --dir src/components
```

This creates a `.figma.tsx` file next to each matched component.

## Mapping Syntax

### Enum Props (Figma variant → TypeScript union)

```tsx
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

### Prop Type Mapping

| Figma Property Type | Code Connect Function | TypeScript Result |
|---|---|---|
| Variant (enum) | `figma.enum('PropName', mapping)` | String union |
| Boolean | `figma.boolean('PropName')` | `boolean` |
| Text layer | `figma.string('LayerName')` | `string` |
| Nested instance | `figma.children('SlotName')` | `ReactNode` |
| Instance swap | `figma.instance('SwapName')` | `ReactNode` |

### Conditional Rendering

```tsx
figma.connect(Alert, 'URL', {
  props: {
    hasIcon: figma.boolean('Show Icon'),
    icon: figma.children('Icon'),
    title: figma.string('Title'),
    description: figma.string('Description'),
  },
  example: ({ hasIcon, icon, title, description }) => (
    <Alert>
      {hasIcon && <AlertIcon>{icon}</AlertIcon>}
      <AlertTitle>{title}</AlertTitle>
      <AlertDescription>{description}</AlertDescription>
    </Alert>
  ),
})
```

## Publishing

Push mappings to Figma so developers see code snippets in the Inspect panel:

```bash
npx @figma/code-connect publish
```

To validate without publishing:

```bash
npx @figma/code-connect publish --dry-run
```

## Workflow Integration

1. **Build components** — Generate from Figma using `/figma-to-code`
2. **Create mappings** — Write `.figma.tsx` files for each component
3. **Publish** — Push to Figma with `code-connect publish`
4. **Maintain** — Re-publish when component API changes

## File Naming Convention

```
src/components/
├── Button/
│   ├── Button.tsx              # Component implementation
│   ├── Button.figma.tsx        # Code Connect mapping
│   ├── Button.test.tsx         # Tests
│   └── index.ts                # Barrel export
```

## Troubleshooting

| Issue | Fix |
|---|---|
| "Component not found" | Verify the Figma URL points to a component, not an instance |
| Props not mapping | Check variant property names match exactly (case-sensitive) |
| Publish fails | Run `--dry-run` first; ensure `FIGMA_ACCESS_TOKEN` env var is set |
| Stale snippets in Figma | Re-run `publish` after code changes |
