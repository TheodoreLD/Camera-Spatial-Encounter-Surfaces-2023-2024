#!/usr/bin/env Rscript
###############################################################################
# Runner: Road-camera March 2024 human-activity -- single-month, spatial-only
# -----------------------------------------------------------------------------
# The human-activity companion to run_road_march2024_wolf.R: a single calendar
# month (March 2024) modelled with NO month fixed effect (use_month_effect =
# FALSE), intercept + INLA-SPDE spatial field only. The modelled detections are
# a human-activity index (Homo sapiens + bikes + cars + motorcycle). It is a
# single-period surface (nothing to annualize; scale factor 1.000).
#
# Input data: deployments_march2024.csv (shared with the wolf March runner) and
# observations_humanmarch2024.csv -- the March 2024 human/vehicle events from the
# full multi-year camera-trap dataset. See data/README.md.
#
# Usage:
#   Rscript scripts/run_road_march2024_human.R
###############################################################################

SURVEY_ID         <- "human_march_2024"
SURVEY_LABEL      <- "Road-camera March 2024 human-activity survey (spatial-only)"
SURVEY_PREFIX     <- "human_march_2024"
TARGET_LABEL      <- "human activity"
# Poisson: like the wolf March surface, the single-month model comparison prefers
# Poisson (WAIC ~20 below NB/ZINB) -- no overdispersion once the spatial field is
# included (the multi-month human surveys, pooling months, needed NB).
FINAL_FAMILY      <- "poisson"
FINAL_MODEL_NAME  <- "poisson_spatial"
SURVEY_DATA_SHAPE <- "road_deployments"
input_files_required <- c("deployments_march2024.csv", "observations_humanmarch2024.csv")
OUTPUT_SUBPATH    <- "human_march_2024"

# Human-activity detection labels (exact scientificName strings in the data).
WOLF_NAMES <- c("Homo sapiens", "bikes", "cars", "motorcycle")

settings <- list(
  cell_size_m = 150,
  pred_buffer_m = 1500,
  mesh_cutoff_m = 150,
  mesh_max_edge = c(300, 3000),
  mesh_offset = c(4000, 12000),
  fix_range_m = NULL,
  prior_range_m = c(2500, 0.5),   # PC prior centred near the human spatial scale (weak)
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
