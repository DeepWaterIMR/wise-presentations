# package_setup.R — shared, consent-aware package setup for scaffolded projects.
#
# Keep this helper self-contained: scaffold.R copies it into each new project's R/ folder.

.install_missing_r_packages <- function(pkgs) {
  if (!length(pkgs)) return(invisible(NULL))

  repos <- getOption("repos")
  if (is.na(repos["CRAN"]) || repos["CRAN"] == "@CRAN@") {
    repos["CRAN"] <- "https://cloud.r-project.org"
    options(repos = repos)
  }

  lib <- strsplit(Sys.getenv("R_LIBS_USER"), .Platform$path.sep)[[1]][1]
  if (!is.na(lib) && nzchar(lib)) {
    if (!dir.exists(lib)) dir.create(lib, recursive = TRUE)
    .libPaths(c(lib, .libPaths()))
  }

  options(install.packages.compile.from.source = "never")
  if (any(!is.na(pkgs)) && !requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  for (package in names(pkgs)) {
    message("Installing missing package: ", package)
    if (is.na(pkgs[[package]])) {
      install.packages(package)
    } else {
      remotes::install_github(pkgs[[package]], upgrade = "never")
    }
  }
  invisible(NULL)
}

.project_uses_renv <- function(project_root = getwd()) {
  current <- normalizePath(project_root, mustWork = FALSE)
  repeat {
    if (file.exists(file.path(current, "renv.lock")) ||
        dir.exists(file.path(current, "renv"))) return(TRUE)
    parent <- dirname(current)
    if (identical(parent, current)) break
    current <- parent
  }
  FALSE
}

#' Install and attach packages from a named package vector
#'
#' Package names are vector names; values are GitHub repositories or NA for CRAN packages.
#' Missing packages are reported without installation unless this call explicitly enables
#' installation. renv projects always manage their own library. R_AW_INSTALL_MISSING=false
#' remains a hard deny switch for compatibility with existing projects.
#'
#' @param packages Named character vector of package names and optional GitHub repositories.
#' @param install_missing_packages Set TRUE only after the user has authorized installation.
#' @param project_root Project directory used to detect renv.
#' @param package_available Function that checks whether a package is installed.
#' @param installer Function that installs a named vector of missing packages.
#' @param attach Function that attaches package names after validation.
#' @param deny_install Explicit deny state, defaulting to the legacy environment variable.
#' @return Invisibly, the result of attaching the requested packages.
package_setup <- function(packages,
                          install_missing_packages = FALSE,
                          project_root = getwd(),
                          package_available = function(package) {
                            requireNamespace(package, quietly = TRUE)
                          },
                          installer = .install_missing_r_packages,
                          attach = function(packages) {
                            invisible(lapply(packages, function(package) {
                              suppressPackageStartupMessages(
                                library(package, character.only = TRUE)
                              )
                            }))
                          },
                          deny_install = identical(
                            tolower(trimws(Sys.getenv("R_AW_INSTALL_MISSING", unset = ""))),
                            "false"
                          )) {
  if (!is.character(packages) || is.null(names(packages)) ||
      any(!nzchar(names(packages)))) {
    stop("`packages` must be a named character vector.", call. = FALSE)
  }
  if (anyDuplicated(names(packages))) {
    stop("Package names in `packages` must be unique.", call. = FALSE)
  }

  missing <- names(packages)[
    !vapply(names(packages), package_available, logical(1))
  ]
  renv_project <- .project_uses_renv(project_root)
  may_install <- isTRUE(install_missing_packages) && !isTRUE(deny_install) &&
    !renv_project

  if (length(missing) && may_install) {
    installer(packages[missing])
    missing <- names(packages)[
      !vapply(names(packages), package_available, logical(1))
    ]
  }

  if (length(missing)) {
    reason <- if (renv_project) {
      "This project uses renv; restore its lockfile with renv."
    } else if (isTRUE(deny_install)) {
      "R_AW_INSTALL_MISSING=false blocks automatic installation."
    } else {
      "Installation is off by default. Ask the user and pass install_missing_packages = TRUE after consent."
    }
    stop(
      "Required R package(s) are missing: ", paste(missing, collapse = ", "),
      "\n", reason,
      "\nSee the academic-toolchain-setup skill if a compiler is required.",
      call. = FALSE
    )
  }

  invisible(attach(names(packages)))
}
