[![Part of Fiskwise](https://deepwaterimr.github.io/fiskwise/assets/part-of-fiskwise.svg)](https://deepwaterimr.github.io/fiskwise/)

# wise-presentations

A Quarto RevealJS template for scientific presentations. It provides predefined slide layouts, project-relative data interfaces, and a render-and-review workflow.

**Learning hub:** <https://deepwaterimr.github.io/wise-presentations/>

**Repository:** <https://github.com/DeepWaterIMR/wise-presentations>

Part of [Fiskwise](https://deepwaterimr.github.io/fiskwise/), the shared home for [wise-writing](https://github.com/DeepWaterIMR/wise-writing), [index-wise](https://github.com/DeepWaterIMR/index-wise), and [spict-wise](https://github.com/DeepWaterIMR/spict-wise).

## What the template provides

- Content slides with a full-sentence title that states the main message, without a closing full stop.
- Layouts that give the primary figure, image, table, or explanation sufficient space, including full-height edge figures, figure tabs, and conclusion cards.
- Project-relative interfaces for reading rerenderable analysis outputs.
- A self-contained HTML presentation that can be shared as one file.
- Focused skills for presentation creation, rendered-slide review, and template maintenance.
- Scripts for rendering slides and producing screenshots and contact sheets for review.
- A small credit line on the final slide stating that the slides were made with Quarto, wise-presentations, and the AI model that built them.

The slide-design guidance is informed by the assertion–evidence approach described by Michael Alley in *The Craft of Scientific Presentations*. The template adapts that approach to its existing Quarto visual system; it does not reproduce Alley's template.

## Start with an agent

Give the agent this repository URL, the analysis project, and the folder where the presentation should live:

```text
Use https://github.com/DeepWaterIMR/wise-presentations to initiate a presentation in docs/presentation. Familiarize yourself with the analysis project first. Discuss the audience, purpose, duration, meeting context, one-sentence story, and HTML output filename with me. Prepare slide-plan.md, show me the overview, and wait for approval before building.
```

The `make-presentation` skill covers orientation, discussion, planning, and construction. The `review-presentation` skill covers rendering, screenshots, correction, and delivery checks.

## Install manually

### Fiskwise core bootstrap

When installed through Fiskwise, the `make-presentation` and `review-presentation` skill packages can be copied directly into an agent's skill folder. This core knowledge install does not require R, Quarto, or an R package library, and it does not install modeling software or optional R packages. Keep those tools opt-in and add them only when a project needs them and the user approves.

The core skill install does not create a presentation project. Once R is available, use the project installer below if you want the starter files in an analysis repository. The Quarto CLI is installed separately from the R package `quarto`; the R package is an interface to the CLI, not a replacement for it.

### Standalone install from this repository

From a clone of this repository:

```bash
Rscript install_into_project.R --target "/path/to/project"
```

The default destination is `docs/presentation/`. Use `--presentation-dir presentation` to choose another project-relative folder. The installer refuses to overwrite existing presentation files unless `--force` is supplied, never overwrites project-level agent guidance, and warns when required files are ignored by Git.

To install the three skill packages globally for your user account, run this from the repository:

```bash
Rscript scripts/install_global_skills.R
```

This installs `make-presentation`, `review-presentation`, and `maintain-presentation-template` under `~/.agents/skills/`. Each skill carries its workflow reference, so it works outside the repository checkout. Existing skill folders are protected; pass `--force` only when you intend to replace those three packages. Use `--target` to stage or inspect an installation elsewhere.

This standalone installer is written in base R, so it requires `Rscript`; the Fiskwise core bootstrap uses filesystem copies when R is not yet available. Neither route installs R, Quarto, R packages, or model software.

## Build and review a presentation

1. Learn the analysis and identify stable result objects or data-loading scripts.
2. Agree on the sequence of messages and the slide plan.
3. Connect project-relative inputs through `presentation.yml`.
4. Select layouts from the [learning hub](https://deepwaterimr.github.io/wise-presentations/).
5. Build the presentation from the approved plan.
6. Run `Rscript render_presentation.R`.
7. Run `Rscript capture_slides.R` and inspect every slide plus the contact sheet.

Use `presentation.html` when no output filename is specified. PowerPoint export is not yet part of the supported workflow; it will be evaluated after the HTML layouts are settled.

## Stable interfaces

- `presentation.yml` is the downstream presentation configuration and data-input boundary.
- `slide-plan.md` records the approved message, supporting evidence or explanation, layout, visible text, notes, and status for each slide.
- `slide-layouts.yml` is the repository's public layout catalogue. Stable IDs connect sampler slides, source snippets, previews, and learning-hub links.
- `assets/theme.scss` contains the reusable visual system.
- `R/presentation_helpers.R` contains small adapters and plotting helpers.

## Development

Recent layout and authoring changes are recorded in [CHANGELOG.md](CHANGELOG.md). Repository maintenance is documented in [docs/architecture.md](docs/architecture.md) and [CONTRIBUTING.md](CONTRIBUTING.md). The `maintain-presentation-template` skill applies only to this repository. Generated HTML, screenshots, contact sheets, and generated presentation assets are build artifacts and are not committed.

The repository-authored code and documentation are MIT licensed. The bundled IMR logo and font asset are excluded; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
