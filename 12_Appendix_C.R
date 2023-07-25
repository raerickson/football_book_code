## logic operators
score <- c(21, 7, 0, 14)
team <- c("GB", "DEN", "KC", "NYJ")

score < 15

position <- c("QB", "DE", "OLB", "ED")

position %in% c("DE", "OLB", "ED")
c("DE", "OLB", "ED") %in% position

score > 7 | team == "DEN"

(score >= 7 & team == "DEN") | (score == 0)

## Filtering and sorting data
library(tidyverse)
library(nflfastR)

pbp_r <- load_pbp(2020)

gb_det_2020_r_pass <-
    pbp_r |>
    filter(home_team == "GB" & away_team == "DET") |>
    select(
        posteam, yards_after_catch, air_yards,
        pass_location, qb_scramble
    )

gb_det_2020_r_pass |>
    filter(yards_after_catch > 15)

gb_det_2020_r_pass |>
    filter(yards_after_catch > 15 & posteam == "DET")

gb_det_2020_r_pass |>
    filter(yards_after_catch > 15 | air_yards > 20 &
        posteam == "DET")

gb_det_2020_r_pass |>
    filter((yards_after_catch > 15 | air_yards > 20) &
        posteam == "DET")

gb_det_2020_r_pass |>
    filter((yards_after_catch > 15 | air_yards > 20) &
        posteam != "DET")

## cleaning data
wrong_number <-
    tibble(col1 = c("a", "b"), col2 = c("1O", "12"), col3 = c(2, 44))
wrong_number <-
    wrong_number |>
    mutate(col2 = ifelse(col2 == "1O", 10, col2))

wrong_number <-
    mutate(wrong_number, col2 = as.numeric(col2))
str(wrong_number)

## Checking for outliers
wrong_number |>
    summary()

## merging
library(tidyverse)
city_data <-
    data.frame(
        city = c("DET", "GB", "HOU"),
        team = c("Lions", "Packers", "Texans")
    )
schedule <-
    data.frame(
        home = c("GB", "DET"),
        away = c("DET", "HOU")
    )

print(
    full_join(schedule, city_data, by = c("home" = "city"))
)

print(
    inner_join(schedule, city_data, by = c("home" = "city"))
)

print(right_join(schedule, city_data, by = c("home" = "city")))

print(left_join(schedule, city_data, by = c("home" = "city")))

schedule_name <-
    schedule |>
    left_join(city_data, by = c("home" = "city")) |>
    rename(home_team = team) |>
    left_join(city_data, by = c("away" = "city")) |>
    rename(away_team = team)

print(schedule_name)
