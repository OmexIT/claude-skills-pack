# Accessibility Standards Reference

## WCAG AA Requirements (minimum for all products)

### Color Contrast
- Normal text (< 18px): minimum **4.5:1** ratio
- Large text (>= 18px or 14px bold): minimum **3:1** ratio
- UI components and graphics: minimum **3:1** ratio
- Placeholder text: minimum **4.5:1** ratio (don't rely on placeholder for critical info)

### Keyboard Accessibility
- All interactive elements must be reachable via **Tab** key
- Focus order must match visual reading order (left-to-right, top-to-bottom)
- Focus indicator must be clearly visible: `outline: 2px solid`, `offset: 2px` minimum
- Modal dialogs must **trap focus** inside while open
- **Escape** key closes modals, dropdowns, tooltips
- **Arrow keys** navigate within components (menus, tabs, radio groups)
- **Enter/Space** activates buttons and links
- Skip navigation link as first focusable element on the page

### Touch Targets
- Minimum **44x44px** for all interactive elements on mobile
- Minimum **8px** spacing between adjacent touch targets
- Never place two small tap targets next to each other without spacing

### Screen Readers
- All images need `alt` text (empty `""` if decorative)
- Form inputs need associated `<label>` (not just placeholder)
- Error messages linked to inputs via `aria-describedby`
- Dynamic content updates use `aria-live="polite"` (or `"assertive"` for critical)
- Buttons that open modals: `aria-haspopup="dialog"`
- Current page in nav: `aria-current="page"`
- Loading states: `aria-busy="true"` on the region loading
- Icon-only buttons must have `aria-label`
- Decorative icons use `aria-hidden="true"`

### Focus Management
- When a modal opens: focus moves to first focusable element inside
- When a modal closes: focus returns to the element that triggered it
- When content is dynamically added: announce via `aria-live`
- When a page loads after navigation: focus moves to main content or `<h1>`

---

## WCAG AAA (target for key flows)

- Contrast ratio **7:1** for normal text
- No time limits, or easily extendable
- No flashing content (< 3 flashes per second)
- Multiple ways to navigate (search, sitemap, nav)
- Section headings to organize content

---

## Contrast Checking Quick Reference

| Background | Foreground | Ratio | WCAG AA | WCAG AAA |
|---|---|---|---|---|
| #FFFFFF | #000000 | 21:1 | PASS | PASS |
| #FFFFFF | #767676 | 4.54:1 | PASS | FAIL |
| #FFFFFF | #959595 | 2.85:1 | FAIL | FAIL |
| #1A1A1A | #F5F5F5 | 17.4:1 | PASS | PASS |
| #1A1A1A | #A3A3A3 | 7.1:1 | PASS | PASS |
| #1A1A1A | #737373 | 4.2:1 | FAIL | FAIL |

---

## Common Accessibility Mistakes

1. **Using color alone** to indicate state (error = red, success = green) without icons or text
2. **Placeholder as label** — screen readers may not announce placeholder text
3. **Custom components** that don't implement keyboard handling (custom dropdown, custom checkbox)
4. **Infinite scroll** without a "Load more" fallback for keyboard users
5. **Auto-playing video/audio** without pause controls
6. **Low contrast text** on decorative backgrounds or images
7. **Disabled buttons** without explanation of why they're disabled
8. **Tooltip-only information** — inaccessible to touch users
