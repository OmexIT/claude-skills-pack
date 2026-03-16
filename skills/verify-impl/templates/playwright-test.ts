// playwright-test.template.ts
// Copy to e2e/verify-impl/<feature>.spec.ts and replace PLACEHOLDER values

import { test, expect, Page } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

// ── Config ───────────────────────────────────────────────────────────────────

const BASE_URL  = process.env.BASE_URL  || 'http://localhost:3000';
const API_URL   = process.env.API_URL   || 'http://localhost:8080';
const TEST_USER = process.env.TEST_USER || 'test@example.com';
const TEST_PASS = process.env.TEST_PASS || 'testpass123';
const SCREENSHOTS = path.join(__dirname, 'screenshots');

// Ensure screenshots dir exists
if (!fs.existsSync(SCREENSHOTS)) fs.mkdirSync(SCREENSHOTS, { recursive: true });

// ── Helpers ──────────────────────────────────────────────────────────────────

async function screenshot(page: Page, name: string) {
  const file = path.join(SCREENSHOTS, `${name}.png`);
  await page.screenshot({ path: file, fullPage: true });
  console.log(`  📸 Screenshot: ${file}`);
}

async function login(page: Page) {
  await page.goto(`${BASE_URL}/login`);
  await page.fill('[data-testid="email"]',    TEST_USER);
  await page.fill('[data-testid="password"]', TEST_PASS);
  await page.click('[data-testid="login-btn"]');
  await expect(page).toHaveURL(/dashboard|home/, { timeout: 5000 });
  await screenshot(page, '00-logged-in');
}

// ── Setup ─────────────────────────────────────────────────────────────────────

test.describe('REPLACE_FEATURE — verify-impl', () => {

  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  // ── Happy Path ─────────────────────────────────────────────────────────────

  test('happy path — REPLACE_PRIMARY_FLOW', async ({ page }) => {
    // Navigate to the feature
    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await expect(page).toHaveTitle(/REPLACE_EXPECTED_TITLE/);
    await screenshot(page, '01-page-loaded');

    // Fill the form / interact with the UI
    await page.fill('[data-testid="REPLACE_FIELD_1"]', 'REPLACE_VALUE_1');
    await page.fill('[data-testid="REPLACE_FIELD_2"]', 'REPLACE_VALUE_2');
    await screenshot(page, '02-form-filled');

    // Submit
    await page.click('[data-testid="submit-btn"]');

    // Assert success feedback
    await expect(
      page.locator('[data-testid="success-message"]')
    ).toBeVisible({ timeout: 5000 });

    await expect(
      page.locator('[data-testid="success-message"]')
    ).toContainText('REPLACE_SUCCESS_TEXT');

    await screenshot(page, '03-success');
  });

  // ── Validation ─────────────────────────────────────────────────────────────

  test('validation — empty form shows required errors', async ({ page }) => {
    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);

    // Submit without filling anything
    await page.click('[data-testid="submit-btn"]');

    // Assert error messages appear
    await expect(
      page.locator('[data-testid="REPLACE_FIELD_1-error"]')
    ).toBeVisible();

    await screenshot(page, '04-validation-errors');
  });

  // ── Error State ────────────────────────────────────────────────────────────

  test('error state — API failure shows user-friendly message', async ({ page }) => {
    // Intercept API to simulate failure
    await page.route(`${API_URL}/api/v1/REPLACE_RESOURCE`, route =>
      route.fulfill({ status: 500, body: JSON.stringify({ error: 'Internal error' }) })
    );

    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await page.fill('[data-testid="REPLACE_FIELD_1"]', 'REPLACE_VALUE_1');
    await page.click('[data-testid="submit-btn"]');

    // Should show error, NOT a blank screen or crash
    await expect(
      page.locator('[data-testid="error-message"]')
    ).toBeVisible({ timeout: 3000 });

    await screenshot(page, '05-error-state');
  });

  // ── Loading State ──────────────────────────────────────────────────────────

  test('loading state — spinner shown during API call', async ({ page }) => {
    // Slow down the API response to catch the loading state
    await page.route(`${API_URL}/api/v1/REPLACE_RESOURCE`, async route => {
      await new Promise(r => setTimeout(r, 1000));
      await route.continue();
    });

    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await page.fill('[data-testid="REPLACE_FIELD_1"]', 'REPLACE_VALUE_1');
    await page.click('[data-testid="submit-btn"]');

    // Loading indicator should appear
    await expect(
      page.locator('[data-testid="loading-spinner"]')
    ).toBeVisible({ timeout: 500 });

    await screenshot(page, '06-loading-state');
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  test('navigation — breadcrumb and back button work', async ({ page }) => {
    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);

    // Breadcrumb visible
    await expect(page.locator('[data-testid="breadcrumb"]')).toBeVisible();

    // Back navigates correctly
    await page.click('[data-testid="back-btn"]');
    await expect(page).toHaveURL(/REPLACE_PARENT_ROUTE/);
  });

  // ── Add more test cases derived from spec FRs below ───────────────────────

});
