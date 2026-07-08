#!/usr/bin/env Rscript
###############################################################################
# Runner: Road-camera 2024 -- HUMAN-ACTIVITY encounter surface
# -----------------------------------------------------------------------------
# Same shared pipeline as run_road_2024.R, but the modelled detections are a
# human-activity index (Homo sapiens + bikes + cars + motorcycle) instead of
# wolves.
#
# The mesh is finer than the road-wolf runners (inner edge 300 m vs 400 m) to
# resolve the shorter human spatial range (estimated ~1.2 km); the
# mesh-sensitivity check confirms the fit is insensitive to further refinement.
# Priors are weakly informative (verified by the prior-sensitivity check).
#
# CAVEAT: this survey shows a small but significant residual spatial
# autocorrelation (Moran's I ~ 0.03, p ~ 0.02) that finer meshing does not
# remove -- genuine fine-scale human structure a stationary field cannot fully
# absorb. The map is retained as a relative-activity index with that caveat.
#
# Usage:
#   Rscript scripts/run_road_2024_human.R
###############################################################################

SURVEY_ID         <- "human_2024"
SURVEY_LABEL      <- "Road-camera 2024 human-activity survey"
SURVEY_PREFIX     <- "human_2024"
TARGET_LABEL      <- "human activity"
FINAL_FAMILY      <- "nbinomial"
FINAL_MODEL_NAME  <- "nb_spatial_month"
SURVEY_DATA_SHAPE <- "road_deployments"
input_files_required <- c("deployments_2024.csv", "observations_2024.csv")
OUTPUT_SUBPATH    <- file.path("human", "human_2024_NB_month_split_final_v1")

# Human-activity detection labels (exact scientificName strings in the data).
WOLF_NAMES <- c("Homo sapiens", "bikes", "cars", "motorcycle")

settings <- list(
  cell_size_m = 150,
  pred_buffer_m = 1500,
  max_dist_m = 2500,
  mesh_cutoff_m = 150,
  mesh_max_edge = c(300, 3000),
  mesh_offset = c(4000, 12000),
  fix_range_m = NULL,
  prior_range_m = c(2500, 0.5),   # PC prior centred near the human spatial scale (weak)
  prior_sigma = c(2.00, 0.05),    # PC prior: P(SD > 2.00) = 0.05
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
