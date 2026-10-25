# Install wise-presentations independently

This pack can be installed without Fiskwise. It contains presentation creation, visual review, and repository maintenance guidance. It does not install R, Quarto, R packages, browser tooling, or model software.

## 1. Find or clone the repository

Read `~/.wise-presentations/config.json` → `wise_presentations_path` or the Fiskwise registry `components.wise-presentations.path` first. Reuse a valid checkout. Otherwise choose a sensible user-owned folder consistent with the workspace and clone `https://github.com/DeepWaterIMR/wise-presentations` there. Never clone to a filesystem root or system directory. Enable `.githooks` only if no custom hook configuration would be displaced. Preserve custom hooks. Save the checkout path as `wise_presentations_path` in `~/.wise-presentations/config.json`, merging existing fields.

## 2. Install the global skills

If R is present, run `Rscript "<path>/scripts/install_global_skills.R"`. If not, use native file tools to copy each `.agents/skills/*` directory recursively, including its `references/`, into the active host’s user-level skill directory. Missing R must not block installing instructions. This installs the pack's skills under `~/.agents/skills/`; use `--target "<directory>"` to stage elsewhere. Existing skill folders are preserved unless the user explicitly requests replacement with `--force`. The project starter is separate: `Rscript "<path>/install_into_project.R" --target "<analysis-project>"` copies presentation files into `docs/presentation/` by default.

## 3. Check tools only when needed

The skills themselves require no scientific software. A presentation project needs R and Quarto. Check for both with `R --version` and `quarto --version`; direct installation or updates to system software require the user's approval. If a project has `renv.lock`, follow renv and report missing packages without installing them outside that environment.

## 4. Report

Report the checkout path, pack version, installed skill IDs and destination, tool availability, and whether a project starter was created. Do not claim that the project starter or scientific tools were installed unless they were.
