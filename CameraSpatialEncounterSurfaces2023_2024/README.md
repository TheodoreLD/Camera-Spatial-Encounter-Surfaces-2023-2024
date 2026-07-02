# Bayesian Spatial Encounter-Surface Models For 2023-2024 Wolf Camera-Trap Detections

This project contains the final 2023-2024 wolf relative encounter-frequency models
from camera-trap data. It is organized so a reader can understand the ecological
question, the input data structure, the three final statistical models, the
validation checks, and the outputs needed to reproduce or audit the analysis.

The analyses model the number of independent wolf event IDs recorded in
camera-month rows. The statistical approach is Bayesian count modelling with
INLA-SPDE spatial random fields. Active camera-days are used as an exposure
term, calendar month is included as a fixed temporal control, and outputs are
relative encounter-frequency surfaces expressed as expected wolf events per 100
camera-days across the sampled survey-year period. The maps should not be
interpreted as abundance, density, occupancy, or population size.

## Final Models

Three camera-specific analyses are included:

| Survey | Final model | Cameras | Events | Effort | Final output |
| --- | --- | ---: | ---: | ---: | --- |
| Road-camera 2023 | Negative-binomial spatial-month INLA-SPDE model | 60 | 586 | 5222.2 camera-days | `results/road_2023/` |
| Forest-camera 2024 | Negative-binomial spatial-month INLA-SPDE model | 53 | 46 | 4423.0 camera-days | `results/forest_2024/` |
| Road-camera 2024 | Zero-inflated negative-binomial spatial-month INLA-SPDE model | 60 | 479 | 3574.0 camera-days | `results/road_2024/` |

## Result Maps

Each survey below is mapped as two GeoTIFF/PNG pairs: a posterior-mean
encounter-frequency surface (the main result) and a posterior-SD map (the
matching uncertainty surface, on the same units and color scale family). Both
are expected independent wolf events per 100 camera-days, effort-weighted and
annualized over the sampled months for that survey (see
[Model Structure And Camera-Month Rows](#model-structure-and-camera-month-rows)
below) -- not abundance, density, occupancy, or population size. GeoTIFFs for
GIS use are in the same result folders as these PNGs.

### Road-Camera 2023

| Posterior mean | Posterior SD |
| --- | --- |
| ![Road-camera 2023 posterior mean encounter frequency](results/road_2023/wolf_2023_final_event_frequency_mean.png) | ![Road-camera 2023 posterior SD](results/road_2023/wolf_2023_final_event_frequency_sd.png) |

### Forest-Camera 2024

| Posterior mean | Posterior SD |
| --- | --- |
| ![Forest-camera 2024 posterior mean encounter frequency](results/forest_2024/wolf_forest_2024_final_event_frequency_mean.png) | ![Forest-camera 2024 posterior SD](results/forest_2024/wolf_forest_2024_final_event_frequency_sd.png) |

### Road-Camera 2024

| Posterior mean | Posterior SD |
| --- | --- |
| ![Road-camera 2024 posterior mean encounter frequency](results/road_2024/wolf_2024_final_event_frequency_mean.png) | ![Road-camera 2024 posterior SD](results/road_2024/wolf_2024_final_event_frequency_sd.png) |

## Model Structure And Camera-Month Rows

The analysis is fitted at the camera-month scale. Each row represents one camera
location during one calendar month, with:

- `y_i`: the number of independent wolf events detected by camera `i` during
  that month;
- `E_i`: the number of active camera-days for that camera during that month;
- `s_i`: the spatial location of the camera;
- `m_i`: the calendar month assigned to the row.

If a deployment crosses a month boundary, the deployment is split before
modelling. This keeps event counts and exposure aligned before fitting month
effects.

The shared linear predictor is:

```text
log(mu_i) = log(E_i) + beta_0 + gamma[m_i] + u(s_i)
```

where:

- `mu_i` is the expected number of wolf events in camera-month row `i`;
- `log(E_i)` is an offset for camera effort, so cameras active for more days are
  expected to record more events;
- `beta_0` is the model intercept on the log encounter-rate scale;
- `gamma[m_i]` is a fixed calendar-month effect used as a temporal control;
- `u(s_i)` is the spatial INLA-SPDE random field, which estimates a smooth
  spatial surface while allowing nearby camera locations to be correlated.

The forest-camera 2024 model and road-camera 2023 model use a
negative-binomial likelihood:

```text
y_i ~ NegativeBinomial(mu_i, size)
```

The road-camera 2024 model uses INLA's `zeroinflatednbinomial1` likelihood:

```text
y_i ~ ZeroInflatedNegativeBinomial(mu_i, size, pi)
```

The negative-binomial component allows event counts to be more variable than a
Poisson model. The zero-inflation component in the road-camera 2024 model
allows for additional zero counts beyond those expected from the
negative-binomial count process. In this type-1 parameterization, `pi` is the
probability of an additional structural zero, while `mu_i` and `size` describe
the negative-binomial count component.

The final map target is an effort-weighted annualized survey-year encounter-frequency
surface. Month remains in the model as a temporal control because residual
diagnostics indicated temporal structure when time was not handled explicitly.
Month is treated as a fixed effect in the final models. The public maps are not
intended to represent one selected calendar month. For each prediction cell, the
mapped daily encounter rate is:

```text
lambda_year(s) = sum_m w_m * 100 * exp(beta_0 + gamma[m] + u(s))
```

where `w_m` is the proportion of total sampled camera-days in month `m`. This
keeps the annual spatial pattern aligned with the months that were actually
sampled in each camera dataset.

The mapped central estimate is the posterior mean because the reported target
is an expected encounter rate. Posterior-SD maps are included as the matching
uncertainty maps.

## Repository Layout

```text
CameraSpatialEncounterSurfaces2023_2024/
  README.md
  data/
    README.md
  docs/
    final-model-details.md
  results/
    README.md
    road_2023/
    forest_2024/
    road_2024/
  scripts/
    wolf_2023_nb_month_split_workflow.R
    wolf_forest_month_refit.R
    wolf_2024_zinb_month_split_workflow.R
    wolf_relative_frequency_inla_helpers.R
```

Raw camera-trap CSV files are not committed here. The `data/README.md` file
lists the expected input files and where to place them for reproduction.

## Main Scripts

### Road-Camera 2023 Final Model

```sh
Rscript scripts/wolf_2023_nb_month_split_workflow.R
```

Final model:

- likelihood: negative binomial;
- spatial component: INLA-SPDE spatial random field;
- temporal component: calendar-month fixed effects;
- effort component: active camera-days are included as exposure;
- map target: effort-weighted annualized 2023 surface;
- priors: weakly informative Gaussian and PC priors.

### Forest-Camera 2024 Final Model

```sh
Rscript scripts/wolf_forest_month_refit.R
```

Final model:

- likelihood: negative binomial;
- spatial component: INLA-SPDE spatial random field;
- temporal component: calendar-month fixed effects;
- effort component: active camera-days are included as exposure;
- map target: effort-weighted annualized 2024 surface;
- priors: weakly informative Gaussian and PC priors.

### Road-Camera 2024 Final Model

```sh
Rscript scripts/wolf_2024_zinb_month_split_workflow.R
```

Final model:

- likelihood: zero-inflated negative binomial type 1;
- spatial component: INLA-SPDE spatial random field;
- temporal component: calendar-month fixed effects;
- effort component: active camera-days are included as exposure;
- map target: effort-weighted annualized 2024 surface;
- priors: weakly informative Gaussian and PC priors, including a weakly
  informative zero-inflation prior.

## Runtime Profiles

All workflows use the `WOLF_RUN_PROFILE` environment variable:

```sh
# Fast development run
WOLF_RUN_PROFILE=quick

# Recommended reproducible analysis
WOLF_RUN_PROFILE=balanced

# Heavier final run with more posterior simulations
WOLF_RUN_PROFILE=final
```

On Windows PowerShell, for example:

```powershell
$env:WOLF_RUN_PROFILE = "balanced"
& "C:\Program Files\R\R-4.5.2\bin\Rscript.exe" scripts\wolf_2024_zinb_month_split_workflow.R
```

Path overrides are available:

```powershell
$env:WOLF_PROJECT_DIR = "C:\path\to\CameraSpatialEncounterSurfaces2023_2024"
$env:WOLF_DATA_DIR = "C:\path\to\CameraSpatialEncounterSurfaces2023_2024\data"
$env:WOLF_OUTPUT_DIR = "C:\path\to\outputs"
```

## Key Results

"Required diagnostics pass" refers to a specific gate: camera-level posterior
predictive checks (total events, zero fraction, max count) plus residual
Moran's I. PIT KS p-values are reported for every model as a supporting
calibration diagnostic but are not part of this gate, since PIT KS is
sensitive to camera-level clustering and small-count discreteness in ways
that do not track distortion of the mapped spatial surface. See
`docs/final-model-details.md` for the full rationale.

### Road-Camera 2023

The corrected negative-binomial spatial-month model passes the required
diagnostics:

- posterior predictive camera total events: pass;
- posterior predictive camera zero fraction: pass;
- posterior predictive camera maximum count: pass;
- residual Moran's I: `I = -0.004`, `p = 0.492`;
- row PIT KS p-value: `0.1019`;
- temporal residual autocorrelation: within-camera lag-1 `r = 0.017`,
  `p = 0.7281`; no evidence of residual autocorrelation;
- spatial block cross-validation: row 90 percent coverage `0.96`, camera
  90 percent coverage `0.95`; acceptable;
- mesh sensitivity: WAIC and hyperparameter estimates are stable across the
  final, finer, and coarser mesh variants (delta WAIC `0.00` to `0.24`; WAIC
  range `1162.81` to `1163.05`);
- prior sensitivity: WAIC, DIC, and posterior hyperparameter estimates are
  stable across 6 prior variants (delta WAIC `0.00` to `0.76`). This checks
  fit/hyperparameter stability, not a full rerun of the required PPC/Moran's
  I diagnostic gate; see `docs/final-model-details.md` for detail.

Model comparison shows ZINB is only marginally lower by WAIC, with low estimated
zero inflation, so the NB model is retained for parsimony:

| Model | WAIC | Delta WAIC |
| --- | ---: | ---: |
| ZINB spatial-month | 1162.65 | 0.00 |
| NB spatial-month | 1162.90 | 0.25 |
| Poisson spatial-month | 1303.06 | 140.41 |

### Forest-Camera 2024

The final negative-binomial spatial-month model passes the required
diagnostics:

- posterior predictive row and camera total events: pass;
- posterior predictive row and camera zero fraction: pass;
- posterior predictive row and camera maximum count: pass;
- residual Moran's I: `I = -0.035`, `p = 0.691`;
- PIT KS p-values: row `0.7938`, camera `0.5125`;
- temporal residual autocorrelation: within-camera lag-1 `r = -0.046`,
  `p = 0.4211`; no evidence of residual autocorrelation. The month-level lag-1
  ACF is `0.144` and is retained as a low-power supporting check;
- spatial block cross-validation: row 90 percent coverage `0.978`, camera
  90 percent coverage `0.925`; acceptable;
- mesh sensitivity: final, finer, and coarser mesh variants pass required
  diagnostics; WAIC range `269.49` to `270.42`;
- prior sensitivity: all 12 variants pass required diagnostics (this
  survey's sensitivity loop genuinely recomputes the full diagnostic gate
  per variant, unlike the two road-camera scripts below).

The main caveat is low information content: 46 independent wolf events, so
month and spatial effects have wider uncertainty.

### Road-Camera 2024

The corrected zero-inflated negative-binomial spatial-month model passes the
required posterior-predictive and spatial diagnostics. The residual temporal
diagnostic is retained as a caution:

- posterior predictive camera total events: pass;
- posterior predictive camera zero fraction: pass;
- posterior predictive camera maximum count: pass;
- residual Moran's I: `I = -0.034`, `p = 0.384`;
- row PIT KS p-value: `0.08442`;
- temporal residual autocorrelation: within-camera lag-1 `r = -0.179`,
  `p = 0.002523`; residual deployment-order temporal structure remains
  detectable. The originally hypothesized mechanism (staggered deployment
  timing correlated with camera location) was tested directly: a Spearman
  correlation of deployment start day-of-year against UTM northing gives
  `rho = 0.058`, `p = 0.280` (n = 344) — not a meaningful correlation, so it
  does not explain the residual autocorrelation, and no specific mechanism is
  claimed (see `docs/final-model-details.md`). Judged not to distort the
  mapped spatial surface because the spatial field is fit net of the month
  effect and spatial block cross-validation and mesh sensitivity remain
  stable;
- spatial block cross-validation: row 90 percent coverage `0.96`, camera
  90 percent coverage `0.93`; acceptable;
- mesh sensitivity: WAIC and hyperparameter estimates are stable across the
  final, finer, and coarser mesh variants (delta WAIC `0.00` to `0.32`; WAIC
  range `933.32` to `933.64`);
- prior sensitivity: WAIC, DIC, and posterior hyperparameter estimates are
  stable across the retained prior variants (delta WAIC `0.00` to `0.50`).
  This checks fit/hyperparameter stability, not a full rerun of the required
  PPC/Moran's I diagnostic gate; see `docs/final-model-details.md` for detail.

Model comparison supports the ZINB model:

| Model | WAIC | Delta WAIC |
| --- | ---: | ---: |
| ZINB spatial-month | 933.64 | 0.00 |
| NB spatial-month | 937.32 | 3.68 |
| Poisson spatial-month | 997.30 | 63.66 |

## Outputs Included Here

Across the final-results folders, the curated outputs include:

- final validation report;
- posterior predictive checks;
- hyperparameter summaries;
- month-effect summaries;
- prior sensitivity reports and tables;
- mesh sensitivity reports and tables for all three analyses;
- model-comparison report and table for the road-camera models;
- spatial block cross-validation summaries;
- temporal residual diagnostics;
- posterior mean encounter-frequency map as PNG and GeoTIFF;
- posterior-SD uncertainty map as PNG and GeoTIFF.

The full generated output folders also contain exploratory plots, full
prediction grids, and additional intermediate diagnostics. Those full scratch
archives are not part of the curated GitHub result set.

## Required R Packages

- `readr`
- `dplyr`
- `tidyr`
- `sf`
- `terra`
- `ggplot2`
- `viridis`
- `scales`
- `INLA`

The scripts do not install packages automatically unless explicitly changed by
the user. INLA usually requires installing from the INLA repository.

## Reproducibility

INLA results can shift across package versions and INLA builds, and this
repository does not pin one. To make a specific run reproducible:

- Run `Rscript scripts/capture_session_info.R` in the same R environment used
  for a final run and commit the resulting `results/session_info.txt`. It
  records `sessionInfo()` plus the exact INLA package version and build.
- For a fuller environment pin, initialize [`renv`](https://rstudio.github.io/renv/)
  in this project (`renv::init()`) and commit the generated `renv.lock`.

A small synthetic sample dataset is included under `data/sample/` (see
`data/README.md`) so the pipeline can be run end-to-end without the private
survey CSVs, for structural checks rather than reproducing the reported
results.
