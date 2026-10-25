# Update wise-presentations independently

The standalone update keeps this pack usable without Fiskwise. It updates the checkout and synchronizes only this repository's skills; it does not install or update R, Quarto, R packages, browser tooling, or model software.

## 1. Find and inspect the checkout

Resolve `~/.wise-presentations/config.json` → `wise_presentations_path`, the Fiskwise registry `components.wise-presentations.path`, or a user-supplied checkout. Record its current `VERSION`, then run `git -C "<path>" status --short --branch`. If the working tree contains changes, stop and show them to the user; do not stash, discard, commit, merge, or rebase without direction.

## 2. Pull the update

Run `git -C "<path>" pull --ff-only`. If the branch diverged or the pull fails, report the state and stop for user direction. Preserve custom hook configuration; enable the version hook only where it does not displace an existing hook.

## 3. Synchronize skills

Compare installed copies against the previous checkout revision. Preserve customized copies and report them. Refresh unchanged owned skills and add newly introduced IDs with the existing installer (using `--force` only after this comparison) or native file tools if R is absent. Keep a recoverable backup before replacing a copy. Do not remove unrelated skills. A project starter is copied, not linked; updating the pack does not update an existing presentation project.

## 4. Report

Report the old and new pack versions, commit summary, synchronized skill IDs, and any follow-up required. Do not render or update an existing project unless separately requested.
