# UI layer (Playwright)

Execute every `ui` block selected from the test plan in a real browser against the running app,
with screenshots as evidence.

## Setup

The repo must already declare `@playwright/test`; add it only when the requested scope includes test
setup. Install browsers with `scripts/playwright-setup.sh`; pass `--with-deps` only when the user
approves OS package installation. Confirm the frontend answers before running.

## Locators

Follow `references/data-testid-conventions.md`: role plus accessible name first, then label, then
visible text, and a test ID only as a justified fallback. Plan `selector` strings stay strings; the
generated spec maps these prefixes to Playwright's user-facing locators:

| Plan selector | Playwright call |
|---|---|
| `role:button:Create link` | `getByRole('button', { name: 'Create link' })` |
| `label:Amount` | `getByLabel('Amount')` |
| `text:Link created` | `getByText('Link created')` |
| `testid:live-match-momentum-canvas` | `getByTestId('live-match-momentum-canvas')` |
| anything else | `page.locator(selector)` (legacy CSS, flag it in the report) |

When a role or label cannot find an interactive control, report the control as an accessibility
defect before reaching for a test ID.

## Generate and run

Copy `assets/test-plan-spec.ts` to `e2e/verify-impl/test-plan.spec.ts`. It turns each plan `ui`
flow into one test, logs in with `TEST_USER`/`TEST_PASS` from the environment, resolves `{var}`
placeholders from `e2e/.captures.json`, and writes screenshots to `e2e/verify-impl/screenshots/`.
It needs `js-yaml` as a dev dependency; add it only if missing and the scope includes test setup.
For a `--tc` run, set `TC="TC-001 TC-003"` so only those test cases generate tests.
For a repo without a test plan, adapt `assets/playwright-test.ts` instead.

```bash
npx playwright test e2e/verify-impl/test-plan.spec.ts --reporter=list --retries=1
npx playwright test e2e/verify-impl/test-plan.spec.ts --reporter=list --trace on   # on failure
```

A test that passes only on retry is flaky: report it as a finding, not a pass.

## Responsive check

When the change touches layout, also run the changed flow at a phone viewport (for example
390x844) through Playwright's device emulation or the Chrome DevTools MCP, and screenshot it.

## Design intent (optional)

When a `claudedocs/handoff-ui-design-*.yaml` handoff has a `stitch` block, fetch the screen with
`get_screen(name, projectId, screenId)` to read the intended structure while investigating a UI
failure. It is context, not evidence: a design-tool image never proves the running app works.

## Result skeleton

```
UI (Playwright, Chromium) - base <url>, <n> flows, <passed> passed, <failed> failed
TC-002 [P0] <title>
  PASS  happy_path  link generated and displayed   2.1s
  FAIL  edge_case   duplicate warning not visible within 5000ms
        Screenshot: e2e/verify-impl/screenshots/tc002-edge-case-failure.png
```
