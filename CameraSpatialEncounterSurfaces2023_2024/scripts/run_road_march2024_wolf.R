#!/usr/bin/env Rscript
###############################################################################
# Runner: Road-camera March 2024 wolf -- single-month, spatial-only surface
# -----------------------------------------------------------------------------
# A single calendar month (March 2024) modelled with the shared library, with
# NO month fixed effect (use_month_effect = FALSE): intercept + INLA-SPDE
# spatial field only, camera-days as exposure. Unlike the multi-month surveys
# there is nothing to annualize, so the map is a single-period expected
# encounter-frequency surface (scale factor 1.000).
#
# Likelihood: Poisson. Unlike the multi-month wolf surveys, the candidate model
# comparison prefers Poisson here (WAIC ~5.6 below NB, ~7.8 below ZINB); the
# March counts show no overdispersion once the spatial field is included, so the
# simpler Poisson model is selected.
#
# Input data: deployments_march2024.csv and observations_march2024.csv -- the
# March 2024 slice of the full multi-year camera-trap dataset (deployments
# clipped to the March window; distinct wolf events with eventStart in March
# 2024). See data/README.md.
#
# Usage:
#   Rscript scripts/run_road_march2024_wolf.R
###############################################################################

SURVEY_ID         <- "wolf_march_2024"
SURVEY_LABEL      <- "Road-camera March 2024 wolf survey (spatial-only)"
SURVEY_PREFIX     <- "wolf_march_2024"
TARGET_LABEL      <- "wolf"
FINAL_FAMILY      <- "poisson"
FINAL_MODEL_NAME  <- "poisson_spatial"
SURVEY_DATA_SHAPE <- "road_deployments"
input_files_required <- c("deployments_march2024.csv", "observations_march2024.csv")
OUTPUT_SUBPATH    <- "wolf_march_2024"

settings <- list(
  cell_size_m = 150,
  pred_buffer_m = 1500,
  mesh_cutoff_m = 200,
  mesh_max_edge = c(400, 3000),
  mesh_offset = c(4000, 12000),
  fix_range_m = NULL,
  prior_range_m = c(5000, 0.5),   # PC prior: P(range < 5000 m) = 0.5
  prior_sigma = c(2.00, 0.05),    # PC prior: P(SD > 2.00) = 0.05
  use_month_effect = FALSE,        # single month -> intercept + spatial only
  month_reference = "2024-03",
  month_prediction = "2024-03"
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
