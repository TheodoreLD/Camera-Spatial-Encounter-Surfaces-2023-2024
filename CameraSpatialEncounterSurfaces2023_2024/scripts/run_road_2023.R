#!/usr/bin/env Rscript
###############################################################################
# Runner: Road-camera 2023 -- negative-binomial spatial-month encounter surface
# -----------------------------------------------------------------------------
# Thin entry point. It only sets this survey's configuration and then sources
# the shared analysis library, which runs the full ordered workflow used by
# every survey: exploratory checks, candidate model comparison (Poisson/NB/ZINB
# by WAIC/DIC), prior-influence screen, prior- and mesh-sensitivity refits, the
# final mapping fit and observed-data diagnostic fit, posterior predictive and
# Moran's I diagnostics, residual temporal-autocorrelation checks, spatial block
# cross-validation, and the annualized posterior mean/SD/CV maps.
#
# Usage:
#   Rscript scripts/run_road_2023.R
# Optional env vars: WOLF_RUN_PROFILE (quick|balanced|final),
#   WOLF_PROJECT_DIR, WOLF_DATA_DIR, WOLF_OUTPUT_DIR.
###############################################################################

SURVEY_ID         <- "2023"
SURVEY_LABEL      <- "Road-camera 2023 survey"
SURVEY_PREFIX     <- "wolf_2023"
FINAL_FAMILY      <- "nbinomial"
FINAL_MODEL_NAME  <- "nb_spatial_month"
SURVEY_DATA_SHAPE <- "road_deployments"
input_files_required <- c("deployments_2023.csv", "observations_2023.csv")
OUTPUT_SUBPATH    <- file.path("2023", "wolf_2023_NB_month_split_final_v1")

settings <- list(
  cell_size_m = 150,
  pred_buffer_m = 1500,
  max_dist_m = 2500,
  mesh_cutoff_m = 200,
  mesh_max_edge = c(400, 3000),
  mesh_offset = c(4000, 12000),
  fix_range_m = NULL,
  prior_range_m = c(5000, 0.5),   # PC prior: P(range < 5000 m) = 0.5
  prior_sigma = c(2.00, 0.05),    # PC prior: P(SD > 2.00) = 0.05
  include_grid_in_mesh = FALSE,
  use_month_effect = TRUE,
  month_reference = "2023-08",
  month_prediction = "2023-08"
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
