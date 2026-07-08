# Bayesian Spatial Encounter-Surface Modelling Of 2023-2024 Camera-Trap Detections

This repository contains a 2023-2024 camera-trap modelling project focused on
the spatial pattern of wolf relative encounter frequency. The analyses model
independent wolf detections recorded by camera traps using Bayesian count models
with INLA-SPDE spatial random fields. Active camera-days are used as exposure,
calendar month is included as a fixed temporal control, and outputs are
relative encounter-frequency surfaces expressed as expected independent wolf
events per 100 camera-days across the sampled survey-year period.

## Project

- [CameraSpatialEncounterSurfaces2023_2024](CameraSpatialEncounterSurfaces2023_2024/):
  three Bayesian spatial encounter-surface models from camera-trap data: a
  2023 road-camera negative-binomial spatial-month model, a 2024 forest-camera
  negative-binomial spatial-month model, and a 2024 road-camera
  zero-inflated negative-binomial spatial-month model.

All three models run the same analyses, diagnostics, and outputs through a
single shared analysis library
([`scripts/wolf_encounter_surface_lib.R`](CameraSpatialEncounterSurfaces2023_2024/scripts/wolf_encounter_surface_lib.R)),
driven by one thin runner per survey. The same library also produces two
companion **human-activity** surfaces (people and vehicles) on the road-camera
surveys, as a relative human-disturbance index. See the
[project README](CameraSpatialEncounterSurfaces2023_2024/README.md) for the full
methodology, diagnostics, and outputs.

## License And Citation

This repository is licensed under [CC BY 4.0](LICENSE). If you use it, please
cite it using the metadata in [CITATION.cff](CITATION.cff).
