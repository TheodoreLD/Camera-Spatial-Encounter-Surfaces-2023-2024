# Final Model Details

This note gives a compact technical description of the three final 2023-2024
wolf relative encounter-frequency models. All numbers below are from a
`WOLF_RUN_PROFILE=final` rerun of the three scripts against the private
camera-trap data, and match the files committed under `results/`.

## Common Modelling Target

The response is an independent wolf event count. The exposure is camera effort
in camera-days. INLA receives effort through `E`, so the linear predictor
describes the expected daily encounter rate and map outputs are converted to
expected events per 100 camera-days.

The models estimate relative encounter frequency, not abundance, density,
occupancy, or population size.

For camera-month row `i`, the common model structure is:

```text
log(mu_i) = log(E_i) + beta_0 + gamma[m_i] + u(s_i)
```

where `mu_i` is the expected event count, `E_i` is active camera-days,
`beta_0` is the model intercept on the log encounter-rate scale, `gamma[m_i]`
is the fixed effect for calendar month, and `u(s_i)` is the INLA-SPDE spatial
random field at the camera location.

## Data Units

All final models use camera-month rows:

1. A camera deployment is split when it crosses a calendar-month boundary.
2. The effort assigned to a row is the number of active camera-days inside that
   camera-month interval.
3. Wolf events are assigned by `eventStart` month.
4. The model includes calendar-month fixed effects as a temporal control and a
   spatial SPDE field.

This avoids mixing September and October effort/events in deployments that
cross month boundaries.

Month enters the model as a fixed effect, but the final mapped quantity is not
a single-month prediction. The maps report an effort-weighted annualized
survey-year surface:

```text
lambda_year(s) = sum_m w_m * 100 * exp(beta_0 + gamma[m] + u(s))
```

where `w_m` is the proportion of sampled camera-days in month `m`. This keeps
month in the model as a temporal control while reporting the spatial pattern
for the sampled survey-year period as a whole.

Month is treated as a fixed effect in the final models.

## Diagnostic Gate

"Required posterior-predictive/spatial diagnostics pass" below refers to a
specific gate: the camera-level posterior predictive checks (total events,
zero fraction, max count) and the residual Moran's I spatial-autocorrelation
test (a two-sided permutation test, scaled by `WOLF_RUN_PROFILE`, in all three
scripts). A model is only called final if it clears this gate.

PIT (probability integral transform) KS p-values are also computed and
reported for every model, but they are supporting diagnostics, not part of
the gate. PIT KS is sensitive to camera-level clustering and small-count
discreteness in ways that do not track whether the mapped spatial surface
itself is distorted, so a low PIT KS p-value is reported but is not on its
own treated as disqualifying. This is why, for example, the road-camera 2023
model reports "required diagnostics pass: TRUE" alongside a camera PIT KS
p-value near 0.001: the low PIT KS value is retained and shown, not silently
dropped, but it does not gate the pass/fail call.

## Road-Camera 2023 Model

Final script:

```text
scripts/wolf_2023_nb_month_split_workflow.R
```

Final output folder:

```text
results/road_2023/
```

Model:

```text
y_i ~ NegativeBinomial(mu_i, size)
log(mu_i) = log(effort_i) + intercept + month_i + spatial(s_i)
```

Key settings:

- 490 camera-month rows;
- 60 cameras;
- 586 independent wolf events;
- 5222.2 camera-days;
- observed mean encounter frequency: 11.221 events per 100 camera-days;
- effort component: active camera-days are included as exposure;
- map target: effort-weighted annualized 2023 surface;
- annualization factor used in map aggregation: 1.117;
- INLA-SPDE spatial random field;
- negative-binomial likelihood.

Weakly informative priors:

- intercept: Gaussian(mean = -2.187, SD 2.5 on log scale), centered on the
  crude observed daily rate;
- month log-rate ratios: Gaussian(0, SD 1);
- negative-binomial log(size): Gaussian(log(2), SD 2);
- spatial range: PC prior, `P(range < 5000 m) = 0.5`;
- spatial marginal SD: PC prior, `P(SD > 2.0) = 0.05`.

Model comparison:

| Model | WAIC | Delta WAIC |
| --- | ---: | ---: |
| ZINB spatial-month | 1162.65 | 0.00 |
| NB spatial-month | 1162.90 | 0.25 |
| Poisson spatial-month | 1303.06 | 140.41 |

ZINB is only marginally lower by WAIC and has a low estimated zero-inflation
probability (mean 0.032), so the negative-binomial spatial-month model is
retained for parsimony.

Main diagnostics:

- posterior predictive camera total events: pass;
- posterior predictive camera zero fraction: pass;
- posterior predictive camera maximum count: pass;
- row Pearson dispersion: 0.665;
- camera Pearson dispersion: 0.292;
- residual Moran's I: -0.004 (expected -0.017), two-sided p = 0.492;
- row PIT KS p-value: 0.1019;
- camera PIT KS p-value: 0.001507;
- negative-binomial size posterior mean: 1.708;
- temporal residual autocorrelation: within-camera lag-1 r = 0.017,
  p = 0.7281 (n = 430 pairs); no evidence of residual temporal
  autocorrelation;
- date-ordered mean-residual lag-1 ACF: -0.176;
- required posterior-predictive/spatial diagnostics pass: TRUE;
- spatial block cross-validation: row 90 percent coverage = 0.96, camera 90
  percent coverage = 0.95;
- prior sensitivity: WAIC, DIC, and posterior hyperparameter estimates (NB
  size, spatial range, spatial SD) are stable across 6 prior variants
  (WAIC 1162.80 to 1163.56; delta WAIC 0.00 to 0.76). This checks
  fit/hyperparameter stability, not a full rerun of the required PPC/Moran's
  I diagnostic gate: unlike the forest-camera model, this script's
  prior/mesh sensitivity loop does not recompute `diagnostics_ok` per
  variant;
- mesh sensitivity: WAIC and hyperparameter estimates are stable across the
  final, finer, and coarser mesh variants (WAIC 1162.81 to 1163.05; delta
  WAIC 0.00 to 0.24), on the same basis as above.

Exploratory check: a Spearman correlation of deployment start day-of-year
against UTM northing (`results/road_2023/wolf_2023_exploratory_timing_vs_northing.csv`)
gives rho = 0.042, p = 0.357 (n = 490) -- deployment timing is not
meaningfully correlated with camera location in this survey.

## Forest-Camera 2024 Model

Final script:

```text
scripts/wolf_forest_month_refit.R
```

Final output folder:

```text
results/forest_2024/
```

Model:

```text
y_i ~ NegativeBinomial(mu_i, size)
log(mu_i) = log(effort_i) + intercept + month_i + spatial(s_i)
```

Key settings:

- 356 camera-month rows;
- 53 cameras;
- 46 independent wolf events;
- 4423.0 camera-days;
- observed mean encounter frequency: 1.040 events per 100 camera-days;
- effort component: active camera-days are included as exposure;
- map target: effort-weighted annualized 2024 surface;
- INLA-SPDE spatial random field;
- negative-binomial likelihood.

Weakly informative priors:

- intercept: Gaussian centered on crude observed daily rate, SD 2.5 on log
  scale;
- month log-rate ratios: Gaussian(0, SD 1);
- negative-binomial log(size): Gaussian(log(2), SD 2);
- spatial range: PC prior, `P(range < 1000 m) = 0.5`;
- spatial marginal SD: PC prior, `P(SD > 1.5) = 0.05`.

Fitted hyperparameters:

- negative-binomial size posterior mean: 1.836;
- spatial range posterior mean: 584.1 m;
- spatial SD posterior mean: 0.816.

Month effects (rate ratio vs. reference month 2024-08):

- 2024-03: 0.34 (95% CrI 0.08 to 1.47);
- 2024-04: 0.65 (95% CrI 0.22 to 1.92);
- 2024-05: 0.91 (95% CrI 0.36 to 2.31);
- 2024-06: 1.69 (95% CrI 0.74 to 3.79);
- 2024-07: 1.28 (95% CrI 0.53 to 3.07);
- 2024-09: 0.67 (95% CrI 0.23 to 1.99).

Main diagnostics:

- posterior predictive row and camera total events: pass;
- posterior predictive row and camera zero fraction: pass;
- posterior predictive row and camera maximum count: pass;
- row Pearson dispersion: 0.584;
- camera Pearson dispersion: 0.614;
- residual Moran's I: -0.035, two-sided p = 0.691;
- row PIT KS p-value: 0.7938;
- camera PIT KS p-value: 0.5125;
- required posterior-predictive/spatial diagnostics pass: TRUE;
- temporal residual autocorrelation: within-camera lag-1 r = -0.046,
  p = 0.4211 (n = 303 pairs); no evidence of residual autocorrelation. The
  month-level lag-1 ACF is 0.144 and is retained as a low-power supporting
  check because only seven monthly time points are available;
- spatial block cross-validation: row 90 percent coverage = 0.978, camera
  90 percent coverage = 0.925. This survey's cross-validation builds its
  SPDE mesh from train-fold camera locations only, and simulates held-out
  counts from full joint posterior samples, matching the road-camera
  2023/2024 scripts' CV methodology exactly (both were previously
  lower-fidelity in this script and have been fixed and verified against
  this rerun);
- prior sensitivity: all 12 variants pass required diagnostics (WAIC 269.49
  to 276.75; best variant `month_sd_0_5`, WAIC 269.49; final-current variant
  WAIC 270.21). Unlike the road-camera scripts, this survey's sensitivity
  loop recomputes the full PPC/Moran's I diagnostic gate independently for
  each variant;
- mesh sensitivity: final, finer, and coarser mesh variants all pass
  required diagnostics; WAIC range = 269.49 to 270.42.

Main limitation:

The forest-camera dataset contains only 46 independent wolf events. The final
model is valid for relative encounter-frequency mapping, but month and spatial
effects should be interpreted with wide uncertainty.

## Road-Camera 2024 Model

Final script:

```text
scripts/wolf_2024_zinb_month_split_workflow.R
```

Final output folder:

```text
results/road_2024/
```

Model:

```text
y_i ~ ZeroInflatedNegativeBinomial1(mu_i, size, pi)
log(mu_i) = log(effort_i) + intercept + month_i + spatial(s_i)
```

`ZeroInflatedNegativeBinomial1` is INLA's type-1 zero-inflated negative-binomial
parameterization. The parameter `pi` represents additional structural-zero
probability, while the negative-binomial component models overdispersed event
counts through `mu_i` and `size`.

Key settings:

- 344 camera-month rows;
- 60 cameras;
- 479 independent wolf events;
- 3574.0 camera-days;
- observed mean encounter frequency: 13.402 events per 100 camera-days;
- effort component: active camera-days are included as exposure;
- map target: effort-weighted annualized 2024 surface;
- annualization factor used in map aggregation: 1.195;
- INLA-SPDE spatial random field;
- zero-inflated negative-binomial type 1 likelihood.

Weakly informative priors:

- intercept: Gaussian(mean = -2.010, SD 2.5 on log scale), centered on the
  crude observed daily rate;
- month log-rate ratios: Gaussian(0, SD 1);
- zero-inflation logit probability: Gaussian(mean = -2.94, SD approximately
  1.5 on logit scale);
- negative-binomial log(size): Gaussian(log(2), SD 2);
- spatial range: PC prior, `P(range < 5000 m) = 0.5`;
- spatial marginal SD: PC prior, `P(SD > 2.5) = 0.05`.

Model comparison:

| Model | WAIC | Delta WAIC |
| --- | ---: | ---: |
| ZINB spatial-month | 933.64 | 0.00 |
| NB spatial-month | 937.32 | 3.68 |
| Poisson spatial-month | 997.30 | 63.66 |

Main diagnostics:

- posterior predictive camera total events: pass;
- posterior predictive camera zero fraction: pass;
- posterior predictive camera maximum count: pass;
- row Pearson dispersion: 0.589;
- camera Pearson dispersion: 0.232;
- residual Moran's I: -0.034 (expected -0.017), two-sided p = 0.384;
- row PIT KS p-value: 0.08442;
- camera PIT KS p-value: 0.0008276;
- zero-inflation probability posterior mean: 0.075;
- negative-binomial size posterior mean: 3.622;
- required posterior-predictive/spatial diagnostics pass: TRUE;
- temporal residual autocorrelation: within-camera lag-1 r = -0.179,
  p = 0.002523 (n = 284 pairs); residual deployment-order temporal structure
  remains detectable;
- date-ordered mean-residual lag-1 ACF: 0.252;
- mechanism check: the residual lag-1 autocorrelation was originally
  hypothesized to reflect staggered deployment timing correlated with camera
  location. That hypothesis was tested directly: a Spearman correlation of
  deployment start day-of-year against UTM northing
  (`results/road_2024/wolf_2024_exploratory_timing_vs_northing.csv`) gives
  rho = 0.058, p = 0.280 (n = 344) -- not a meaningful correlation, so this
  does not explain the residual autocorrelation. The actual mechanism is not
  identified. This is judged not to distort the mapped spatial surface
  because the spatial field `u(s)` is fit jointly with, and net of, the
  month effect, and spatial block cross-validation coverage (camera 90
  percent coverage = 0.93) and mesh sensitivity both remain stable; the
  residual structure is retained as an open temporal caution rather than
  corrected further, since its cause is not established;
- spatial block cross-validation: row 90 percent coverage = 0.96, camera 90
  percent coverage = 0.93;
- prior sensitivity: WAIC, DIC, and posterior hyperparameter estimates are
  stable across the retained prior variants (WAIC 933.40 to 933.89; delta
  WAIC 0.00 to 0.50). This checks fit/hyperparameter stability, not a full
  rerun of the required PPC/Moran's I diagnostic gate: unlike the
  forest-camera model, this script's prior/mesh sensitivity loop does not
  recompute `diagnostics_ok` per variant;
- mesh sensitivity: WAIC and hyperparameter estimates are stable across the
  final, finer, and coarser mesh variants (WAIC 933.32 to 933.64; delta WAIC
  0.00 to 0.32), on the same basis as above.

## Final Interpretation

All three models are final for relative encounter-frequency mapping. The
road-camera 2023 model passes the required diagnostics after the camera-month
temporal correction, shows no evidence of residual temporal autocorrelation,
and is retained as a parsimonious NB model. The forest-camera 2024 model
passes the required diagnostics, and its prior/mesh sensitivity variants
independently re-verify that same diagnostic gate. The road-camera 2024 model
passes the required posterior-predictive and spatial diagnostics; its prior
and mesh sensitivity checks show stable WAIC and hyperparameters across
variants but (like road-camera 2023) do not re-verify the full diagnostic
gate per variant, and its spatial block cross-validation coverage is
acceptable. Its significant within-camera lag-1 residual correlation is
retained as an open temporal caution: the originally hypothesized
deployment-timing-versus-location mechanism was checked directly against the
final data and is not supported (Spearman rho = 0.058, p = 0.280), so no
specific mechanism is claimed.
