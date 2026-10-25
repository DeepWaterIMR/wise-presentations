# Install this repository's skill packages into the user-level Codex
# skill directory. Each package carries its workflow reference, so it is
# independent of the checkout after installation.

args <- commandArgs(trailingOnly = TRUE)
value_after <- function(flag, default = NULL) {
  position <- match(flag, args)
  if (is.na(position)) return(default)
  if (position == length(args)) stop("Missing value after ", flag)
  args[[position + 1L]]
}

script_arg <- sub("^--file=", "", commandArgs(trailingOnly = FALSE)[grep("^--file=", commandArgs(trailingOnly = FALSE))][[1L]])
script_arg <- gsub("~\\+~", " ", script_arg)
repo_root <- normalizePath(file.path(dirname(normalizePath(script_arg, mustWork = TRUE)), ".."), mustWork = TRUE)
source_root <- file.path(repo_root, ".agents", "skills")
skills <- c(
  "make-presentation", "review-presentation", "maintain-presentation-template",
  "wise-presentations-install", "wise-presentations-update"
)
target <- path.expand(value_after("--target", "~/.agents/skills"))
force <- "--force" %in% args

missing_sources <- skills[!vapply(file.path(source_root, skills, "SKILL.md"), file.exists, logical(1))]
if (length(missing_sources)) stop("Missing skill packages: ", paste(missing_sources, collapse = ", "))

destinations <- file.path(target, skills)
conflicts <- destinations[dir.exists(destinations) | file.exists(destinations)]
if (length(conflicts) && !force) {
  stop(
    "Skill destination already exists; review it or rerun with --force to replace only these owned skill folders:\n  ",
    paste(conflicts, collapse = "\n  ")
  )
}

dir.create(target, recursive = TRUE, showWarnings = FALSE)
target <- normalizePath(target, mustWork = TRUE)
for (skill in skills) {
  destination <- file.path(target, skill)
  if (dir.exists(destination)) unlink(destination, recursive = TRUE, force = TRUE)
  if (!file.copy(file.path(source_root, skill), target, recursive = TRUE)) {
    stop("Failed to install skill package: ", skill)
  }
  if (!file.exists(file.path(destination, "references", "workflow.md"))) {
    stop("Installed skill package is missing its workflow reference: ", skill)
  }
  message("Installed ", skill, " to ", destination)
}
