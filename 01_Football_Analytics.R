## demonstrate objects
z <- 2
z / 3

## install nflfastR
## This command is only run once unless you upgrade or reinstall R
## Also, make sure you have installed the tidyverse
# install.packages("nflfastR")

## load packages
library(tidyverse)
library(nflfastR)

## load play-by-play data for 2021
chap_1_file <- "./data/pbp_r_chap_1.csv"
if (!file.exists(chap_1_file)) {
    pbp_r <- load_pbp(2021)
    write_csv(pbp_r, chap_1_file)
} else {
    pbp_r <- read_csv(chap_1_file)
}

## filter to include pass data
pbp_r_p <-
    pbp_r |>
    filter(play_type == "pass" & !is.na(air_yards))

## calculate and print adot
pbp_r_p |>
    group_by(passer_id, passer) |>
    summarize(n = n(), adot = mean(air_yards)) |>
    filter(n >= 100 & !is.na(passer)) |>
    arrange(-adot) |>
    print(n = Inf)
