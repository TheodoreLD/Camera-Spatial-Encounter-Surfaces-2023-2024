###############################################################################
# Capture the R environment used to fit the final models.
# -----------------------------------------------------------------------------
# INLA results can shift across package versions and INLA builds. Run this
# script in the same R environment used for a final run and commit the output
# file (results/session_info.txt) so an external reviewer can see the exact
# package and INLA build versions the reported numbers came from.
#
# Usage:
#   Rscript scripts/capture_session_info.R
###############################################################################

# Locate the project's results/ directory robustly, whether this file is run via
# `Rscript scripts/capture_session_info.R`, sourced interactively, or with
# WOLF_PROJECT_DIR set.
resolve_results_dir <- function() {
  proj <- Sys.getenv("WOLF_PROJECT_DIR", unset = "")
  if (nzchar(proj)) return(file.path(proj, "results"))
  cmd <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  script_path <- if (length(cmd)) {
    sub("^--file=", "", cmd[[1]])
  } else {
    tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  }
  base <- if (!is.null(script_path) && !is.na(script_path) && nzchar(script_path)) {
    dirname(dirname(normalizePath(script_path, winslash = "/", mustWork = FALSE)))
  } else {
    getwd()
  }
  file.path(base, "results")
}

out_dir <- resolve_results_dir()
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
out_file <- file.path(out_dir, "session_info.txt")

lines <- c(
  "Session info captured for reproducibility.",
  paste("Captured:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  ""
)

if (requireNamespace("INLA", quietly = TRUE)) {
  inla_version <- tryCatch(as.character(utils::packageVersion("INLA")),
                            error = function(e) NA_character_)
  inla_build <- tryCatch(INLA::inla.version(), error = function(e) NA_character_)
  lines <- c(lines,
             paste("INLA package version:", inla_version),
             "INLA build info:",
             paste(utils::capture.output(print(inla_build)), collapse = "\n"),
             "")
} else {
  lines <- c(lines, "INLA is not installed in this R environment.", "")
}

lines <- c(lines, "sessionInfo():", utils::capture.output(print(sessionInfo())))

writeLines(lines, out_file)
cat(sprintf("Session info written to %s\n", out_file))
