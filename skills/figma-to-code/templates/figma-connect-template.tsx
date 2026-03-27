/**
 * Code Connect mapping: <ComponentName>
 * Links Figma component → codebase component
 *
 * Figma component: <figma-component-url>
 * Codebase component: <import-path>
 */

import figma from '@figma/code-connect'
import { <ComponentName> } from './<ComponentName>'

figma.connect(<ComponentName>, '<FIGMA_COMPONENT_URL>', {
  props: {
    // figma.enum maps Figma variant property → TypeScript union
    variant: figma.enum('Variant', {
      'Primary':   'primary',
      'Secondary': 'secondary',
      'Ghost':     'ghost',
    }),

    // figma.boolean maps Figma boolean property → TypeScript boolean
    disabled: figma.boolean('Disabled'),
    loading:  figma.boolean('Loading'),

    // figma.string maps Figma text layer → TypeScript string prop
    label: figma.string('Label'),

    // figma.children maps Figma nested component → React children
    icon: figma.children('Icon'),
  },

  example: ({ variant, disabled, loading, label }) => (
    <ComponentName
      variant={variant}
      disabled={disabled}
      loading={loading}
    >
      {label}
    </ComponentName>
  ),
})
