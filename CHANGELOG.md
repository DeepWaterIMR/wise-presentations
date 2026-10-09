# Changelog

## 2026-10-09 — review and learning-hub synchronization

- Updated layout selection guidance for Edge figure, Figure tabs, and Conclusion cards, plus title punctuation, transparent figure backgrounds, and final-slide credits.
- Replaced the browser test’s fixed 15-layout expectation with catalogue membership and order checks. The current catalogue contains 17 layouts and six features; the old assertion prevented GitHub Pages deployment.
- Removed the blank opening slide created by the first catalogue comment by placing its catalogue marker after the title heading. Screenshot validation now rejects unnamed and duplicate slides, and the catalogue generator enforces source order.
- Corrected Figure tabs styling to target RevealJS’s Tabby markup and retain labels of at least 16 pt; applied the same minimum to the final production credit. Added browser checks for tab selection and visible images.
- Kept the layout dialog focused on its heading when opened so mobile readers see the layout name and preview before the source-copy controls.
- Made Conclusion cards use equal-width columns for the documented two-to-four-card range.
- Added clear validation for missing tab titles in `print_tabs()` and regression checks in CI.

Validation: catalogue/source order and all 23 previews, sampler render (5.1 MB), helper checks, installer smoke tests, skill validation, site lint/build, and four desktop/mobile browser checks passed locally.

## 2026-10-08–09 — layout and authoring updates

- Added Figure tabs and `print_tabs()` for a named list of related plots, with an optional fallback figure.
- Added Conclusion cards with white cards, an optional generated bottom graphic, and a fragment sign-off.
- Changed Edge figure to occupy the right half from top to bottom while preserving aspect ratio; kept title, interpretation, and section label on the left.
- Aligned title-slide elements on a shared left edge and width, leaving space for an illustration on the right.
- Added `transparent_bg()` for package-themed figures and used it in the presentation theme; changed numeric thousands separators to spaces.
- Removed the top border from workflow cards and refined list and title-link styling inside cards.
- Added sampler guidance for wider canvases, vertical centering, screen-resolution figures, and file size.
- Required declarative content-slide titles without closing full stops.
- Added the final-slide `.credit-note` production line; its model name is supplied by `project.ai_model` in `presentation.yml`.

## 2026-09-02 — catalogue and dependencies

- Renamed patterns to layouts, separated layouts from features, and connected stable catalogue IDs to sampler source, rendered previews, and learning-hub links.
- Added tibble to the sampler and pinned CI dependencies.
