@AGENTS.md

wise-presentations is part of [Fiskwise](https://deepwaterimr.github.io/fiskwise/). See the
[ecosystem repository](https://github.com/DeepWaterIMR/fiskwise) for the canonical pack
names and migration guide. Existing skill IDs and scientific interfaces remain stable.

# Claude Code notes

- Use `/make-presentation` for planning and building a deck.
- Use `/review-presentation` for rendering and visual QA.
- Use `/maintain-presentation-template` only in the wise-presentations repository.
- Keep shared invariants in `AGENTS.md`; add notes here only when they are genuinely Claude-specific.

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
