// Copy to e2e/verify-impl/test-plan.spec.ts. Generates one test per `ui` flow in e2e/test-plan.yaml.
// Adapt the three LOGIN_* names to the app's real login form.

import { test, expect, Page, Locator } from '@playwright/test';
import * as yaml from 'js-yaml';
import * as fs from 'fs';
import * as path from 'path';

const plan = yaml.load(fs.readFileSync('e2e/test-plan.yaml', 'utf8')) as any;
const BASE = process.env.BASE_URL ?? plan.environment.frontend_url;
const USER = process.env.TEST_USER;
const PASS = process.env.TEST_PASS;
const ONLY = (process.env.TC ?? '').split(/[\s,]+/).filter(Boolean); // optional --tc filter
const SHOTS = path.join(__dirname, 'screenshots');
fs.mkdirSync(SHOTS, { recursive: true });

const LOGIN_USER_LABEL = 'Email';
const LOGIN_PASS_LABEL = 'Password';
const LOGIN_SUBMIT_NAME = 'Sign in';

// Values captured by the API layer, keyed by test case ID.
const captures: Record<string, Record<string, string>> = (() => {
  try { return JSON.parse(fs.readFileSync('e2e/.captures.json', 'utf8')); } catch { return {}; }
})();

const resolveVar = (val: string, tcId: string) =>
  val.replace(/\{(\w+)\}/g, (match, k) => captures[tcId]?.[k] ?? match);

// Plan selectors: role:<role>:<name>, label:<text>, text:<text>, testid:<id>, else CSS (legacy).
function locate(page: Page, selector: string): Locator {
  const [kind, ...rest] = selector.split(':');
  switch (kind) {
    case 'role': {
      const [role, ...name] = rest;
      return page.getByRole(role as any, name.length ? { name: name.join(':') } : {});
    }
    case 'label': return page.getByLabel(rest.join(':'));
    case 'text': return page.getByText(rest.join(':'));
    case 'testid': return page.getByTestId(rest.join(':'));
    default: return page.locator(selector);
  }
}

async function login(page: Page) {
  if (!USER || !PASS) throw new Error('Set TEST_USER and TEST_PASS in the environment');
  await page.goto(`${BASE}/login`);
  await page.getByLabel(LOGIN_USER_LABEL).fill(USER);
  await page.getByLabel(LOGIN_PASS_LABEL).fill(PASS);
  await page.getByRole('button', { name: LOGIN_SUBMIT_NAME }).click();
  await expect(page).not.toHaveURL(/\/login/);
}

for (const tc of plan.test_cases) {
  if (!tc.ui || (ONLY.length && !ONLY.includes(tc.id))) continue;

  for (const flow of tc.ui) {
    test(`${tc.id} [${tc.priority}] ${tc.title} - ${flow.flow}`, async ({ page }) => {
      await login(page);

      for (const step of flow.steps) {
        const val = step.value ? resolveVar(step.value, tc.id) : undefined;
        const target = step.selector ? locate(page, resolveVar(step.selector, tc.id)) : undefined;

        switch (step.action) {
          case 'goto': await page.goto(`${BASE}${resolveVar(step.url, tc.id)}`); break;
          case 'fill': await target!.fill(val!); break;
          case 'click': await target!.click(); break;
          case 'select': await target!.selectOption(val!); break;
          case 'assert_visible':
            await expect(target!).toBeVisible({ timeout: step.timeout_ms ?? 5000 }); break;
          case 'assert_text': await expect(target!).toContainText(step.contains); break;
          case 'assert_url': await expect(page).toHaveURL(new RegExp(step.pattern)); break;
          case 'screenshot':
            await page.screenshot({ path: path.join(SHOTS, `${step.name}.png`), fullPage: true }); break;
          default: throw new Error(`Unknown action ${step.action} in ${tc.id}`);
        }
      }
    });
  }
}
