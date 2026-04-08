// @ts-check
import { test, expect } from '@playwright/test';

const DEFAULT_BASE_URL = 'http://127.0.0.1:8000';
const DEMO_BASE = '/blast/js_stress_example';

/**
 * Hierarchical destruction demo pages that should load without errors.
 * Each demo uses buildHierarchicalFragments + buildDestructibleCore and
 * falls back to flat solver when WASM hierarchy functions are unavailable.
 */
const HIERARCHICAL_DEMOS = [
  { name: 'hierarchical-wall', path: `${DEMO_BASE}/hierarchical-wall.html` },
  { name: 'hierarchical-tower', path: `${DEMO_BASE}/hierarchical-tower.html` },
  { name: 'hierarchical-bridge', path: `${DEMO_BASE}/hierarchical-bridge.html` },
];

function makeConsoleListeners(page) {
  const logs = { errors: [], warns: [], info: [] };
  page.on('console', (message) => {
    const text = message.text();
    if (message.type() === 'error') {
      logs.errors.push(text);
      // eslint-disable-next-line no-console
      console.error(`[browser][error] ${text}`);
    } else if (message.type() === 'warning') {
      logs.warns.push(text);
      // eslint-disable-next-line no-console
      console.log(`[browser][warn] ${text}`);
    } else if (message.type() === 'log') {
      logs.info.push(text);
      // eslint-disable-next-line no-console
      console.log(`[browser][log] ${text}`);
    }
  });
  return logs;
}

test.describe('hierarchical destruction demos', () => {
  for (const demo of HIERARCHICAL_DEMOS) {
    test(`${demo.name} loads without errors`, async ({ page }, testInfo) => {
      const baseUrl = process.env.BRIDGE_BASE_URL ?? DEFAULT_BASE_URL;
      const url = new URL(demo.path, baseUrl).toString();

      const consoleLogs = makeConsoleListeners(page);

      page.on('pageerror', (err) => {
        const msg = `PageError: ${err?.message ?? err}`;
        consoleLogs.errors.push(msg);
        // eslint-disable-next-line no-console
        console.error(`[pageerror] ${msg}`);
      });
      page.on('requestfailed', (req) => {
        const failure = req.failure();
        // eslint-disable-next-line no-console
        console.error(`[requestfailed] ${req.url()} ${failure?.errorText ?? ''}`);
      });

      await page.goto(url, { waitUntil: 'domcontentloaded' });

      // Wait for the demo to initialize (sets window.__demoReady = true)
      try {
        await page.waitForFunction(
          () => (globalThis).__demoReady === true,
          { timeout: 60_000 },
        );
      } catch (e) {
        // Grab diagnostic info on timeout
        const snapshot = await page.evaluate(() => ({
          title: document.title,
          href: location.href,
          ready: (globalThis).__demoReady ?? false,
          hintText: document.querySelector('.viewport-hint')?.textContent ?? '',
        }));
        // eslint-disable-next-line no-console
        console.error(`[diagnostic] waitForFunction timeout, snapshot: ${JSON.stringify(snapshot, null, 2)}`);
        throw e;
      }

      // Verify no viewport-hint error text
      const hintText = await page.$eval('.viewport-hint', (el) => el.textContent ?? '');
      expect(hintText).not.toContain('Error:');

      // Filter out expected warnings (flat solver fallback is OK)
      const fatalErrors = consoleLogs.errors.filter(
        (msg) => !msg.includes('Hierarchical solver not available'),
      );

      if (testInfo.attachments) {
        await testInfo.attach(`${demo.name}-console.json`, {
          body: JSON.stringify({ consoleLogs, hintText }, null, 2),
          contentType: 'application/json',
        });
      }

      expect(fatalErrors, fatalErrors.join('\n')).toHaveLength(0);
    });
  }
});
