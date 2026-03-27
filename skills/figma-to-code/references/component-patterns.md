# Component Patterns Reference

Production-ready TypeScript component implementations for common Figma patterns.

---

## 1. Card Component

```tsx
import { cn } from '@/lib/utils'
import { type ReactNode } from 'react'

export interface CardProps {
  variant?: 'default' | 'elevated' | 'outlined'
  padding?: 'sm' | 'md' | 'lg'
  className?: string
  children: ReactNode
}

const variantStyles = {
  default:  'bg-white dark:bg-gray-900',
  elevated: 'bg-white dark:bg-gray-900 shadow-md',
  outlined: 'bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700',
} as const

const paddingStyles = {
  sm: 'p-3',
  md: 'p-4',
  lg: 'p-6',
} as const

export function Card({
  variant = 'default',
  padding = 'md',
  className,
  children,
}: CardProps) {
  return (
    <div
      className={cn(
        'rounded-lg',
        variantStyles[variant],
        paddingStyles[padding],
        className
      )}
    >
      {children}
    </div>
  )
}

Card.displayName = 'Card'
```

---

## 2. Badge / Pill Component

```tsx
import { cn } from '@/lib/utils'
import { type ReactNode } from 'react'

export interface BadgeProps {
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'live'
  className?: string
  children: ReactNode
}

const variantStyles = {
  default: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200',
  success: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
  warning: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
  danger:  'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
  info:    'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
  live:    'bg-red-600 text-white animate-pulse',
} as const

export function Badge({
  variant = 'default',
  className,
  children,
}: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
        variantStyles[variant],
        className
      )}
    >
      {children}
    </span>
  )
}

Badge.displayName = 'Badge'
```

---

## 3. OddsCard Component (iGaming)

```tsx
import { cn } from '@/lib/utils'
import { Badge } from '../Badge/Badge'

export interface OddsCardProps {
  homeTeam: string
  awayTeam: string
  odds: {
    home: number
    draw?: number
    away: number
  }
  isLive: boolean
  startTime: string
  sport: string
  onSelect: (selection: 'home' | 'draw' | 'away', odds: number) => void
  className?: string
}

export function OddsCard({
  homeTeam,
  awayTeam,
  odds,
  isLive,
  startTime,
  sport,
  onSelect,
  className,
}: OddsCardProps) {
  return (
    <div
      className={cn(
        'rounded-lg border border-gray-200 bg-white p-4 dark:border-gray-700 dark:bg-gray-900',
        className
      )}
    >
      <div className="mb-3 flex items-center justify-between">
        <span className="text-xs text-gray-500">{sport}</span>
        {isLive ? (
          <Badge variant="live">LIVE</Badge>
        ) : (
          <span className="text-xs text-gray-400">{startTime}</span>
        )}
      </div>

      <div className="mb-3 flex flex-col gap-1">
        <span className="text-sm font-medium">{homeTeam}</span>
        <span className="text-sm font-medium">{awayTeam}</span>
      </div>

      <div className={cn('grid gap-2', odds.draw !== undefined ? 'grid-cols-3' : 'grid-cols-2')}>
        <OddsButton label="1" value={odds.home} onClick={() => onSelect('home', odds.home)} />
        {odds.draw !== undefined && (
          <OddsButton label="X" value={odds.draw} onClick={() => onSelect('draw', odds.draw!)} />
        )}
        <OddsButton label="2" value={odds.away} onClick={() => onSelect('away', odds.away)} />
      </div>
    </div>
  )
}

OddsCard.displayName = 'OddsCard'
```

---

## 4. OddsButton Sub-Component

```tsx
import { cn } from '@/lib/utils'

export interface OddsButtonProps {
  label: '1' | 'X' | '2'
  value: number
  selected?: boolean
  onClick: () => void
}

export function OddsButton({ label, value, selected = false, onClick }: OddsButtonProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={`${label}: odds ${value.toFixed(2)}`}
      aria-pressed={selected}
      className={cn(
        'flex flex-col items-center rounded-md border px-3 py-2 text-sm transition-colors',
        'hover:border-blue-500 hover:bg-blue-50 dark:hover:bg-blue-950',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500',
        selected
          ? 'border-blue-500 bg-blue-50 text-blue-700 dark:bg-blue-950 dark:text-blue-300'
          : 'border-gray-200 bg-gray-50 dark:border-gray-700 dark:bg-gray-800'
      )}
    >
      <span className="text-xs text-gray-500">{label}</span>
      <span className="font-semibold">{value.toFixed(2)}</span>
    </button>
  )
}

OddsButton.displayName = 'OddsButton'
```

---

## 5. FormField Wrapper

```tsx
import { cn } from '@/lib/utils'
import { type ReactElement, cloneElement, useId } from 'react'

export interface FormFieldProps {
  label: string
  error?: string
  hint?: string
  required?: boolean
  className?: string
  children: ReactElement
}

export function FormField({
  label,
  error,
  hint,
  required = false,
  className,
  children,
}: FormFieldProps) {
  const id = useId()
  const errorId = `${id}-error`
  const hintId = `${id}-hint`

  const describedBy = [
    error ? errorId : undefined,
    hint ? hintId : undefined,
  ].filter(Boolean).join(' ') || undefined

  return (
    <div className={cn('flex flex-col gap-1.5', className)}>
      <label htmlFor={id} className="text-sm font-medium text-gray-700 dark:text-gray-300">
        {label}
        {required && <span className="ml-0.5 text-red-500" aria-hidden="true">*</span>}
      </label>

      {cloneElement(children, {
        id,
        'aria-describedby': describedBy,
        'aria-invalid': error ? true : undefined,
        'aria-required': required ? true : undefined,
      })}

      {hint && !error && (
        <p id={hintId} className="text-xs text-gray-500">{hint}</p>
      )}
      {error && (
        <p id={errorId} className="text-xs text-red-600 dark:text-red-400" role="alert">{error}</p>
      )}
    </div>
  )
}

FormField.displayName = 'FormField'
```

---

## 6. Figma Auto-Layout → Tailwind Mapping

| Figma Auto-Layout Property | Tailwind Equivalent |
|---|---|
| Horizontal direction | `flex flex-row` |
| Vertical direction | `flex flex-col` |
| Wrap | `flex-wrap` |
| Space between (primary) | `justify-between` |
| Space between (counter) | `items-stretch` or explicit |
| Packed (start) | `justify-start items-start` |
| Packed (center) | `justify-center items-center` |
| Packed (end) | `justify-end items-end` |
| Gap 4px | `gap-1` |
| Gap 8px | `gap-2` |
| Gap 12px | `gap-3` |
| Gap 16px | `gap-4` |
| Gap 20px | `gap-5` |
| Gap 24px | `gap-6` |
| Gap 32px | `gap-8` |
| Gap 40px | `gap-10` |
| Gap 48px | `gap-12` |
| Padding 4px | `p-1` |
| Padding 8px | `p-2` |
| Padding 12px | `p-3` |
| Padding 16px | `p-4` |
| Padding 20px | `p-5` |
| Padding 24px | `p-6` |
| Padding 32px | `p-8` |
| Individual padding | `pt-X pr-X pb-X pl-X` |
| Fill container | `flex-1` or `w-full` |
| Hug contents | `w-fit` |
| Fixed width | `w-[Xpx]` |
| No Tailwind match | `[Xpx]` arbitrary value |

---

## 7. Responsive Breakpoint Mapping

| Figma Frame Width | Tailwind Breakpoint | Prefix |
|---|---|---|
| 375px | Mobile (default) | (none) |
| 768px | Tablet | `md:` |
| 1024px | Small desktop | `lg:` |
| 1280px | Desktop | `xl:` |
| 1440px | Large desktop | `2xl:` |

Mobile-first approach: design at 375px first (no prefix), then add `md:`, `lg:`, etc. for larger screens.

When Figma has frames at multiple widths, generate responsive Tailwind:
```tsx
<div className="flex flex-col gap-4 md:flex-row md:gap-6 lg:gap-8">
  {/* stacks vertically on mobile, horizontally on tablet+ */}
</div>
```
