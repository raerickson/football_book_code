## load packages
library(tidyverse)
library(nflfastR)

## Load all data
pbp_r <- load_pbp(2020)

## filter out game data
gb_det_2020_r <-
    pbp_r |>
    filter(home_team == "GB" & away_team == "DET")

# select pass data
gb_det_2020_pass_r <-
    gb_det_2020_r |>
    select(
        posteam, yards_after_catch, air_yards,
        pass_location, qb_scramble
    )

# summary
summary(gb_det_2020_pass_r)

gb_det_2020_pass_r |>
    summarize(
        min_yac = min(air_yards), max_yac = max(air_yards),
        mean_yac = mean(air_yards),
        median_yac = median(air_yards), sd_yac = sd(air_yards),
        var_yac = var(air_yards), n_yac = n()
    )

gb_det_2020_pass_r |>
    summarize(
        min_yac = min(air_yards, na.rm = TRUE),
        max_yac = max(air_yards, na.rm = TRUE),
        mean_yac = mean(air_yards, na.rm = TRUE),
        median_yac = median(air_yards, na.rm = TRUE),
        sd_yac = sd(air_yards, na.rm = TRUE),
        var_yac = var(air_yards, na.rm = TRUE),
        n_yac = n()
    )

## group_by
gb_det_2020_pass_r |>
    group_by(posteam) |>
    summarize(
        min_yac = min(air_yards, na.rm = TRUE),
        max_yac = max(air_yards, na.rm = TRUE),
        mean_yac = mean(air_yards, na.rm = TRUE),
        median_yac = median(air_yards, na.rm = TRUE),
        sd_yac = sd(air_yards, na.rm = TRUE),
        var_yac = var(air_yards, na.rm = TRUE),
        n_yac = n()
    )
