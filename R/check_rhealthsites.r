#' Check whether to install rhealthsites and install if necessary
#'
#' If the rhealthsites package is not installed, install it from GitLab using
#' remotes.
#' @export
check_rhealthsites <- function() {
  rhealthsites_version <- "0.2.1.9000"
  if (!requireNamespace("rhealthsites", quietly = TRUE)) {
    message("The rhealthsites package needs to be installed.")
    install_rhealthsites()
  } else if (utils::packageVersion("rhealthsites") < rhealthsites_version) {
    message("The rhealthsites package needs to be updated.")
    install_rhealthsites()
  }
}

#' Install the rhealthsites package after checking with the user
#' @export
install_rhealthsites <- function() {
  instructions <- paste("Please try installing the package for yourself",
                        "using the following command: \n",
                        "remotes::install_gitlab('dickoa/rhealthsites')")
                        #"install.packages(\"rhealthsites\")")

  error_func <- function(e) {
    stop(paste("Failed to install the rhealthsites package.\n", instructions))
  }

  input <- 1
  if (interactive()) {
    input <- utils::menu(c("Yes", "No"),
                         title = "Install the rhealthsites package?")
  }

  if (input == 1) {
    message("Installing the rhealthsites package.")
     tryCatch( remotes::install_gitlab("dickoa/rhealthsites"),
               error = error_func, warning = error_func)
  } else {
    stop(paste("The remotes and rhealthsites package are necessary for that method.\n",
               instructions))
  }

  # } else {
  #   stop(paste("Failed to install the rhealthsites package.\n", instructions))
  # }
}
