`%||%` <- function(x, fallback) {
  if (is.null(x) || length(x) == 0 || identical(x, "")) fallback else x
}

resolve_path <- function(path, base_dir = ".") {
  if (is.null(path) || length(path) == 0 || is.na(path) || identical(path, "")) {
    return(NULL)
  }
  if (grepl("^(/|[A-Za-z]:[/\\\\])", path)) {
    return(normalizePath(path, mustWork = FALSE))
  }
  normalizePath(file.path(base_dir, path), mustWork = FALSE)
}

presentation_input_paths <- function(cfg) {
  inputs <- cfg$data$inputs %||% list()
  if (!length(inputs)) {
    inputs <- list()
  } else if (is.null(names(inputs)) || any(!nzchar(names(inputs)))) {
    names(inputs) <- paste0("input_", seq_along(inputs))
  }

  paths <- c(
    list(summary_file = cfg$data$summary_file %||% ""),
    inputs
  )
  paths <- paths[vapply(paths, function(path) length(path) && nzchar(path), logical(1))]

  lapply(paths, resolve_path, base_dir = cfg$.project_root)
}

validate_presentation_inputs <- function(cfg, require_summary = FALSE) {
  paths <- presentation_input_paths(cfg)
  if (require_summary && !("summary_file" %in% names(paths))) {
    stop("presentation.yml must define data.summary_file for this adapter.")
  }
  if (!length(paths)) {
    return(invisible(paths))
  }

  missing <- paths[!file.exists(unlist(paths, use.names = FALSE))]
  if (length(missing)) {
    stop(
      "Configured presentation input files are missing:\n  ",
      paste(names(missing), unlist(missing, use.names = FALSE), sep = ": ", collapse = "\n  "),
      "\nRerun the analysis workflow, run a deck input refresh helper, or update presentation.yml."
    )
  }

  invisible(paths)
}

read_presentation_config <- function(config_file = "presentation.yml",
                                     project_root = ".") {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Install the R package 'yaml' before rendering the presentation.")
  }

  config_path <- resolve_path(config_file, getwd())
  if (!file.exists(config_path)) {
    stop("Presentation config does not exist: ", config_path)
  }

  cfg <- yaml::read_yaml(config_path)
  cfg$.config_path <- config_path
  cfg$.config_dir <- dirname(config_path)
  cfg$.project_root <- resolve_path(project_root, getwd())
  cfg
}

load_presentation_summary <- function(cfg) {
  env_path <- Sys.getenv("PRESENTATION_SUMMARY_FILE", unset = "")
  configured_path <- cfg$data$summary_file %||% ""
  summary_path <- env_path %||% configured_path

  if (identical(summary_path, "")) {
    return(NULL)
  }

  summary_path <- resolve_path(summary_path, cfg$.project_root)
  if (!file.exists(summary_path)) {
    stop(
      "Configured presentation summary does not exist: ",
      summary_path,
      "\nRerun the analysis or update data.summary_file in presentation.yml."
    )
  }

  readRDS(summary_path)
}

format_num <- function(x, digits = 2, suffix = "") {
  if (is.null(x) || length(x) == 0 || is.na(x)) {
    return("TBD")
  }
  paste0(format(round(x, digits), trim = TRUE, big.mark = " "), suffix)
}

#' Label a prompt reply with the responding model's configured name
#' @param model Concise model name, normally from project.ai_model.
#' @return A model label, or "Agent reply" when no usable name is configured.
prompt_reply_label <- function(model = NULL) {
  if (!is.character(model) || length(model) != 1L || is.na(model)) {
    return("Agent reply")
  }
  model <- trimws(sub("^Codex,\\s*", "", model))
  if (!nzchar(model) || tolower(model) %in% c("ai model name", "model name")) {
    return("Agent reply")
  }
  model
}

#' Draw the simulated figure used by the prompt-output sampler
#' @return A ggplot with illustrative estimates and uncertainty, not research data.
plot_prompt_output_example <- function() {
  example <- tibble::tibble(
    year = 2014:2025,
    index = c(0.48, 0.44, 0.50, 0.46, 0.57, 0.61, 0.66, 0.62, 0.74, 0.81, 0.87, 0.94),
    uncertainty = 0.10 + (0:11) * 0.004
  )
  ggplot2::ggplot(example, ggplot2::aes(year, index)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = index - uncertainty, ymax = index + uncertainty),
      fill = "#449bcf", alpha = 0.22
    ) +
    ggplot2::geom_line(colour = "#056a89", linewidth = 1.3) +
    ggplot2::geom_point(colour = "#056a89", size = 2.5) +
    ggplot2::scale_x_continuous(breaks = c(2014, 2017, 2020, 2023, 2025)) +
    ggplot2::scale_y_continuous(limits = c(0, 1.4), breaks = seq(0, 1.2, 0.4)) +
    ggplot2::labs(x = "Year", y = "Relative biomass index") +
    presentation_theme(base_size = 26) +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_line(colour = "#d6dedb"))
}

# Add to plots with a package-supplied theme: transparent plot, panel and legend backgrounds.
transparent_bg <- function() {
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    panel.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    legend.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    legend.box.background = ggplot2::element_rect(fill = "transparent", colour = NA),
    legend.key = ggplot2::element_rect(fill = "transparent", colour = NA)
  )
}

presentation_theme <- function(base_size = 18) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Install the R package 'ggplot2' before using presentation_theme().")
  }

  ggplot2::theme_classic(base_size = base_size) +
    ggplot2::theme(
      panel.background = ggplot2::element_blank(),
      plot.background = ggplot2::element_blank(),
      legend.background = ggplot2::element_blank(),
      legend.box.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      strip.background = ggplot2::element_blank()
    ) +
    transparent_bg()
}

# Register a bundled hand-drawn font (default: assets/fonts/xkcd-script.ttf) for
# systemfonts-aware devices and return the family name to pass to
# ggplot2::geom_text(family = ...). Self-contained — needs no system font
# install. IMPORTANT: the registration is only honoured by a systemfonts-aware
# device (ragg), so draw any figure that uses the font with ragg
# (`device = ragg::agg_png` in ggsave, or `#| dev: ragg_png` for an inline
# chunk). The default `png` (quartz) device ignores it. Degrades gracefully to
# the family name if `systemfonts` is unavailable.
register_xkcd_font <- function(ttf = "assets/fonts/xkcd-script.ttf",
                               family = "xkcd Script") {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    return(family)
  }
  already <- family %in% systemfonts::registry_fonts()$family ||
    family %in% systemfonts::system_fonts()$family
  if (!already && file.exists(ttf)) {
    systemfonts::register_font(name = family, plain = ttf)
  }
  family
}

extract_spict_context <- function(summary) {
  if (is.null(summary)) {
    return(NULL)
  }

  required <- c("summary", "refpoints", "state", "manTable", "assessment_year", "tac_year")
  missing <- setdiff(required, names(summary))
  if (length(missing)) {
    stop("SPiCT summary is missing fields: ", paste(missing, collapse = ", "))
  }

  state <- as.data.frame(summary$state)
  state$metric <- rownames(state)
  biomass_row <- grep("/Bmsy$", state$metric)
  fishing_row <- grep("/Fmsy$", state$metric)

  if (length(biomass_row) != 1 || length(fishing_row) != 1) {
    stop("Could not identify current B/Bmsy and F/Fmsy rows in the SPiCT state table.")
  }

  list(
    assessment_year = summary$assessment_year,
    advice_year = summary$tac_year,
    biomass_ratio = state$estimate[biomass_row],
    fishing_ratio = state$estimate[fishing_row],
    msy_tonnes = summary$refpoints["MSYd", "estimate"],
    scenarios = summary$manTable,
    raw = summary
  )
}

scenario_table <- function(spict) {
  if (is.null(spict)) {
    return(data.frame(
      Scenario = "Connect a result adapter to populate this table.",
      `Catch (t)` = "TBD",
      `B/Bmsy` = "TBD",
      `F/Fmsy` = "TBD",
      check.names = FALSE
    ))
  }

  x <- spict$scenarios
  data.frame(
    Scenario = gsub(" \\(@\\$\\)", "", x$Scenario),
    `Catch (t)` = format(round(x$C), big.mark = " ", scientific = FALSE),
    `B/Bmsy` = format(round(x$`B/Bmsy`, 2), nsmall = 2),
    `F/Fmsy` = format(round(x$`F/Fmsy`, 2), nsmall = 2),
    check.names = FALSE
  )
}

plot_spict_trajectories <- function(spict) {
  if (is.null(spict)) {
    years <- 2016:2025
    biomass <- c(0.72, 0.77, 0.83, 0.88, 0.96, 1.08, 1.15, 1.11, 1.23, 1.31)
    fishing <- c(1.32, 1.24, 1.19, 1.08, 1.02, 0.93, 0.86, 0.91, 0.80, 0.74)
    old_par <- par(no.readonly = TRUE)
    on.exit(par(old_par))
    par(mfrow = c(1, 2), mar = c(3.3, 3.7, 2.2, 0.8), mgp = c(2.1, 0.7, 0))
    plot(years, biomass, type = "l", lwd = 4, col = "#056A89", xlab = "Year", ylab = "Relative biomass", main = "Illustrative sampler data")
    abline(h = 1, col = "#6CA67A", lty = 2, lwd = 2)
    plot(years, fishing, type = "l", lwd = 4, col = "#D44F56", xlab = "Year", ylab = "Relative pressure", main = "Illustrative sampler data")
    abline(h = 1, col = "#6CA67A", lty = 2, lwd = 2)
    return(invisible(NULL))
  }

  x <- spict$raw$summary
  keep <- is.finite(x$year) & is.finite(x$BBmsy.est) & is.finite(x$FFmsy.est)
  x <- x[keep, , drop = FALSE]

  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  par(mfrow = c(1, 2), mar = c(3.3, 3.7, 1.4, 0.8), mgp = c(2.1, 0.7, 0))

  plot(
    x$year,
    exp(x$BBmsy.est),
    type = "l",
    lwd = 3,
    col = "#056A89",
    xlab = "Year",
    ylab = "B / Bmsy"
  )
  abline(h = 1, col = "#6CA67A", lty = 2, lwd = 2)

  plot(
    x$year,
    exp(x$FFmsy.est),
    type = "l",
    lwd = 3,
    col = "#D44F56",
    xlab = "Year",
    ylab = "F / Fmsy"
  )
  abline(h = 1, col = "#6CA67A", lty = 2, lwd = 2)
}

# Print a named list of ggplots as Quarto panel-tabset tabs. Call inside a
# `::: {.panel-tabset}` div from a chunk with `#| results: asis`; the list names
# become the tab titles. Pass `fallback` (a ggplot) to show one tab when the
# list is empty.
print_tabs <- function(plots, fallback = NULL) {
  if (!length(plots)) {
    cat("  \n### Figure  \n")
    if (!is.null(fallback)) print(fallback)
    return(invisible())
  }
  titles <- names(plots)
  if (is.null(titles) || anyNA(titles) || any(!nzchar(trimws(titles)))) {
    stop("print_tabs() requires a named list with a non-empty title for every plot.")
  }
  for (i in seq_along(plots)) {
    cat("  \n###", titles[i], "  \n")
    print(plots[[i]])
    cat("  \n")
  }
  invisible()
}
