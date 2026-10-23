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
