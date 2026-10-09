# Validate tab headings before they become generated Markdown.
source('R/presentation_helpers.R')
for (plots in list(list(1), setNames(list(1), ''), setNames(list(1), NA_character_))) {
  stopifnot(inherits(try(print_tabs(plots), silent = TRUE), 'try-error'))
}
stopifnot(identical(capture.output(print_tabs(list())), c('  ', '### Figure  ')))
output <- capture.output(print_tabs(list(First = 1, Second = 2)))
stopifnot(any(output == '### First   '), any(output == '### Second   '))
message('Tab-heading validation and empty fallback passed.')
