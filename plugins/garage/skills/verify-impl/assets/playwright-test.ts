// Copy to e2e/verify-impl/<feature>.spec.ts and replace the REPLACE_* values.
// Locators follow references/data-testid-conventions.md: role and label first, test IDs last.

import { test, expect, Page } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';
const API_URL = process.env.API_URL || 'http://localhost:8080';
const TEST_USER = process.env.TEST_USER;
const TEST_PASS = process.env.TEST_PASS;
const SCREENSHOTS = path.join(__dirname, 'screenshots');
fs.mkdirSync(SCREENSHOTS, { recursive: true });

async function screenshot(page: Page, name: string) {
  await page.screenshot({ path: path.join(SCREENSHOTS, `${name}.png`), fullPage: true });
}

async function login(page: Page) {
  if (!TEST_USER || !TEST_PASS) throw new Error('Set TEST_USER and TEST_PASS in the environment');
  await page.goto(`${BASE_URL}/login`);
  await page.getByLabel('REPLACE_USER_LABEL').fill(TEST_USER);
  await page.getByLabel('REPLACE_PASSWORD_LABEL').fill(TEST_PASS);
  await page.getByRole('button', { name: 'REPLACE_SIGN_IN_NAME' }).click();
  await expect(page).not.toHaveURL(/\/login/);
}

test.describe('REPLACE_FEATURE - verify-impl', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('happy path - REPLACE_PRIMARY_FLOW', async ({ page }) => {
    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await expect(page.getByRole('heading', { name: 'REPLACE_HEADING' })).toBeVisible();

    await page.getByLabel('REPLACE_FIELD_LABEL').fill('REPLACE_VALUE');
    await page.getByRole('button', { name: 'REPLACE_SUBMIT_NAME' }).click();

    await expect(page.getByRole('status')).toContainText('REPLACE_SUCCESS_TEXT');
    await screenshot(page, '01-success');
  });

  test('validation - empty form shows required errors', async ({ page }) => {
    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await page.getByRole('button', { name: 'REPLACE_SUBMIT_NAME' }).click();

    await expect(page.getByRole('alert')).toContainText('REPLACE_REQUIRED_MESSAGE');
    await screenshot(page, '02-validation-errors');
  });

  test('error state - API failure shows a recoverable message', async ({ page }) => {
    await page.route(`${API_URL}/api/v1/REPLACE_RESOURCE`, route =>
      route.fulfill({
        status: 500,
        contentType: 'application/problem+json',
        body: JSON.stringify({ type: 'about:blank', title: 'Internal Server Error', status: 500 }),
      })
    );

    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await page.getByLabel('REPLACE_FIELD_LABEL').fill('REPLACE_VALUE');
    await page.getByRole('button', { name: 'REPLACE_SUBMIT_NAME' }).click();

    await expect(page.getByRole('alert')).toBeVisible();
    await screenshot(page, '03-error-state');
  });

  test('loading state - submit is busy or disabled during the call', async ({ page }) => {
    await page.route(`${API_URL}/api/v1/REPLACE_RESOURCE`, async route => {
      await new Promise(r => setTimeout(r, 1000));
      await route.continue();
    });

    await page.goto(`${BASE_URL}/REPLACE_ROUTE`);
    await page.getByLabel('REPLACE_FIELD_LABEL').fill('REPLACE_VALUE');
    const submit = page.getByRole('button', { name: 'REPLACE_SUBMIT_NAME' });
    await submit.click();

    // Double submits create duplicate money operations; the control must block a second click.
    await expect(submit).toBeDisabled();
    await screenshot(page, '04-loading-state');
  });
});
