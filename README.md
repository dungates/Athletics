
<!-- README.md is generated from README.Rmd. Do not edit README.md directly. -->

# Athletics World Records

Analysis of running world record progressions and current standings,
asking: which records are most impressive, how fast has improvement
been, and how do men’s and women’s records compare?

------------------------------------------------------------------------

## Pipeline — run scripts in this order

Every script is self-contained Quarto document (`.qmd`) or R file
rendered with `quarto render <file>` / `Rscript <file>`. Run them in the
numbered order below; later steps depend on the processed data that
earlier steps write to `data/processed/`.

### 1 · `pipeline/data_obtain.qmd`

**Purpose:** Scrape all raw data from the web and write cleaned `.rds` /
`.csv` files to `data/processed/`.

| What it does | Source |
|----|----|
| Scrapes men’s & women’s current world records | [World Athletics](https://www.worldathletics.org/records/by-category/world-records) |
| Scrapes 100 m record progression (IAAF automatic-timing era) | [Wikipedia — table 3](https://en.wikipedia.org/wiki/Men%27s_100_metres_world_record_progression) |
| Scrapes record progressions for 200 m – marathon | [Wikipedia](https://en.wikipedia.org/wiki/Athletics_record_progressions) (one page per event) |
| Scrapes mile record progression | [Wikipedia — table 4](https://en.wikipedia.org/wiki/Mile_run_world_record_progression) |
| Cleans and standardises all time strings to seconds | via `parse_perf()` helper |
| Resolves athlete nationalities via country codes | `countrycode` package |

**Outputs written to `data/processed/`:**

    mens_world_records_seconds.rds
    womens_world_records_seconds.rds
    mens_womens_current_records.rds
    onehundred_progression.rds
    RunningRecordsOverTime.rds
    RunningRecordsOverTime.csv

> **Note:** this script makes ~15 polite HTTP requests with a 1-second
> delay between each. Allow a few minutes for it to run. Requires a live
> internet connection.

------------------------------------------------------------------------

### 2 · `misc/apple_watch.qmd`

**Purpose:** Parse the Apple Watch XML export and produce a processed
heart-rate dataset.

- Reads `data/raw/apple_health_export/export.xml` (~309 MB)
- Filters `HKQuantityTypeIdentifierHeartRate` records
- Writes `data/processed/heart_rate.rds`

> Run this only if you have the Apple Health export available. The
> processed `.rds` is checked in, so you can skip this step if you just
> want to run the analyses.

------------------------------------------------------------------------

### 3 · `analysis/records.qmd`

**Purpose:** Main analysis — “Which world record is most impressive?”

Reads from `data/processed/`:

- `mens_world_records_seconds.rds`
- `womens_world_records_seconds.rds`
- `mens_womens_current_records.rds`
- `onehundred_progression.rds`
- `RunningRecordsOverTime.rds`

Produces:

- Current records by distance and pace (short / middle / long)
- Men’s vs women’s record comparison and gender gap
- 100 m progression with wind speed and per-record improvement
- Animated record progression (`gganimate`)
- Log–distance regression models with `gtsummary` output tables

------------------------------------------------------------------------

### 4 · `analysis/standing_records.qmd`

**Purpose:** Live table of current world records.

Scrapes
[worldathletics.org](https://www.worldathletics.org/records/by-category/world-records)
at render time (requires internet), parses performance times with
`parse_perf()`, and renders a `gt` table grouped by event type (running,
relay, jumping, throwing).

> Unlike the other analysis files this one hits the web at render time —
> it always shows the latest records.

------------------------------------------------------------------------

### 5 · `analysis/all_time_athletics.qmd`

**Purpose:** Scrape and display the all-time men’s best performances
from [alltime-athletics.com](http://www.alltime-athletics.com/men.htm).

- Reads the event index page to build a list of event links
- Loops over events with `read_event()`, selecting the right column
  schema per event type via a `column_configs` lookup list +
  `purrr::detect()`
- Parses pre-formatted ASCII tables with regex + `tidyr::separate()`

------------------------------------------------------------------------

### 6 · `shiny/app.R`

**Purpose:** Interactive heart-rate dashboard.

Reads `data/processed/heart_rate.rds` and serves a Shiny app with a
date-range selector, heart-rate plot, and summary statistics table.

Run with:

``` r
shiny::runApp("shiny/app.R")
```

------------------------------------------------------------------------

## Dependency graph

    worldathletics.org ──┐
    Wikipedia (×12)  ────┤──► pipeline/data_obtain.qmd ──► data/processed/*.rds ──► analysis/records.qmd
                         │                                                        └──► analysis/standing_records.qmd (also live)
    apple_health_export ─┴──► misc/apple_watch.qmd ──► data/processed/heart_rate.rds ──► shiny/app.R

    alltime-athletics.com ──► analysis/all_time_athletics.qmd

------------------------------------------------------------------------

## R packages required

``` r
install.packages(c(
  "tidyverse", "here", "lubridate", "rvest", "xml2", "polite",
  "countrycode", "readxl", "scales", "gt", "gtsummary",
  "ggrepel", "ggtext", "ggpmisc", "gganimate", "transformr",
  "shiny", "gentelellaShiny", "shinyWidgets", "magrittr"
))
```

------------------------------------------------------------------------

## Data sources

| File | Source | Automated? |
|----|----|----|
| Current world records | [worldathletics.org](https://www.worldathletics.org/records/by-category/world-records) | ✅ scraped |
| 100 m progression | [Wikipedia](https://en.wikipedia.org/wiki/Men%27s_100_metres_world_record_progression) | ✅ scraped |
| 200 m – marathon progressions | Wikipedia (one page per event) | ✅ scraped |
| Mile progression | [Wikipedia](https://en.wikipedia.org/wiki/Mile_run_world_record_progression) | ✅ scraped |
| All-time best performances | [alltime-athletics.com](http://www.alltime-athletics.com/men.htm) | ✅ scraped |
| Heart rate | Apple Watch (personal export) | manual export |
