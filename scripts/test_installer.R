# Exercise the installer contract in isolated temporary projects.

repo_root <- normalizePath(".", mustWork = TRUE)
rscript <- file.path(R.home("bin"), "Rscript")
installer <- file.path(repo_root, "install_into_project.R")

run_installer <- function(arguments, expected_status = 0L) {
  output_file <- tempfile("installer-output-")
  status <- system2(
    rscript,
    args = c(shQuote(installer), vapply(arguments, shQuote, character(1))),
    stdout = output_file,
    stderr = output_file
  )
  if (is.null(status)) status <- 0L
  output <- paste(readLines(output_file, warn = FALSE), collapse = "\n")
  unlink(output_file)
  if (!identical(as.integer(status), as.integer(expected_status))) {
    stop("Installer returned ", status, " instead of ", expected_status, ".\n", output)
  }
  output
}

make_project <- function(name) {
  path <- file.path(tempdir(), paste0("presentation-installer-", name, "-", Sys.getpid()))
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  normalizePath(path, mustWork = TRUE)
}

project_default <- make_project("default")
run_installer(c("--target", project_default))
required_default <- c(
  file.path(project_default, "docs", "presentation", "presentation.qmd"),
  file.path(project_default, "docs", "presentation", "R", "package_setup.R"),
  file.path(project_default, ".agents", "skills", "make-presentation", "SKILL.md"),
  file.path(project_default, ".agents", "skills", "make-presentation", "references", "workflow.md"),
  file.path(project_default, ".agents", "skills", "review-presentation", "SKILL.md"),
  file.path(project_default, ".claude", "skills", "make-presentation", "references", "workflow.md"),
  file.path(project_default, ".claude", "skills", "review-presentation", "references", "workflow.md")
)
if (!all(file.exists(required_default))) stop("Default installation is incomplete.")
copied_setup <- readBin(
  file.path(project_default, "docs", "presentation", "R", "package_setup.R"),
  what = "raw", n = file.info(file.path(project_default, "docs", "presentation", "R", "package_setup.R"))$size
)
source_setup <- readBin(file.path(repo_root, "R", "package_setup.R"), what = "raw",
                        n = file.info(file.path(repo_root, "R", "package_setup.R"))$size)
if (!identical(copied_setup, source_setup)) stop("The shared package helper was not copied intact.")
canonical_setup <- file.path(
  dirname(repo_root), "wise-writing", "project-template", "R", "package_setup.R"
)
if (file.exists(canonical_setup)) {
  canonical_bytes <- readBin(
    canonical_setup, what = "raw", n = file.info(canonical_setup)$size
  )
  if (!identical(source_setup, canonical_bytes)) {
    stop("Refresh R/package_setup.R from wise-writing's canonical helper.")
  }
}
presentation_source <- readLines(file.path(repo_root, "presentation.qmd"), warn = FALSE)
if (!any(grepl("install_missing_packages: false", presentation_source, fixed = TRUE)) ||
    !any(grepl("package_setup(", presentation_source, fixed = TRUE)) ||
    any(grepl("install.packages(", presentation_source, fixed = TRUE))) {
  stop("Presentation package setup must use the shared helper and default to no installation.")
}
if (dir.exists(file.path(project_default, ".agents", "skills", "maintain-presentation-template"))) {
  stop("Repository maintenance skill must not be installed downstream.")
}

overwrite <- run_installer(c("--target", project_default), expected_status = 1L)
if (!grepl("Refusing to overwrite", overwrite, fixed = TRUE)) {
  stop("Overwrite refusal did not explain the failure.")
}

project_optional <- make_project("optional")
blocked_skill <- file.path(project_optional, ".agents", "skills", "make-presentation", "SKILL.md")
dir.create(dirname(blocked_skill), recursive = TRUE, showWarnings = FALSE)
writeLines("keep existing skill", blocked_skill)
optional <- run_installer(c("--target", project_optional))
if (!grepl("Could not install optional agent workflow file", optional, fixed = TRUE)) {
  stop("Optional skill-shim failure did not warn and continue.")
}
if (!file.exists(file.path(project_optional, "docs", "presentation", "presentation.qmd"))) {
  stop("Optional skill-shim failure interrupted the required deck installation.")
}

project_custom <- make_project("custom")
run_installer(c("--target", project_custom, "--presentation-dir", "presentation"))
if (!file.exists(file.path(project_custom, "presentation", "presentation.yml"))) {
  stop("Custom destination was not respected.")
}

traversal <- run_installer(
  c("--target", project_custom, "--presentation-dir", "../outside"),
  expected_status = 1L
)
if (!grepl("must be a relative folder", traversal, fixed = TRUE)) {
  stop("Traversal rejection did not explain the failure.")
}

project_ignored <- make_project("ignored")
system2("git", c("-C", shQuote(project_ignored), "init", "--quiet"))
writeLines(c("/*", "!/.gitignore"), file.path(project_ignored, ".gitignore"))
ignored <- run_installer(c("--target", project_ignored))
if (!grepl("ignored by the target repository", ignored, fixed = TRUE)) {
  stop("Allowlist-style .gitignore warning was not emitted.")
}

message("Installer contract passed: default, custom, overwrite, traversal, optional shim, skill scope, and ignored-file warning.")

# Global skill installation is exercised only in a temporary target.
global_installer <- file.path(repo_root, "scripts", "install_global_skills.R")
global_target <- file.path(tempdir(), paste0("wise-presentations-global-skills-", Sys.getpid()))
dir.create(global_target, recursive = TRUE, showWarnings = FALSE)
writeLines("keep", file.path(global_target, "unrelated-skill.txt"))
run_global_installer <- function(arguments, expected_status = 0L) {
  output_file <- tempfile("global-skills-output-")
  status <- system2(
    rscript,
    args = c(shQuote(global_installer), vapply(arguments, shQuote, character(1))),
    stdout = output_file,
    stderr = output_file
  )
  if (is.null(status)) status <- 0L
  output <- paste(readLines(output_file, warn = FALSE), collapse = "\n")
  unlink(output_file)
  if (!identical(as.integer(status), as.integer(expected_status))) {
    stop("Global skill installer returned ", status, " instead of ", expected_status, ".\n", output)
  }
  output
}
run_global_installer(c("--target", global_target))
installed_skills <- c(
  "make-presentation", "review-presentation", "maintain-presentation-template",
  "wise-presentations-install", "wise-presentations-update"
)
for (skill in installed_skills) {
  package <- file.path(global_target, skill)
  if (!file.exists(file.path(package, "SKILL.md")) || !file.exists(file.path(package, "references", "workflow.md"))) {
    stop("Global skill package is incomplete: ", skill)
  }
  skill_text <- paste(readLines(file.path(package, "SKILL.md"), warn = FALSE), collapse = "\n")
  if (grepl("agent-workflows/", skill_text, fixed = TRUE)) {
    stop("Global skill shim still depends on a repository-relative workflow path: ", skill)
  }
}
if (!file.exists(file.path(global_target, "unrelated-skill.txt"))) stop("Global installation removed an unrelated file.")
conflict <- run_global_installer(c("--target", global_target), expected_status = 1L)
if (!grepl("Skill destination already exists", conflict, fixed = TRUE)) stop("Global installer did not protect existing skills.")
run_global_installer(c("--target", global_target, "--force"))
message("Global skill installer contract passed: five relocatable skills, conflict protection, and forced replacement.")

# Exercise the starter's actual declaration against the shared helper's API. No packages
# are loaded or installed: injected functions verify the contract before a render.
setup_start <- grep("^```\\{r\\}", presentation_source)[[1L]]
setup_end <- which(seq_along(presentation_source) > setup_start & presentation_source == "```")[[1L]]
setup_expressions <- parse(text = presentation_source[(setup_start + 1L):(setup_end - 1L)])
preflight <- new.env(parent = baseenv())
eval(setup_expressions[[1L]], envir = preflight)
source(file.path(repo_root, "R", "package_setup.R"), local = preflight)
preflight$package_setup(preflight$packages, project_root = tempdir(),
  package_available = function(package) TRUE,
  installer = function(packages) stop("Preflight must not install packages"),
  attach = function(packages) stopifnot(length(packages) == 5L))
cat("Starter package declaration preflight passed.\n")
