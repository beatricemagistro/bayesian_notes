suppressPackageStartupMessages({
  library("knitr")
  library("rstan")
  library("rstanarm")
  library("bayesplot")
  library("loo")
  library("tidyverse")
  library("rubbish")
})

set.seed(92508117 )
options(digits = 3)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  out.width = "70%",
  fig.align = 'center',
  fig.width = 6,
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold"
)

options(dplyr.print_min = 6,
        dplyr.print_max = 6)

# Helpful Documentation functions
rpkg_url <- function(pkg) {
  paste0("https://cran.r-project.org/package=", pkg)
}

rpkg <- function(pkg) {
  paste0("**[", pkg, "](", rpkg_url(pkg), ")**")
}

rdoc_url <- function(pkg, fun) {
  paste0("https://www.rdocumentation.org/packages/", pkg, "/topics/", fun)
}

rdoc <- function(pkg, fun, full_name = FALSE) {
  text <- if (full_name) paste0(pkg, "::", fun) else pkg
  paste0("[", text, "](", rdoc_url(pkg, fun), ")")
}

STAN_VERSION <- "2.14.0"
STAN_URL <- "http://mc-stan.org/documentation/"
STAN_MAN_URL <- paste0("https://github.com/stan-dev/stan/releases/download/v", STAN_VERSION, "/stan-reference-", STAN_VERSION, ".pdf")

standoc <- function(x = NULL) {
  if (!is.null(x)) {
    STAN_MAN_URL
  } else {
    paste("[", x, "](", STAN_MAN_URL, ")")
  }
}

# placeholder for maybe linking directly to docs
stanfunc <- function(x) {
  paste0("`", x, "`")
}

knit_print.stanmodel <- function(x, options) {
  code_str <- x@model_code
  knitr::asis_output(as.character(htmltools::tags$pre(htmltools::tags$code(htmltools::HTML(code_str), class = "stan"))))
}

# cat_line <- function (...)  {
#   cat(..., "\n", sep = "")
# }
#
# print.stanfit_summary <- function(x, n = 10, stats = NULL) {
#   stats <- stats %||% colnames(x$summary)
#   comment <- sprintf("stanfit_summary: %d paramters, %d chains",
#                      nrow(x$summary), length(x$c_summary))
#   cat_line(comment)
#   print(head(x$summary[ , stats, drop = FALSE], n))
# }

autoscale <- function(x, ...) {
  UseMethod("autoscale")
}

autoscale.numeric <- function(x, center = TRUE, scale = TRUE) {
  nvals <- length(unique(x))
  if (nvals <= 1) {
    out <- x
  } else if (nvals == 2) {
    out <- if (scale) {
      (x - min(x, na.rm = TRUE)) / diff(range(x, finite = TRUE))
    } else x
    if (center) {
      out <- x - mean(x)
    }
  } else {
    out <- if (center) {
      x - mean(x, na.rm = TRUE)
    } else x
    out <- if (scale) out / sd(out, na.rm = TRUE)
  }
  out
}

autoscale.matrix <- function(x, center = TRUE, scale = TRUE) {
  apply(x, 2, autoscale, center = center, scale = scale)
}

autoscale.data_frame <- function(x, center = TRUE, scale = TRUE) {
  mutate_if(is.numeric, autoscale.numeric, center = center, scale = scale)
}
