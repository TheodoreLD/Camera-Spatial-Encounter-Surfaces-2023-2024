#!/usr/bin/env Rscript
###############################################################################
# Runner: Forest-camera 2024 -- negative-binomial spatial-month encounter surface
# -----------------------------------------------------------------------------
# Thin entry point. The forest survey arrives as a single dated flat file rather
# than separate deployment/observation tables (SURVEY_DATA_SHAPE = "forest_flat"),
# but it runs the IDENTICAL ordered workflow as the road surveys through the
# shared analysis library: exploratory checks, candidate model comparison
# (Poisson/NB/ZINB by WAIC/DIC), prior-influence screen, prior/mesh sensitivity,
# final mapping fit, diagnostics, spatial block cross-validation, and the
# annualized posterior mean/SD/CV maps. The forest spatial scale is much shorter
# than the road surveys', so the mesh and prediction grid are finer here.
#
# Usage:
#   Rscript scripts/run_forest_2024.R
# Optional env vars: WOLF_RUN_PROFILE (quick|balanced|final), WOLF_FOREST_FILE,
#   WOLF_PROJECT_DIR, WOLF_DATA_DIR, WOLF_OUTPUT_DIR.
###############################################################################

SURVEY_ID         <- "forest_2024"
SURVEY_LABEL      <- "Forest-camera 2024 survey"
SURVEY_PREFIX     <- "wolf_forest_2024"
FINAL_FAMILY      <- "nbinomial"
FINAL_MODEL_NAME  <- "nb_spatial_month"
SURVEY_DATA_SHAPE <- "forest_flat"
# A single flat file. input_files_required is used only for project-directory
# detection; the actual file is resolved via FOREST_INPUT_FILES / WOLF_FOREST_FILE.
input_files_required <- c("forest_camera_trap_events.csv")
FOREST_INPUT_FILES <- unique(c(
  Sys.getenv("WOLF_FOREST_FILE", unset = ""),
  "forest_camera_trap_events.csv",
  "Forest_2024_camera_trap_events.csv"
))
OUTPUT_SUBPATH    <- "wolf_forest_NB_month_est_range_v1"

settings <- list(
  cell_size_m = 60,
  pred_buffer_m = 1500,
  mesh_cutoff_m = 75,
  mesh_max_edge = c(150, 900),
  mesh_offset = c(1200, 4000),
  fix_range_m = NULL,
  prior_range_m = c(1000, 0.5),   # PC prior: P(range < 1000 m) = 0.5
  prior_sigma = c(1.5, 0.05),     # PC prior: P(SD > 1.5) = 0.05
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
