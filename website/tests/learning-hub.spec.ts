import { readFileSync } from "node:fs";
import { expect, test } from "@playwright/test";

type Entry = { id: string; kind: string; name: string; category: string };
const { entries } = JSON.parse(readFileSync(new URL("../public/layouts.json", import.meta.url), "utf8")) as { entries: Entry[] };
const layouts = entries.filter((entry) => entry.kind === "layout");

test("catalogue, deep links, dialog, copy, and responsive layout", async ({ page }, testInfo) => {
  const failedResponses: string[] = [];
  page.on("response", (response) => {
    if (response.status() >= 400) failedResponses.push(`${response.status()} ${response.url()}`);
  });

  await page.goto("/wise-presentations/");
  await expect(page).toHaveTitle("wise-presentations | Fiskwise");
  await expect(page.getByRole("heading", { level: 1 })).toHaveText("Match each scientific claim with an appropriate slide layout.");
  await expect(page.getByRole("img", { name: "Fiskwise" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Fiskwise", exact: true })).toHaveAttribute("href", "https://deepwaterimr.github.io/fiskwise/");

  await expect(page.locator(".site-header").getByRole("link", { name: "Fiskwise home", exact: true })).toHaveAttribute("href", "https://deepwaterimr.github.io/fiskwise/");
  await expect(page.getByRole("link", { name: "wise-presentations home", exact: true })).toHaveAttribute("href", "#top");

  const cards = page.locator(".layout-card");
  await expect(cards).toHaveCount(layouts.length);
  expect(await cards.evaluateAll((elements) => elements.map((element) => element.getAttribute("aria-label")))).toEqual(layouts.map((entry) => `Inspect ${entry.name}`));
  await expect(page.locator(".feature-card")).toHaveCount(entries.length - layouts.length);
  const previewImages = page.locator(".layout-image img");
  for (let index = 0; index < await previewImages.count(); index += 1) {
    const preview = previewImages.nth(index);
    await preview.scrollIntoViewIfNeeded();
    await expect.poll(async () => preview.evaluate((image) => (image as HTMLImageElement).complete && (image as HTMLImageElement).naturalWidth > 0), { timeout: 15_000 }).toBe(true);
  }
  await expect.poll(async () => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);

  await page.evaluate(() => window.scrollTo({ top: 0, behavior: "instant" }));
  await page.screenshot({ path: testInfo.outputPath("home.png") });

  const sampler = page.getByRole("link", { name: /Open sampler/i }).first();
  const samplerHref = await sampler.getAttribute("href");
  expect(samplerHref).toBeTruthy();
  const samplerResponse = await page.request.get(new URL(samplerHref!, page.url()).href);
  expect(samplerResponse.ok()).toBe(true);

  for (const id of ["edge-figure", "figure-tabs", "conclusion-cards"]) {
    const entry = layouts.find((candidate) => candidate.id === id)!;
    await page.getByRole("button", { name: `Inspect ${entry.name}`, exact: true }).click();
    await expect(page.getByRole("dialog").getByRole("heading", { name: entry.name, exact: true })).toBeVisible();
    await expect(page).toHaveURL(new RegExp(`#layout/${id}$`));
    await expect(page.getByRole("dialog").getByRole("heading", { name: entry.name, exact: true })).toBeInViewport();
    await expect.poll(() => page.getByRole("dialog").evaluate((element) => element.scrollWidth <= element.clientWidth + 1)).toBe(true);
    await page.getByRole("dialog").screenshot({ path: testInfo.outputPath(`${id}.png`), animations: "disabled" });
    await page.keyboard.press("Escape");
  }

  await page.getByLabel("Search slide layouts").fill("map");
  await expect(cards).toHaveCount(2);
  const mapCard = page.getByRole("button", { name: "Inspect Map + context" });
  await mapCard.focus();
  await expect(mapCard).toBeFocused();
  expect(await mapCard.evaluate((element) => getComputedStyle(element).outlineStyle)).not.toBe("none");
  await page.keyboard.press("Enter");

  const dialog = page.getByRole("dialog");
  await expect(dialog).toBeVisible();
  await expect(dialog.getByRole("heading", { name: "Map + context" })).toBeVisible();
  await expect(page).toHaveURL(/#layout\/map-context$/);
  await expect(dialog.getByAltText("Rendered example of Map + context")).toBeVisible();
  const copyButton = dialog.getByRole("button", { name: "Copy" });
  if (testInfo.project.name === "mobile") {
    await copyButton.focus();
    await page.keyboard.press("Enter");
  } else {
    await copyButton.click();
  }
  await expect(dialog.getByText("Layout source copied to the clipboard.")).toHaveText("Layout source copied to the clipboard.");
  expect(await page.evaluate(() => navigator.clipboard.readText())).toContain("#map-context");
  await page.keyboard.press("Escape");
  await expect(dialog).toBeHidden();
  await expect(mapCard).toBeFocused();

  await page.goto("/wise-presentations/#layout/background-image");
  await expect(page.getByRole("dialog")).toBeVisible();
  await expect(page.getByRole("heading", { name: "Background image" })).toBeVisible();
  await page.keyboard.press("Escape");
  await page.getByLabel("Search slide layouts").fill("");
  await page.getByRole("button", { name: "Values", exact: true }).click();
  await expect(cards).toHaveCount(layouts.filter((entry) => entry.category === "Values").length);

  await page.emulateMedia({ reducedMotion: "reduce" });
  const transitionDuration = await page.locator(".layout-card").first().evaluate((element) => getComputedStyle(element).transitionDuration);
  expect(transitionDuration).toMatch(/0\.00001s|1e-05s|0s/);
  await expect.poll(async () => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
  expect(failedResponses).toEqual([]);

  await page.screenshot({ path: testInfo.outputPath("learning-hub.png"), fullPage: true });
  if (testInfo.project.name === "mobile") {
    await page.setViewportSize({ width: 320, height: 800 });
    await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
    await expect.poll(() => page.locator(".site-header").evaluate((header) => header.scrollWidth <= header.clientWidth + 1)).toBe(true);
  }
});

test("sampler opens on its title and figure tabs switch visible plots", async ({ page }, testInfo) => {
  await page.goto("/wise-presentations/demo/presentation.html");
  await page.waitForFunction(() => (window as unknown as { Reveal?: { isReady(): boolean } }).Reveal?.isReady());
  const slideIds = await page.locator(".reveal .slides section.slide.level2").evaluateAll((slides) => slides.map((slide) => slide.id));
  expect(slideIds).toEqual(entries.map((entry) => entry.id));
  if (testInfo.project.name === "desktop") {
    await expect(page.locator("section.present")).toHaveAttribute("id", "title-slide");
  } else {
    await expect(page.locator("#title-slide")).toBeVisible();
  }
  await page.goto("/wise-presentations/demo/presentation.html#/figure-tabs");
  const tabsSlide = page.locator("#figure-tabs");
  await page.waitForFunction(() => (window as unknown as { Reveal?: { isReady(): boolean } }).Reveal?.isReady());
  if (testInfo.project.name === "desktop") {
    await expect(tabsSlide).toHaveClass(/present/);
  } else {
    // Reveal uses its scroll view on a narrow mobile screen.
    await tabsSlide.scrollIntoViewIfNeeded();
  }
  for (const title of ["Fuel use", "Power", "Cylinders"]) {
    const tab = tabsSlide.getByRole("tab", { name: title, exact: true });
    await tab.click();
    await expect(tab).toHaveAttribute("aria-selected", "true");
    const panelId = await tab.getAttribute("aria-controls");
    expect(panelId).toBeTruthy();
    const panel = page.locator(`[id="${panelId}"]`);
    await expect(panel).toBeVisible();
    await expect.poll(() => panel.locator("img").evaluate((image) => (image as HTMLImageElement).complete && (image as HTMLImageElement).naturalWidth > 0)).toBe(true);
    expect(await tab.evaluate((element) => parseFloat(getComputedStyle(element).fontSize))).toBeGreaterThanOrEqual(16 * 96 / 72 - 0.01);
  }
  await page.screenshot({ path: testInfo.outputPath("figure-tabs.png") });
  await page.goto("/wise-presentations/demo/presentation.html?qa-fragments=last#/conclusion-cards");
  const grid = page.locator(".conclusion-cards-grid");
  await expect(grid).toBeVisible();
  expect(await page.locator(".credit-note").evaluate((element) => parseFloat(getComputedStyle(element).fontSize))).toBeGreaterThanOrEqual(16 * 96 / 72 - 0.01);
  for (const count of [2, 4]) {
    await grid.evaluate((element, count) => {
      const card = element.firstElementChild!.cloneNode(true);
      element.replaceChildren(...Array.from({ length: count }, () => card.cloneNode(true)));
    }, count);
    const boxes = await grid.locator(".conclusion-card").evaluateAll((cards) => cards.map((card) => card.getBoundingClientRect().toJSON()));
    expect(Math.max(...boxes.map((box) => box.top)) - Math.min(...boxes.map((box) => box.top))).toBeLessThan(1);
    expect(Math.max(...boxes.map((box) => box.width)) - Math.min(...boxes.map((box) => box.width))).toBeLessThan(1);
  }
});

test("catalogue is present before JavaScript runs", async ({ browser }) => {
  const context = await browser.newContext({ javaScriptEnabled: false });
  const page = await context.newPage();
  await page.goto("http://127.0.0.1:4173/wise-presentations/");
  await expect(page.locator(".layout-card")).toHaveCount(layouts.length);
  await expect(page.locator(".feature-card")).toHaveCount(entries.length - layouts.length);
  await context.close();
});
