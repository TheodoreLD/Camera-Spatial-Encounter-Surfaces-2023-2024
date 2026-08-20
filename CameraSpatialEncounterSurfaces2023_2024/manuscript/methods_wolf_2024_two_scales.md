# Methods Text: 2024 Wolf Encounter-Frequency Surfaces At Two Spatial Scales

Draft manuscript methods text for an article that uses **both** 2024 wolf
surfaces produced in this repository:

- the **landscape-scale** surface from the road-camera 2024 survey
  (`results/road_2024/`, 60 cameras over a ~26 x 37 km extent), and
- the **local-scale** surface from the forest-camera 2024 survey
  (`results/forest_2024/`, 53 cameras over a ~8.9 x 8.3 km extent nested
  inside the road-camera extent).

Every number below is taken from the committed `WOLF_RUN_PROFILE=final`
results and from the runner/library configuration; see the
[project README](../README.md) for the full diagnostic tables. Section
numbering is placeholder — renumber to match the target journal. Bracketed
`[...]` items are the few details that live outside this repository (study
area name, detection-independence interval, camera model, spacing/design)
and must be filled in by the authors.

---

## Full version

### 2.1 Camera-trap sampling

Wolf (*Canis lupus*) detections were obtained from two camera-trap surveys run
in 2024 in [study area, country], designed to characterise wolf space use at
two contrasting spatial scales. The **road-camera survey** deployed 60 cameras
along forest roads and tracks across the wider landscape (August–October 2024;
3,574.0 active camera-days). The **forest-camera survey** deployed 53 cameras
inside a focal forest block nested within the road-camera extent, at an
off-road, within-stand placement (March–September 2024; 4,423.0 active
camera-days). Cameras were [model], set to [trigger/burst settings], and
[describe placement rule, height, spacing, and whether stations were baited or
lured — wolf surveys should state this explicitly].

Images were classified to species and grouped into detection events; an event
is the unit of independence used throughout, identified by the unique event
identifier assigned during classification [state the independence interval used
to close an event, e.g. 30 min of inactivity]. Each event was counted once per
camera. The road-camera survey yielded 479 independent wolf events and the
forest-camera survey 46.

### 2.2 Response variable, effort, and data units

Both surveys were analysed with an identical modelling pipeline, applied
separately to each survey. Deployments were split at every calendar-month
boundary they crossed, so the analytical unit is a **camera-month row**: for
each camera and each calendar month, the number of independent wolf events
recorded, together with the number of active camera-days accumulated by that
camera within that month. Events were assigned to the row whose month contained
the event start timestamp. This yielded 344 camera-month rows for the
road-camera survey and 356 for the forest-camera survey.

Active camera-days entered the model as an exposure offset, so the linear
predictor describes an expected per-day encounter rate and all mapped outputs
are expressed as expected independent wolf events per 100 camera-days. Encounter
rate is used here as a relative-abundance index in the sense of Rowcliffe et al.
(2008) and O'Brien (2011); because detection probability was not estimated, the
surfaces must not be read as abundance, density, occupancy, or population size.

Camera coordinates were projected to WGS 84 / UTM zone 34N (EPSG:32634) for all
spatial computation and mapping.

### 2.3 Spatial model

For camera-month row *i*, the expected event count `mu_i` was modelled as

```
log(mu_i) = log(E_i) + beta_0 + gamma[m_i] + u(s_i)
```

where `E_i` is active camera-days in that row, `beta_0` is the intercept on the
log encounter-rate scale, `gamma[m_i]` is a fixed effect for calendar month, and
`u(s)` is a continuous spatial random field. The field was given a Matérn
covariance (smoothness `alpha = 2`) and represented as a Gaussian Markov random
field on a triangulated mesh via the stochastic partial differential equation
approach (Lindgren, Rue & Lindström 2011). Models were fitted by integrated
nested Laplace approximation rather than MCMC (Rue, Martino & Chopin 2009).

The two surveys differ in observation model and in mesh and grid resolution,
both chosen for their own data and scale:

- **Road-camera 2024 (landscape scale).** A zero-inflated negative-binomial
  (INLA type 1) likelihood was used, modelling structural zeros separately from
  count-process zeros (Martin et al. 2005) on top of a negative-binomial count
  component that absorbs overdispersion (Hilbe 2011). The mesh used a 200 m
  cutoff, maximum inner/outer edge lengths of 400 m and 3,000 m, and inner/outer
  offsets of 4,000 m and 12,000 m (19,099 vertices).
- **Forest-camera 2024 (local scale).** A negative-binomial likelihood was used.
  Because wolf activity within the forest block is structured at a much finer
  scale, the mesh was correspondingly finer: 75 m cutoff, maximum inner/outer
  edge lengths of 150 m and 900 m, and inner/outer offsets of 1,200 m and
  4,000 m (6,770 vertices).

In both models the month effect and the spatial field were estimated jointly, so
the mapped field is net of the seasonal signal.

### 2.4 Priors

All priors were weakly informative. The intercept was Gaussian with SD 2.5 on
the log scale, centred on each survey's crude observed daily rate (road-camera
mean −2.010; forest-camera mean −4.566). Month log rate-ratios were Gaussian(0,
SD 1) and the negative-binomial log size Gaussian(log 2, SD 2). For the
road-camera model the zero-inflation probability had a Gaussian prior on the
logit scale (mean −2.94, SD ≈ 1.5). The two Matérn hyperparameters were given
penalised-complexity priors (Simpson et al. 2017; Fuglstad et al. 2019), scaled
to each survey's expected spatial scale: road-camera `P(range < 5,000 m) = 0.5`
and `P(sigma > 2.5) = 0.05`; forest-camera `P(range < 1,000 m) = 0.5` and
`P(sigma > 1.5) = 0.05`.

Prior influence was assessed by refitting each final model under six perturbed
prior sets. WAIC, DIC, and the posterior hyperparameters were stable throughout
(road-camera WAIC 933.42–933.89; forest-camera 269.54–277.26), indicating that
the posteriors are likelihood- rather than prior-driven.

### 2.5 Model selection

For each survey, Poisson, negative-binomial, and zero-inflated negative-binomial
versions of the same spatial-month model were compared by WAIC (Watanabe 2010),
cross-checked against DIC (Spiegelhalter et al. 2002), with a 2-unit parsimony
margin. For the road-camera survey the zero-inflated negative-binomial model was
clearly preferred (WAIC 933.64, versus 937.31 for negative-binomial and 997.30
for Poisson); its posterior mean structural-zero probability was 0.063. For the
forest-camera survey the negative-binomial model was preferred (WAIC 270.22,
versus 270.51 for zero-inflated negative-binomial and 274.02 for Poisson), the
zero-inflated variant offering no meaningful gain (ΔWAIC 0.29) and Poisson being
rejected.

### 2.6 Model validation

Each final model had to clear the same pre-specified gate: camera-level
posterior predictive checks of total events, zero fraction, and maximum count
(Gelman, Meng & Stern 1996; 1,500 simulations from the joint posterior), and a
two-sided permutation test of Moran's *I* on model residuals (999 permutations;
Moran 1950; Dormann et al. 2007). Both 2024 models passed: residual Moran's *I*
was −0.036 (p = 0.335) for the road-camera model and −0.041 (p = 0.590) for the
forest-camera model, and all posterior predictive checks passed.

Out-of-sample performance was assessed by spatial block cross-validation
(Roberts et al. 2017): cameras were grouped into five spatially compact folds by
k-means clustering of their standardised coordinates, each fold was held out in turn, and the
SPDE mesh was rebuilt from the training cameras alone so that no held-out
location informed the training mesh. Held-out counts were simulated from 600
full joint posterior draws. Nominal 90% predictive intervals achieved 0.96 (row)
and 0.93 (camera) coverage for the road-camera model and 0.98 and 0.92 for the
forest-camera model.

Probability-integral-transform calibration (Czado, Gneiting & Held 2009),
Pearson dispersion, mesh sensitivity (a finer and a coarser mesh variant), and
within-camera lag-1 residual temporal correlation were computed as supporting
diagnostics. Mesh resolution had negligible influence on either model (WAIC
range 933.33–933.64 across road-camera variants of 10,022–35,378 vertices, and
269.49–270.21 across forest-camera variants).

### 2.7 Prediction and mapping

Predictions were made on a regular grid over the buffered (1,500 m) convex hull
of each survey's cameras, at a resolution matched to that survey's spatial
scale: 150 m cells over a ~26 x 37 km extent for the road-camera surface and
60 m cells over a ~8.9 x 8.3 km extent for the forest-camera surface.

Because month is a fixed effect but the maps are not month-specific, each
survey's fitted monthly rates were combined into a single effort-weighted
surface over that survey's own sampled months:

```
lambda(s) = sum_m w_m * 100 * exp(beta_0 + gamma[m] + u(s))
```

where `w_m` is the share of that survey's total camera-days falling in month
*m*. Expressed relative to the August 2024 reference month, this gives a scaling
factor of 1.195 for the road-camera surface (August–October) and 1.035 for the
forest-camera surface (March–September).

At each grid cell, INLA returns the posterior mean and SD of the linear
predictor, `eta(s) ~ N(eta_mean(s), eta_sd(s)^2)`. Three surfaces were derived
per survey using the log-normal moment relations:

```
mean(s) = f * 100 * exp(eta_mean(s) + 0.5 * eta_sd(s)^2)
cv(s)   = sqrt(exp(eta_sd(s)^2) - 1)
sd(s)   = mean(s) * cv(s)
```

with `f` the survey's effort-weighting factor above. The posterior mean surface
is the central estimate; the CV surface, being independent of the local rate's
magnitude, is used to identify where the estimate is data-driven rather than
reverting to the fixed-effect baseline. Figures are displayed with the colour
scale capped at each surface's 98th percentile, so mapped peaks are understated
relative to the underlying rasters; all quantitative statements use the uncapped
GeoTIFFs.

### 2.8 Comparing the two scales

The estimated Matérn range — the distance over which camera data inform the
field — differs by roughly sevenfold between the two surfaces: 4,175 m (95% CrI
2,007–7,618 m) for the road-camera surface and 584 m (95% CrI 150–1,599 m) for
the forest-camera surface. The posterior spatial SD was 0.96 (95% CrI
0.70–1.28) and 0.82 (95% CrI 0.39–1.45) respectively. The two surfaces are
therefore treated as complementary rather than redundant: the road-camera
surface resolves landscape-scale gradients in wolf encounter frequency across
the study area, while the forest-camera surface resolves within-block structure
that the landscape surface smooths over. [State here how the two were used
together in your analysis — e.g. whether local-scale hotspots fall inside
landscape-scale high-use areas, or the specific comparison the article makes.]

Three limitations constrain how the two surfaces may be compared. First, they
rest on different observation models (zero-inflated negative-binomial versus
negative-binomial), each selected on its own data, so absolute rates do not
share a common likelihood. Second, they cover different parts of the year
(August–October versus March–September) and the annualised surfaces are weighted
over those different month sets. Third, the two camera arrays sample different
detection contexts — road and track placements versus off-road within-stand
placements — and camera-trap encounter rates are known to be strongly placement
dependent. Comparisons between the two scales are therefore made on relative
spatial pattern and standardised values, not on differences in raw events per
100 camera-days.

Two further caveats attach to the individual surfaces. The road-camera model
retains a detectable within-camera lag-1 residual temporal correlation
(r = −0.181, p = 0.002, n = 284 pairs); the hypothesised mechanism, staggered
deployment timing correlated with camera position, was tested and rejected
(Spearman rho of deployment start day-of-year against UTM northing = 0.058,
p = 0.280, n = 344), so no mechanism is established. Because the spatial field is
fitted jointly with and net of the month effect, and both cross-validation
coverage and mesh sensitivity are stable, this is reported as an open temporal
caution that does not appear to distort the mapped spatial surface. The
forest-camera model rests on only 46 independent wolf events, so posterior
credible intervals on its month and spatial effects are wide (for example, the
spatial range spans 150–1,599 m); the surface remains valid for relative
encounter-frequency mapping, but its month and spatial effects should be read
with that uncertainty in mind.

### 2.9 Software

All analyses were run in R 4.5.2 with R-INLA 25.10.19, using `sf` for spatial
data handling and `terra` for raster output. Both surveys were produced by a
single shared analysis library driven by one thin runner per survey, so the
workflow, diagnostics, and outputs are identical across scales; only the
likelihood, priors, mesh and grid resolution, and input paths differ. Code and
curated results are available at [repository DOI / URL]; raw camera-trap data
are archived at [data availability statement].

---

## Condensed version (~350 words, for a short-format methods section)

Wolf detections came from two 2024 camera-trap surveys in [study area] designed
to capture two spatial scales: a landscape-scale road-camera array (60 cameras,
August–October 2024, 3,574.0 camera-days, 479 independent wolf events) and a
local-scale forest-camera array (53 cameras, March–September 2024, 4,423.0
camera-days, 46 events) nested within it. Deployments were split at calendar
month boundaries, giving camera-month rows (344 and 356 respectively) with
active camera-days as exposure; independent detection events were the response.

Each survey was analysed separately with the same Bayesian spatial model, fitted
by integrated nested Laplace approximation (Rue et al. 2009):
`log(mu_i) = log(E_i) + beta_0 + gamma[m_i] + u(s_i)`, where `gamma[m]` is a
calendar-month fixed effect and `u(s)` a Matérn spatial random field represented
through the SPDE approach (Lindgren et al. 2011) with penalised-complexity
priors (Simpson et al. 2017; Fuglstad et al. 2019). All other priors were weakly
informative. Candidate Poisson, negative-binomial, and zero-inflated
negative-binomial likelihoods were compared by WAIC: the road-camera data
selected zero-inflated negative-binomial (ΔWAIC 3.67 over negative-binomial) and
the forest-camera data negative-binomial. Mesh and prediction resolution were
matched to scale (road: 200 m cutoff, 400/3,000 m maximum edges, 150 m grid;
forest: 75 m cutoff, 150/900 m maximum edges, 60 m grid), each predicted over
the 1,500 m-buffered convex hull of its cameras in UTM zone 34N.

Both models passed a pre-specified diagnostic gate of camera-level posterior
predictive checks and a permutation test of residual Moran's *I* (road
*I* = −0.036, p = 0.335; forest *I* = −0.041, p = 0.590), with five-fold spatial
block cross-validation (mesh rebuilt per fold) giving 90% interval coverage of
0.93–0.98, and stable WAIC under perturbed priors and meshes. Fitted month
effects were combined into effort-weighted surfaces over each survey's sampled
months and back-transformed on the log-normal scale to posterior mean, SD, and
CV maps of expected wolf events per 100 camera-days. The estimated spatial range
was 4,175 m (95% CrI 2,007–7,618) for the landscape surface and 584 m (150–1,599)
for the local surface. Surfaces index relative encounter frequency, not
abundance or density, and were compared across scales on relative spatial
pattern rather than absolute rates, given their different likelihoods, sampled
months, and camera placement contexts.

---

## Parameter summary table (for a supplementary table)

| Parameter | Road-camera 2024 (landscape) | Forest-camera 2024 (local) |
| --- | --- | --- |
| Cameras | 60 | 53 |
| Sampled months | Aug–Oct 2024 | Mar–Sep 2024 |
| Camera-month rows | 344 | 356 |
| Independent wolf events | 479 | 46 |
| Effort (camera-days) | 3,574.0 | 4,423.0 |
| Observed rate / 100 camera-days | 13.402 | 1.040 |
| Likelihood | Zero-inflated negative-binomial (type 1) | Negative-binomial |
| WAIC (selected / next best) | 933.64 / 937.31 (NB) | 270.22 / 270.51 (ZINB) |
| Mesh cutoff | 200 m | 75 m |
| Mesh max. edge (inner / outer) | 400 / 3,000 m | 150 / 900 m |
| Mesh offset (inner / outer) | 4,000 / 12,000 m | 1,200 / 4,000 m |
| Mesh vertices | 19,099 | 6,770 |
| Range PC prior | P(range < 5,000 m) = 0.5 | P(range < 1,000 m) = 0.5 |
| SD PC prior | P(sigma > 2.5) = 0.05 | P(sigma > 1.5) = 0.05 |
| Posterior spatial range (95% CrI) | 4,175 m (2,007–7,618) | 584 m (150–1,599) |
| Posterior spatial SD (95% CrI) | 0.96 (0.70–1.28) | 0.82 (0.39–1.45) |
| Posterior NB size | 3.30 | 1.84 |
| Posterior zero-inflation probability | 0.063 | — |
| Prediction cell size | 150 m | 60 m |
| Prediction extent (buffered hull) | ~26 x 37 km | ~8.9 x 8.3 km |
| Effort-weighting factor (ref. Aug 2024) | 1.195 | 1.035 |
| Residual Moran's *I* (p) | −0.036 (0.335) | −0.041 (0.590) |
| Spatial block CV 90% coverage (row / camera) | 0.96 / 0.93 | 0.98 / 0.92 |
| Required diagnostics | Pass | Pass |
| Stated caveat | Residual temporal autocorrelation, mechanism unestablished | Only 46 events; wide posterior intervals |

---

## References cited in this text

- Czado, C., Gneiting, T. & Held, L. (2009). Predictive model assessment for
  count data. *Biometrics*, 65(4), 1254–1261.
- Dormann, C. F. et al. (2007). Methods to account for spatial autocorrelation
  in the analysis of species distributional data: a review. *Ecography*, 30(5),
  609–628.
- Fuglstad, G.-A., Simpson, D., Lindgren, F. & Rue, H. (2019). Constructing
  priors that penalize the complexity of Gaussian random fields. *Journal of the
  American Statistical Association*, 114(525), 445–452.
- Gelman, A., Meng, X.-L. & Stern, H. (1996). Posterior predictive assessment of
  model fitness via realized discrepancies. *Statistica Sinica*, 6(4), 733–760.
- Hilbe, J. M. (2011). *Negative Binomial Regression* (2nd ed.). Cambridge
  University Press.
- Lindgren, F., Rue, H. & Lindström, J. (2011). An explicit link between Gaussian
  fields and Gaussian Markov random fields: the stochastic partial differential
  equation approach. *Journal of the Royal Statistical Society: Series B*, 73(4),
  423–498.
- Martin, T. G. et al. (2005). Zero tolerance ecology: improving ecological
  inference by modelling the source of zero observations. *Ecology Letters*,
  8(11), 1235–1246.
- Moran, P. A. P. (1950). Notes on continuous stochastic phenomena. *Biometrika*,
  37(1/2), 17–23.
- O'Brien, T. G. (2011). Abundance, density and relative abundance: a conceptual
  framework. In *Camera Traps in Animal Ecology* (pp. 71–96). Springer.
- Roberts, D. R. et al. (2017). Cross-validation strategies for data with
  temporal, spatial, hierarchical, or phylogenetic structure. *Ecography*, 40(8),
  913–929.
- Rowcliffe, J. M., Field, J., Turvey, S. T. & Carbone, C. (2008). Estimating
  animal density using camera traps without the need for individual recognition.
  *Journal of Applied Ecology*, 45(4), 1228–1236.
- Rue, H., Martino, S. & Chopin, N. (2009). Approximate Bayesian inference for
  latent Gaussian models by using integrated nested Laplace approximations.
  *Journal of the Royal Statistical Society: Series B*, 71(2), 319–392.
- Simpson, D., Rue, H., Riebler, A., Sørbye, S. H. & Fuglstad, G.-A. (2017).
  Penalising model component complexity: a principled, practical approach to
  constructing priors. *Statistical Science*, 32(1), 1–28.
- Spiegelhalter, D. J., Best, N. G., Carlin, B. P. & van der Linde, A. (2002).
  Bayesian measures of model complexity and fit. *Journal of the Royal
  Statistical Society: Series B*, 64(4), 583–639.
- Watanabe, S. (2010). Asymptotic equivalence of Bayes cross validation and
  widely applicable information criterion in singular learning theory. *Journal
  of Machine Learning Research*, 11, 3571–3594.
