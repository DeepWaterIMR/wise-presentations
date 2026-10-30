# Architecture and maintenance

The repository has four connected surfaces: the downstream presentation scaffold, the sampler, focused agent workflows, and the public learning hub.

## Public contracts

`presentation.yml` is the downstream configuration boundary. Keep existing project, data, and render fields backward compatible.

`slide-layouts.yml` is the canonical catalogue. Each entry records whether it is a layout or feature, a stable ID, public name, category, evidence or explanation type, intended use, Quarto code, classes, caveat, source marker, and preview filename. The stable ID is shared by the Quarto heading, source markers, generated JSON, screenshot filename, and website hash.

`presentation.qmd` is both the installable starter and the complete sampler. Catalogue markers surround each example so `scripts/generate_layout_catalog.R` can extract the actual source rather than maintaining handwritten website snippets.

## Build flow

1. The catalogue generator validates fields, IDs, exact source-marker order, and slide anchors, then writes `website/public/layouts.json`.
2. `render_presentation.R` renders a self-contained sampler and copies the complete helper and asset trees for isolated output builds.
3. `capture_slides.R --manifest slide-layouts.yml` discovers Reveal slide tags regardless of attribute order, rejects unnamed or duplicate slides and checks exact manifest order, writes one PNG per stable ID, and creates a contact sheet.
4. The website reads the generated JSON and preview directory, builds the client bundle, and publishes it under the `/wise-presentations/` GitHub Pages base path.
5. Pull requests run the contract, render, installer, skill, and website checks. Pushes to `main` additionally deploy the Pages artifact.

## Layout and feature boundary

A layout is an audience-facing composition that a user can request by name and Quarto class, such as `Text + figure` / `.text-figure`. A feature modifies a layout or rendering method, such as fragments, a background image, custom figure fonts, or table density. This distinction keeps the layout selection concise without hiding supported authoring techniques.

## Skill boundaries

`make-presentation` covers scientific orientation, the approval gate, and data-backed construction. `review-presentation` covers rendering, screenshots, correction, and delivery. Both are installed downstream with their workflow references. `scripts/install_global_skills.R` can also install all three skill packages into a user-level `.agents/skills` directory without checkout-relative links.

`maintain-presentation-template` covers this repository's catalogue, sampler, site, installer, and validation contracts. The skill ID remains stable, is excluded from downstream project installs, and is included in explicit global installs.

Stable writing, scientific, data, privacy, visual, and installation rules remain in `AGENTS.md`.

## Generated and pinned dependencies

The repository pins website dependencies in `website/package-lock.json` and CI R dependencies in the workflow. Those repository-only dependencies are not copied by `install_into_project.R`. Generated HTML, QA images, `assets/generated/`, website preview images, and deployment output remain ignored.

## PowerPoint evaluation

The supported output is currently RevealJS HTML. A later evaluation should compare Quarto's native PowerPoint output, a dedicated PowerPoint reference template, and image-based export of the reviewed HTML slides. RevealJS classes and CSS do not translate directly to editable PowerPoint layouts, so any PowerPoint route needs an explicit mapping and separate visual validation.

## Recent layout behavior

`Edge figure` reserves the right half from top to bottom for a tall or square image, preserving its aspect ratio. The title and text stay on the left; wide images are letterboxed.

`Figure tabs` uses RevealJS’s Tabby markup (`.panel-tabset-tabby`) inside a Quarto `.panel-tabset`. The `print_tabs()` helper requires a named list with non-empty titles and supports an empty-list fallback. CI clicks every sampler tab and checks its visible image and minimum tab-label size.

`Conclusion cards` uses equal-width columns for two to four short conclusions. The optional bottom graphic and fragment sign-off are demonstrated in the sampler. Every final slide carries a `.credit-note` with the building model read from `project.ai_model`; the installable configuration retains a placeholder until a project is authored.

The opening catalogue marker follows the title heading so it does not create an empty opening slide. The generator includes the preceding heading in that snippet; subsequent markers remain before their headings. Browser acceptance compares catalogue membership and order rather than a fixed layout count, then verifies the current layouts on desktop and mobile.

`Prompt + output` is a family of three catalogue layouts sharing `.prompt-output`: beside (default), `.prompt-output-above`, and `.prompt-output-floating`. Empty headings preserve stable anchors while omitting visible titles. Standard Quarto `fig-cap` and `fig-alt` supply optional scientific captions and accessible descriptions. `prompt_reply_label()` reads the configured model name with an unavailable-name fallback; `plot_prompt_output_example()` is a shared simulated sampler figure. Floating placement requires visual review and does not detect collisions automatically.
