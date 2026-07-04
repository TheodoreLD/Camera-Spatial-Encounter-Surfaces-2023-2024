#!/usr/bin/env Rscript
###############################################################################
# Runner: Road-camera 2024 -- zero-inflated negative-binomial encounter surface
# -----------------------------------------------------------------------------
# Thin entry point. It only sets this survey's configuration and then sources
# the shared analysis library, which runs the full ordered workflow used by
# every survey (exploratory checks, candidate model comparison, prior-influence
# screen, prior/mesh sensitivity, final mapping fit, diagnostics, spatial block
# cross-validation, and the annualized posterior mean/SD/CV maps).
#
# Usage:
#   Rscript scripts/run_road_2024.R
# Optional env vars: WOLF_RUN_PROFILE (quick|balanced|final),
#   WOLF_PROJECT_DIR, WOLF_DATA_DIR, WOLF_OUTPUT_DIR.
###############################################################################

SURVEY_ID         <- "2024"
SURVEY_LABEL      <- "Road-camera 2024 survey"
SURVEY_PREFIX     <- "wolf_2024"
FINAL_FAMILY      <- "zeroinflatednbinomial1"
FINAL_MODEL_NAME  <- "zinb_spatial_month"
SURVEY_DATA_SHAPE <- "road_deployments"
input_files_required <- c("deployments_2024.csv", "observations_2024.csv")
OUTPUT_SUBPATH    <- file.path("2024", "wolf_2024_ZINB_month_split_final_v1")

settings <- list(
  cell_size_m = 150,
  pred_buffer_m = 1500,
  max_dist_m = 2500,
  mesh_cutoff_m = 200,
  mesh_max_edge = c(400, 3000),
  mesh_offset = c(4000, 12000),
  fix_range_m = NULL,
  prior_range_m = c(5000, 0.5),   # PC prior: P(range < 5000 m) = 0.5
  prior_sigma = c(2.50, 0.05),    # PC prior: P(SD > 2.50) = 0.05 (widened after prior-influence screen)
  include_grid_in_mesh = FALSE,
  use_month_effect = TRUE,
  month_reference = "2024-08",
  month_prediction = "2024-08"
)

# Locate and source the shared analysis library (sibling file in scripts/).
.script_dir <- {
  cmd <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  of <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (length(cmd)) {
    dirname(normalizePath(sub("^--file=", "", cmd[[1]]), winslash = "/", mustWork = FALSE))
  } else if (!is.null(of)) {
    dirname(normalizePath(of, winslash = "/", mustWork = FALSE))
  } else {
    file.path(normalizePath(getwd(), winslash = "/"), "scripts")
  }
}
source(file.path(.script_dir, "wolf_encounter_surface_lib.R"))
