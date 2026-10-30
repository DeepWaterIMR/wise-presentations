# Presentation template contract

wise-presentations is part of [Fiskwise](https://deepwaterimr.github.io/fiskwise/). See the
[ecosystem repository](https://github.com/DeepWaterIMR/fiskwise) for the canonical pack
names and migration guide. Existing skill IDs and scientific interfaces remain stable.

Shared rules for scientific presentation projects based on this template. Task procedures live in the focused skills and `agent-workflows/`.

## Skill routing

- For standalone setup/update, use `wise-presentations-install` or `wise-presentations-update`. Retain the checkout for installers; resolve it from `~/.wise-presentations/config.json` or the Fiskwise registry.

- Use `make-presentation` to plan or build a new presentation, make substantive slide revisions, or reconnect slides to changed analysis outputs.
- Use `review-presentation` when an approved or existing presentation needs rendering, screenshots, visual correction, or delivery checks.
- In this wise-presentations repository only, use `maintain-presentation-template` when changing supported layouts or features, the catalogue, learning hub, installer, or validation workflow.

## Writing and approval

- Do not hard-wrap prose. Keep each paragraph or list item on one source line and use line breaks only for real Markdown structure.
- Keep visible slide text concise, professional, factual, and free of filler or promotional language.
- Give each content slide a complete declarative sentence title that states its main message. Do not end the title with a full stop. Title and section slides are exceptions. `Prompt + output` slides may omit the visible title because the prompt establishes their purpose; use an empty heading to retain the slide anchor.
- Do not invent text, results, or examples merely to fill space in a project presentation.
- End every presentation with a `.credit-note` line on the final slide: "The slides were made with [Quarto](https://quarto.org/) using [wise-presentations](https://deepwaterimr.github.io/wise-presentations/) and <model>." The line reads `<model>` from `project.ai_model` in `presentation.yml`. Set it to a concise name for the model you, the agent building the presentation, are running as: product and model only, no version IDs or dates (for example "Claude Opus 5.5" or "Codex, GPT-6.1 Sol"). Check your own system information for the name; never copy it from this template, another deck, or another agent. When a different agent substantially revises the deck, it updates the field to its own model.
- Before editing a presentation, read `README.md`, `slide-plan.md`, and `presentation.yml`, then learn the surrounding analysis project.
- For a new presentation, discuss audience, duration, purpose, meeting context, one-sentence story, and output filename; use `presentation.html` by default.
- Draft and show `slide-plan.md`, then wait for explicit approval before expanding `presentation.qmd` or rendering.

## Scientific and data rules

- Give every content slide one clear message supported by a primary figure, image, table, or explanation.
- Generate presentation inputs through the analysis workflow. Treat `data.summary_file`, named `data.inputs`, or a declared project data-loading script as the stable boundary.
- Never transcribe numeric results from another presentation when a rerenderable source exists.
- Stop clearly when a required input is missing; do not invent values or silently use stale files.
- Keep analysis logic in the analysis project or small helpers. Reuse a helper when one figure appears on multiple slides.
- Keep project inputs relative. Do not commit local absolute paths, credentials, access tokens, private URLs, or unpublished personal details.
- Author names, affiliations, and contact details may be included when they are intended presentation metadata.

## Visual rules

- Prefer the named layouts demonstrated in the learning hub and implemented in `assets/theme.scss`.
- When a figure or image is shown, it should normally occupy most of the slide's content area.
- Concepts should be paired with a photograph, schematic, map, or representative scientific figure that contributes to the explanation.
- Keep all visible text at least 16 pt, including captions, legends, tables, section labels, and slide numbers.
- Keep detailed explanation in speaker notes.
- Use captions only when requested, except that a short caption is recommended for scientific figures in `Prompt + output` when axes and legends leave needed context. Otherwise avoid `fig-` and `tbl-` chunk-label prefixes and placeholder captions.
- Use transparent plot, panel, legend, and legend-key backgrounds.
- Figures must have transparent plot and legend backgrounds; use `transparent_bg()` when a package supplies its own theme.
- Render inline figures at screen resolution and optimize large external images before embedding them in self-contained HTML.
- Reserve arbitrary absolute positioning for genuine full-bleed images or small accents; use the supported figure layouts for scientific figures.
- Keep fragment slides legible in their resting state and ensure transparent intermediate figures fade out before the next one appears.
- Bundle custom fonts under `assets/fonts/`, register them with `systemfonts`, and render those figures with `ragg`.

## Prompt + output

- Use `.prompt-output` for the default beside arrangement; add `.prompt-output-above` or `.prompt-output-floating` for alternatives.
- Keep the prompt concise and the reply to one first-person sentence describing the action taken. Label the reply with the responding model's own concise name, read from `project.ai_model` via `prompt_reply_label()`; use “Agent reply” only when the name is unavailable. Never copy another model's identity.
- Prefer graphical outputs when they suit the prompt. Connect executed results to rerenderable sources. Clearly label any estimated, simulated, or illustrative preview; never imply that an analysis ran when it did not.
- A scientific caption explains how to read the figure, including essential symbols, uncertainty, and units; the reply explains what the agent did. Put the caption directly below the output and detailed methods in notes.
- Use floating bubbles only over empty regions; check data, axes, legends, and captions. Switch to beside or above when no safe space exists. Never alter results to make room.

## Render and delivery rules

- Edit source files, not generated HTML.
- Render through `render_presentation.R` and visually review the result after substantive changes.
- Use the integrated background browser or `capture_slides.R`; do not take over the user's desktop browser for QA.
- Check every slide for overflow, tiny labels, weak hierarchy, awkward spacing, crowded tables, and an unclear relationship between title and supporting evidence or explanation.
- Rerender and reinspect affected slides after layout, theme, figure-size, or rendering changes.
- Deliver self-contained HTML beside the Quarto source. Add PDF or PowerPoint only when the project requires it.
- Keep generated HTML, screenshots, contact sheets, and generated presentation assets out of version control.

## Installation rules

- Presentation-level files are required; project-root skill shims are useful but optional and must warn rather than abort when they cannot be installed.
- Never overwrite an existing project-level `AGENTS.md` or `CLAUDE.md`.
- After installation into an allowlist-style repository, report required copied files that Git ignores.

## Shared Fiskwise capabilities

For ecosystem setup/update/removal, use `fiskwise-install`, `fiskwise-update`, or
`fiskwise-uninstall`. Direct pack and project installation remain supported.
wise-writing owns `r-code-style`, `r-package-setup` and `quarto-reporting`; read
`r-code-style` before new/edited R code. The starter carries a synchronized copy
of its shared package helper for self-contained projects. Missing packages do not
install by default; preserve explicit permission controls and renv/pins. This pack
owns slide planning, layouts, rendering and visual review, not ecosystem lifecycle.

## Fiskwise version policy

Follow the [shared version policy](https://github.com/DeepWaterIMR/fiskwise/blob/main/docs/VERSIONING.md).
Every ordinary authored commit increments the patch by 0.0.1 and stamps the current date
(`VERSION` for knowledge packs; `DESCRIPTION` `Version` and `Date` for R packages).
Only an explicit user request may set `FISKWISE_VERSION_BUMP=minor|major`. Never choose one
autonomously or create tags/releases automatically. Let `.githooks/pre-commit` enforce the
policy, preserve other custom hooks, and replay existing stamps unchanged during merges or
rebases.
