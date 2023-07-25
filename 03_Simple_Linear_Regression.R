## load packages
library(tidyverse)
library(nflfastR)

## load data
chap_3_file <- "./data/pbp_r_chap_3.csv"
if (!file.exists(chap_3_file)) {
    pbp_r <- load_pbp(2016:2022)
    write_csv(pbp_r, chap_3_file)
} else {
    pbp_r <- read_csv(chap_3_file)
}


## filter run data and replace missing values
pbp_r_run <-
    pbp_r |>
    filter(play_type == "run" & !is.na(rusher_id)) |>
    mutate(rushing_yards = ifelse(is.na(rushing_yards), 0, rushing_yards))

## plot raw data prior to building model
ggplot(pbp_r_run, aes(x = ydstogo, y = rushing_yards)) +
    geom_point() +
    theme_bw()

## save figure for book
fig_3_2 <-
    ggplot(pbp_r_run, aes(x = ydstogo, y = rushing_yards)) +
    geom_point() +
    theme_bw() +
    theme(axis.text = element_text(size = 13))
fig_3_2
ggsave("fig_3_2.png", fig_3_2, width = 6, height = 4.25)

## add linear trend line
ggplot(pbp_r_run, aes(x = ydstogo, y = rushing_yards)) +
    geom_point() +
    theme_bw() +
    stat_smooth(method = "lm")

## save figure for book
fig_3_4 <-
    fig_3_2 +
    stat_smooth(method = "lm")
print(fig_3_4)
ggsave("fig_3_4.png", fig_3_4, width = 6, height = 4.25)

## bin and plot data
pbp_r_run_ave <-
    pbp_r_run |>
    group_by(ydstogo) |>
    summarize(ypc = mean(rushing_yards))

ggplot(pbp_r_run_ave, aes(x = ydstogo, y = ypc)) +
    geom_point() +
    theme_bw() +
    stat_smooth(method = "lm")

## build and fit linear model in R
yard_to_go_r <-
    lm(rushing_yards ~ 1 + ydstogo, data = pbp_r_run)
summary(yard_to_go_r)

## save residuals as RYOE
pbp_r_run <-
    pbp_r_run |>
    mutate(ryoe = resid(yard_to_go_r))

ryoe_r <-
    pbp_r_run |>
    group_by(season, rusher_id, rusher) |>
    summarize(
        n = n(), ryoe_total = sum(ryoe),
        ryoe_per = mean(ryoe), yards_per_carry = mean(rushing_yards)
    ) |>
    arrange(-ryoe_total) |>
    filter(n > 50)
print(ryoe_r)

## Look at RYOE
ryoe_r |>
    arrange(-ryoe_per)

## RYOE stability
# create current dataframe
ryoe_now_r <-
    ryoe_r |>
    select(-n, -ryoe_total)

# create last-year's dataframe
# and add 1 to season ryoe_last
ryoe_last_r <-
    ryoe_r |>
    select(-n, -ryoe_total) |>
    mutate(season = season + 1) |>
    rename(ryoe_per_last = ryoe_per, yards_per_carry_last = yards_per_carry)

# merge together
ryoe_lag_r <-
    ryoe_now_r |>
    inner_join(ryoe_last_r, by = c("rusher_id", "rusher", "season")) |>
    ungroup()

## Look at correlation
ryoe_lag_r |>
    select(yards_per_carry, yards_per_carry_last) |>
    cor(use = "complete.obs")

## repeat for RYOE
ryoe_lag_r |>
    select(ryoe_per, ryoe_per_last) |>
    cor(use = "complete.obs")
