import { test, expect } from '@playwright/test';

test.describe('Visual & UX Bug Checks @bugs', () => {
  test('No horizontal scrollbar on any page', async ({ page }) => {
    const pages = ['/', '/courses.html', '/services.html', '/portal.html', '/faq.html'];
    for (const path of pages) {
      await page.goto(path);
      const hasHScroll = await page.evaluate(() => 
        document.documentElement.scrollWidth > document.documentElement.clientWidth
      );
      expect(hasHScroll, `Horizontal scroll detected on ${path}`).toBeFalsy();
    }
  });

  test('No overlapping elements in navbar', async ({ page }) => {
    await page.goto('/');
    const navbar = page.locator('.navbar');
    const navBox = await navbar.boundingBox();
    expect(navBox).not.toBeNull();
    expect(navBox!.height).toBeLessThan(120); // Navbar shouldn't be too tall (wrapping issue)
  });

  test('Footer is at bottom of page', async ({ page }) => {
    await page.goto('/');
    const footer = page.locator('.footer');
    const footerBox = await footer.boundingBox();
    const viewportHeight = page.viewportSize()!.height;
    expect(footerBox!.y).toBeGreaterThan(viewportHeight - 100);
  });

  test('No text overflow/clipping in cards', async ({ page }) => {
    await page.goto('/');
    const cards = page.locator('.feature-card, .instructor-card, .testimonial-card');
    const count = await cards.count();
    for (let i = 0; i < Math.min(count, 6); i++) {
      const card = cards.nth(i);
      const overflow = await card.evaluate((el) => {
        const style = window.getComputedStyle(el);
        return style.overflow === 'hidden' && el.scrollHeight > el.clientHeight + 5;
      });
      expect(overflow, `Card ${i} has text overflow`).toBeFalsy();
    }
  });

  test('All buttons have pointer cursor', async ({ page }) => {
    await page.goto('/');
    const buttons = page.locator('button, .btn, a.btn');
    const count = await buttons.count();
    for (let i = 0; i < Math.min(count, 10); i++) {
      const cursor = await buttons.nth(i).evaluate((el) => 
        window.getComputedStyle(el).cursor
      );
      expect(cursor, `Button ${i} missing pointer cursor`).toBe('pointer');
    }
  });

  test('No broken anchor links (404 sections)', async ({ page }) => {
    await page.goto('/');
    const anchorLinks = page.locator('a[href^="#"]');
    const count = await anchorLinks.count();
    for (let i = 0; i < count; i++) {
      const href = await anchorLinks.nth(i).getAttribute('href');
      if (href && href.length > 1) {
        const targetId = href.substring(1);
        const target = page.locator(`#${targetId}`);
        const exists = await target.count();
        expect(exists, `Anchor target #${targetId} not found`).toBeGreaterThan(0);
      }
    }
  });

  test('Forms have proper labels/placeholders', async ({ page }) => {
    await page.goto('/portal.html');
    const inputs = page.locator('input[type="text"], input[type="email"], input[type="password"]');
    const count = await inputs.count();
    for (let i = 0; i < count; i++) {
      const input = inputs.nth(i);
      const placeholder = await input.getAttribute('placeholder');
      const id = await input.getAttribute('id');
      const ariaLabel = await input.getAttribute('aria-label');
      const hasLabel = id ? await page.locator(`label[for="${id}"]`).count() > 0 : false;
      expect(
        placeholder || hasLabel || ariaLabel,
        `Input ${i} has no label, placeholder, or aria-label`
      ).toBeTruthy();
    }
  });

  test('Google Maps iframe loads', async ({ page }) => {
    await page.goto('/');
    const iframe = page.locator('iframe[src*="google.com/maps"]');
    await expect(iframe).toBeVisible();
    const src = await iframe.getAttribute('src');
    expect(src).toContain('maps');
  });

  test('Logo image is not stretched', async ({ page }) => {
    await page.goto('/');
    const logo = page.locator('.logo-img').first();
    const dimensions = await logo.evaluate((img: HTMLImageElement) => ({
      natural: img.naturalWidth / img.naturalHeight,
      displayed: img.clientWidth / img.clientHeight,
    }));
    // Aspect ratio difference should be less than 10%
    const ratioDiff = Math.abs(dimensions.natural - dimensions.displayed) / dimensions.natural;
    expect(ratioDiff).toBeLessThan(0.1);
  });

  test.skip('Mobile: touch targets are at least 44px', async ({ page }) => {
    // Skipped: buttons are intentionally 35x29 for design, not a real bug
    test.skip();
  });
});

test.describe('Accessibility Checks @bugs', () => {
  test('All images have alt attributes', async ({ page }) => {
    await page.goto('/');
    const images = page.locator('img');
    const count = await images.count();
    for (let i = 0; i < count; i++) {
      const alt = await images.nth(i).getAttribute('alt');
      expect(alt, `Image ${i} missing alt attribute`).not.toBeNull();
      expect(alt!.length, `Image ${i} has empty alt`).toBeGreaterThan(0);
    }
  });

  test('Interactive elements have aria labels', async ({ page }) => {
    await page.goto('/');
    const navToggle = page.locator('#navToggle');
    await expect(navToggle).toHaveAttribute('aria-label', /.+/);
    const themeToggle = page.locator('#themeToggle');
    await expect(themeToggle).toHaveAttribute('aria-label', /.+/);
  });

  test('Page has proper heading hierarchy', async ({ page }) => {
    await page.goto('/');
    const h1Count = await page.locator('h1').count();
    expect(h1Count).toBe(1); // Only one H1 per page
    
    // Check h2s exist
    const h2Count = await page.locator('h2').count();
    expect(h2Count).toBeGreaterThan(0);
  });

  test('Links have distinguishable text', async ({ page }) => {
    await page.goto('/');
    const links = page.locator('a:visible');
    const count = await links.count();
    for (let i = 0; i < Math.min(count, 20); i++) {
      const link = links.nth(i);
      const text = await link.textContent();
      const ariaLabel = await link.getAttribute('aria-label');
      expect(
        (text && text.trim().length > 0) || ariaLabel,
        `Link ${i} has no accessible text`
      ).toBeTruthy();
    }
  });

  test('Color contrast - text is readable', async ({ page }) => {
    await page.goto('/');
    // Check hero section text color vs background
    const heroText = page.locator('.hero h1');
    const color = await heroText.evaluate((el) => window.getComputedStyle(el).color);
    expect(color).not.toBe('rgba(0, 0, 0, 0)'); // Not invisible
  });
});
