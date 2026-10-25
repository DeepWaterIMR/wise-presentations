# Validate the focused skill packages shipped for Codex and Claude.

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Install the R package 'yaml' before validating skills.")
}

expected <- list(
  "make-presentation" = "agent-workflows/make-presentation.md",
  "review-presentation" = "agent-workflows/review-presentation.md",
  "maintain-presentation-template" = "agent-workflows/maintain-presentation-template.md",
  "wise-presentations-install" = "agent-workflows/wise-presentations-install.md",
  "wise-presentations-update" = "agent-workflows/wise-presentations-update.md"
)

read_frontmatter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  delimiters <- which(trimws(lines) == "---")
  if (length(delimiters) < 2L || delimiters[[1]] != 1L) {
    stop(path, " must begin with YAML front matter.")
  }
  yaml::yaml.load(paste(lines[2:(delimiters[[2]] - 1L)], collapse = "\n"))
}

for (system in c(".agents", ".claude")) {
  for (name in names(expected)) {
    path <- file.path(system, "skills", name, "SKILL.md")
    if (!file.exists(path)) {
      stop("Missing skill: ", path)
    }
    metadata <- read_frontmatter(path)
    if (!identical(metadata$name, name)) {
      stop(path, " has name '", metadata$name, "'; expected '", name, "'.")
    }
    description <- metadata$description
    if (!is.character(description) || length(description) != 1L || !nzchar(description)) {
      stop(path, " needs one non-empty description.")
    }
    if (nchar(description) > 1024L) {
      stop(path, " description exceeds 1024 characters.")
    }
    workflow <- expected[[name]]
    body <- paste(readLines(path, warn = FALSE), collapse = "\n")
    reference <- file.path(system, "skills", name, "references", "workflow.md")
    if (!grepl("references/workflow.md", body, fixed = TRUE)) {
      stop(path, " must route to its package-local workflow reference.")
    }
    if (!file.exists(workflow)) {
      stop("Missing shared workflow: ", workflow)
    }
    if (!file.exists(reference)) {
      stop("Missing package-local workflow reference: ", reference)
    }
    if (!identical(readLines(reference, warn = FALSE), readLines(workflow, warn = FALSE))) {
      stop(reference, " is out of sync with ", workflow, ".")
    }
  }
}

message("Validated 10 skill shims and 5 shared workflows.")
