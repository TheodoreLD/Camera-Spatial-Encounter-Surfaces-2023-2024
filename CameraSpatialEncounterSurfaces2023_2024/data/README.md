# Data Inputs

Raw camera-trap data are not committed to this repository. To rerun the final
models, place the required CSV files in this `data/` folder, or set
`WOLF_DATA_DIR` to the folder that contains them.

The raw camera-trap survey data are private and will be released with the
associated publication. No sample data are distributed here; this repository
provides the analysis code and curated result outputs only.

## Required Files

For the forest-camera 2024 model:

```text
forest_camera_trap_events.csv
```

A custom path or filename can be supplied with `WOLF_FOREST_FILE`.

For the road-camera 2024 model:

```text
deployments_2024.csv
observations_2024.csv
```

For the road-camera 2023 model:

```text
deployments_2023.csv
observations_2023.csv
```

For the March 2024 single-month spatial-only companions (wolf and human-activity):

```text
deployments_march2024.csv           # shared road-camera deployments (clipped to March)
observations_march2024.csv          # wolf events
observations_humanmarch2024.csv     # human/vehicle events (Homo sapiens, cars, bikes, motorcycle)
```

These are the March 2024 slice of the full multi-year camera-trap dataset:
deployments clipped to the March 2024 window, the distinct wolf events, and the
distinct human/vehicle events with an `eventStart` in March 2024. They share the
same road-camera deployment file and use the observation schema below.

## Required Fields

The forest-camera flat file must contain:

```text
deploymentID
eventID
eventStart
scientificName
plotID
deploymentEffort
latitude
longitude
startDate
endDate
```

The road-camera deployment file must contain:

```text
deploymentID
locationID
latitude
longitude
deploymentStart
deploymentEnd
```

The road-camera observation file must contain:

```text
deploymentID
eventID
scientificName
eventStart
```

## Event Definition

The scripts count distinct wolf `eventID` values where `scientificName` is
`Canis_lupus` or `Canis lupus`. The analysis assumes each event ID represents an
independent wolf event according to the camera-trap processing workflow.

The human-activity companion runners (`run_road_2023_human.R`,
`run_road_2024_human.R`) instead count events labelled `Homo sapiens`, `cars`,
`bikes`, or `motorcycle` from the same road-camera observation files, as a
relative human-disturbance index.

## How Camera Effort And Events Are Assigned To Months

All final models use camera-month rows. If a camera deployment spans more than
one month, the active camera-days are divided among the months in which the
camera was active. Wolf events are then counted in the month indicated by their
`eventStart` timestamp.

This is required because the statistical model includes month effects: the wolf
count for a month must be paired with the camera effort from that same month.

This keeps the count data and the exposure data aligned before fitting month
effects.
