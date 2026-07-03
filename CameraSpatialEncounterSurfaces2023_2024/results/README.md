# Results Included In This Repository

The `results/` directory contains compact final outputs for the three final
models. It is meant for review and interpretation, not as a complete
generated-output archive. This file only lists what each committed file is;
for methodology, priors, and full diagnostic numbers, see the root
[`README.md`](../README.md).

## Road-Camera 2023

Folder:

```text
results/road_2023/
```

Files:

- `wolf_2023_validation_report.txt` — model, diagnostic status, priors, CV
- `wolf_2023_run_manifest.csv` — one-row run summary: cameras, rows, events,
  effort, diagnostics-pass flag
- `wolf_2023_science_checks_summary.txt` — plain-text summary of the
  posterior predictive checks and residual Moran's I test
- `wolf_2023_model_choice_report.txt` — narrative explanation of why the
  negative-binomial model was kept over the Poisson and ZINB alternatives
- `wolf_2023_model_comparison_report.txt` / `wolf_2023_model_comparison.csv`
  — WAIC/DIC table comparing the Poisson, NB, and ZINB candidate models
- `wolf_2023_prior_sensitivity_report.txt` / `wolf_2023_prior_sensitivity.csv`
  — WAIC and posterior-hyperparameter stability across 6 perturbed-prior
  refits
- `wolf_2023_mesh_sensitivity_report.txt` / `wolf_2023_mesh_sensitivity.csv`
  — WAIC and hyperparameter stability across finer/coarser SPDE mesh refits
- `wolf_2023_nb_spatial_month_temporal_autocorrelation_report.txt` —
  within-camera and date-ordered residual temporal autocorrelation check
- `wolf_2023_exploratory_timing_vs_northing.csv` — Spearman correlation of
  deployment start day-of-year against UTM northing
- `wolf_2023_final_spatial_block_cv_summary.csv` — held-out coverage from
  spatial block cross-validation
- `wolf_2023_annualization_weights.csv` — per-month camera-day shares and
  rate ratios used to build the annualization factor
- `wolf_2023_hyperparameters.csv` — posterior mean/SD of the NB size and
  the spatial range/SD
- `wolf_2023_month_coefficients.csv` — posterior month fixed-effect rate
  ratios with credible intervals
- `wolf_2023_month_observed_summary.csv` — observed events and effort by
  calendar month
- `wolf_2023_nb_spatial_month_posterior_predictive_check.csv` — posterior
  predictive check summary by camera
- `wolf_2023_final_event_frequency_mean.png` / `.tif` — posterior mean
  encounter-frequency map
- `wolf_2023_final_event_frequency_sd.png` /
  `wolf_2023_final_predicted_events_per_100_days_sd.tif` — posterior SD
  (absolute uncertainty) map
- `wolf_2023_final_event_frequency_cv.png` /
  `wolf_2023_final_predicted_events_per_100_days_cv.tif` — posterior CV
  (relative uncertainty) map

## Forest-Camera 2024

Folder:

```text
results/forest_2024/
```

Files:

- `wolf_forest_2024_full_final_model_report.txt` — consolidated model,
  diagnostic, and prior/mesh sensitivity summary
- `wolf_forest_2024_validation_report.txt` — model, diagnostic status,
  priors, CV
- `wolf_forest_2024_run_manifest.csv` — one-row run summary: cameras, rows,
  events, effort, diagnostics-pass flag
- `wolf_forest_2024_prior_sensitivity_report.txt` /
  `wolf_forest_2024_prior_sensitivity.csv` — WAIC, posterior-hyperparameter,
  and diagnostic-gate re-check across 12 perturbed-prior refits
- `wolf_forest_2024_mesh_sensitivity_report.txt` /
  `wolf_forest_2024_mesh_sensitivity.csv` — WAIC and hyperparameter
  stability across finer/coarser SPDE mesh refits
- `wolf_forest_2024_final_spatial_block_cv_summary.csv` — held-out coverage
  from spatial block cross-validation
- `wolf_forest_2024_nb_spatial_month_temporal_autocorrelation_report.txt` —
  within-camera residual temporal autocorrelation check, plus the
  low-power month-level ACF supporting check
- `wolf_forest_2024_temporal_residual_diagnostics.csv` — per-camera
  residual values used for the temporal autocorrelation check
- `wolf_forest_2024_temporal_within_camera_lag_correlation.csv` — lag-1
  pairs used to compute the within-camera autocorrelation statistic
- `wolf_forest_2024_annualization_weights.csv` — per-month camera-day
  shares and rate ratios used to build the annualization factor
- `wolf_forest_2024_hyperparameters.csv` — posterior mean/SD of the NB size
  and the spatial range/SD
- `wolf_forest_2024_month_coefficients.csv` — posterior month fixed-effect
  rate ratios with credible intervals
- `wolf_forest_2024_month_observed_summary.csv` — observed events and
  effort by calendar month
- `wolf_forest_2024_nb_spatial_month_posterior_predictive_check.csv` —
  posterior predictive check summary by camera
- `wolf_forest_2024_final_event_frequency_mean.png` / `.tif` — posterior
  mean encounter-frequency map
- `wolf_forest_2024_final_event_frequency_sd.png` /
  `wolf_forest_2024_final_predicted_events_per_100_days_sd.tif` — posterior
  SD (absolute uncertainty) map
- `wolf_forest_2024_final_event_frequency_cv.png` /
  `wolf_forest_2024_final_predicted_events_per_100_days_cv.tif` — posterior
  CV (relative uncertainty) map

## Road-Camera 2024

Folder:

```text
results/road_2024/
```

Files:

- `wolf_2024_validation_report.txt` — model, diagnostic status, priors, CV
- `wolf_2024_run_manifest.csv` — one-row run summary: cameras, rows, events,
  effort, diagnostics-pass flag
- `wolf_2024_science_checks_summary.txt` — plain-text summary of the
  posterior predictive checks and residual Moran's I test
- `wolf_2024_model_choice_report.txt` — narrative explanation of why the
  zero-inflated negative-binomial model was kept over the Poisson and NB
  alternatives
- `wolf_2024_model_comparison_report.txt` / `wolf_2024_model_comparison.csv`
  — WAIC/DIC table comparing the Poisson, NB, and ZINB candidate models
- `wolf_2024_prior_sensitivity_report.txt` / `wolf_2024_prior_sensitivity.csv`
  — WAIC and posterior-hyperparameter stability across perturbed-prior
  refits
- `wolf_2024_mesh_sensitivity_report.txt` / `wolf_2024_mesh_sensitivity.csv`
  — WAIC and hyperparameter stability across finer/coarser SPDE mesh refits
- `wolf_2024_zinb_spatial_month_temporal_autocorrelation_report.txt` —
  within-camera and date-ordered residual temporal autocorrelation check;
  this is the survey with the open residual-autocorrelation caveat (see
  root README)
- `wolf_2024_exploratory_timing_vs_northing.csv` — Spearman correlation of
  deployment start day-of-year against UTM northing; used to test the
  hypothesized mechanism for this survey's residual temporal
  autocorrelation
- `wolf_2024_final_spatial_block_cv_summary.csv` — held-out coverage from
  spatial block cross-validation
- `wolf_2024_annualization_weights.csv` — per-month camera-day shares and
  rate ratios used to build the annualization factor
- `wolf_2024_hyperparameters.csv` — posterior mean/SD of the NB size,
  zero-inflation probability, and spatial range/SD
- `wolf_2024_month_coefficients.csv` — posterior month fixed-effect rate
  ratios with credible intervals
- `wolf_2024_month_observed_summary.csv` — observed events and effort by
  calendar month
- `wolf_2024_zinb_spatial_month_posterior_predictive_check.csv` — posterior
  predictive check summary by camera
- `wolf_2024_final_event_frequency_mean.png` / `.tif` — posterior mean
  encounter-frequency map
- `wolf_2024_final_event_frequency_sd.png` /
  `wolf_2024_final_predicted_events_per_100_days_sd.tif` — posterior SD
  (absolute uncertainty) map
- `wolf_2024_final_event_frequency_cv.png` /
  `wolf_2024_final_predicted_events_per_100_days_cv.tif` — posterior CV
  (relative uncertainty) map

## Not Included By Default

The full generated output folders contain full prediction-grid CSV files,
exploratory figures, and many intermediate diagnostic files. These are omitted
here to keep the GitHub project focused on the final diagnostics and map
products.
