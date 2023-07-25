## load packages
library(tidyverse)
library(nflfastR)
library(broom)
library(kableExtra)

## model matrix (R only)
demo_data_r <-
    tibble(down = c("first", "second"), ydstogo = c(10, 5))

## look at model matrix
model.matrix(~ ydstogo + down, data = demo_data_r)

## intercept-based model
model.matrix(~ ydstogo + down - 1, data = demo_data_r)

## load data
chap_4_file <- "./data/pbp_r_chap_4.csv"
if (!file.exists(chap_4_file)) {
    pbp_r <- load_pbp(2016:2022)
    write_csv(pbp_r, chap_4_file)
} else {
    pbp_r <- read_csv(chap_4_file)
}

## filter only run plays
pbp_r_run <- pbp_r |>
    filter(play_type == "run" &
        !is.na(rusher_id) &
        !is.na(down) &
        !is.na(run_location)) |>
    mutate(rushing_yards = ifelse(is.na(rushing_yards), 0, rushing_yards))

## Format and plot data
# Change down to be an integer
pbp_r_run <-
    pbp_r_run |>
    mutate(down = as.character(down))

# Plot rushing yards by down
ggplot(pbp_r_run, aes(x = rushing_yards)) +
    geom_histogram(binwidth = 1) +
    facet_wrap(vars(down), ncol = 2, labeller = label_both) +
    theme_bw() +
    theme(strip.background = element_blank())

## save for book
fig_4_2 <-
    ggplot(pbp_r_run, aes(x = rushing_yards)) +
    geom_histogram(binwidth = 1) +
    facet_wrap(vars(down), ncol = 2, labeller = label_both) +
    theme_bw() +
    theme(
        strip.background = element_blank(),
        axis.text = element_text(size = 13)
    )
fig_4_2
ggsave("fig_4_2.png", fig_4_2, width = 6, height = 4.25)

## Look at only plays with 10 yards to go
pbp_r_run |>
    filter(ydstogo == 10) |>
    ggplot(aes(x = down, y = rushing_yards)) +
    geom_boxplot() +
    theme_bw()

## save for book
fig_4_4 <-
    pbp_r_run |>
    filter(ydstogo == 10) |>
    ggplot(aes(x = down, y = rushing_yards)) +
    geom_boxplot() +
    theme_bw() +
    theme(axis.text = element_text(size = 13))
fig_4_4
ggsave("fig_4_4.png", fig_4_4, width = 6, height = 4.25)

## plot trendline in R
ggplot(pbp_r_run, aes(x = yardline_100, y = rushing_yards)) +
    geom_point(alpha = 0.25) +
    stat_smooth(method = "lm") +
    theme_bw()

## save for book
fig_4_6 <-
    ggplot(pbp_r_run, aes(x = yardline_100, y = rushing_yards)) +
    geom_point(alpha = 0.25) +
    stat_smooth(method = "lm") +
    theme_bw() +
    theme(axis.text = element_text(size = 13))
ggsave("fig_4_6.png", fig_4_6, width = 6, height = 4.25)


## Bin and plot
pbp_r_run |>
    group_by(yardline_100) |>
    summarize(rushing_yards_mean = mean(rushing_yards)) |>
    ggplot(aes(x = yardline_100, y = rushing_yards_mean)) +
    geom_point() +
    stat_smooth(method = "lm") +
    theme_bw()

## Boxplot by run location
ggplot(pbp_r_run, aes(run_location, rushing_yards)) +
    geom_boxplot() +
    theme_bw()

fig_4_10 <-
    ggplot(pbp_r_run, aes(run_location, rushing_yards)) +
    geom_boxplot() +
    theme_bw() +
    theme(axis.text = element_text(size = 13))
fig_4_10
ggsave("fig_4_10.png", fig_4_10, width = 6, height = 4.25)

## Calculate and plot score differential
pbp_r_run |>
    group_by(score_differential) |>
    summarize(rushing_yards_mean = mean(rushing_yards)) |>
    ggplot(aes(score_differential, rushing_yards_mean)) +
    geom_point() +
    stat_smooth(method = "lm") +
    theme_bw()

## Multiple logistic regression
pbp_r_run <-
    pbp_r_run |>
    mutate(down = as.character(down))
expected_yards_r <-
    lm(
        rushing_yards ~ 1 + down + ydstogo +
            down:ydstogo + yardline_100 + run_location + score_differential,
        data = pbp_r_run
    )
pbp_r_run <-
    pbp_r_run |>
    mutate(ryoe = resid(expected_yards_r))

## Look at model outputs
print(summary(expected_yards_r))

## create table of outputs
expected_yards_r |>
    tidy(conf.int = TRUE) |>
    kbl(format = "pipe", digits = 2) |>
    kable_styling()

## Analyze RYOE
ryoe_r <-
    pbp_r_run |>
    group_by(season, rusher_id, rusher) |>
    summarize(
        n = n(), ryoe_total = sum(ryoe),
        ryoe_per = mean(ryoe), yards_per_carry = mean(rushing_yards)
    ) |>
    filter(n > 50)

ryoe_r |>
    arrange(-ryoe_total) |>
    print()

## RYOE per carry
ryoe_r |>
    filter(n > 50) |>
    arrange(-ryoe_per) |>
    print()

## Calculate lag
# create current dataframe
ryoe_now_r <-
    ryoe_r |>
    select(-n, -ryoe_total)

# create last-year's dataframe
# and add 1 to season
ryoe_last_r <-
    ryoe_r |>
    select(-n, -ryoe_total) |>
    mutate(season = season + 1) |>
    rename(
        ryoe_per_last = ryoe_per,
        yards_per_carry_last = yards_per_carry
    )
# merge together ryoe_lag
ryoe_lag_r <-
    ryoe_now_r |>
    inner_join(ryoe_last_r, by = c("rusher_id", "rusher", "season")) |>
    ungroup()

## Look at yards per carry
ryoe_lag_r |>
    select(yards_per_carry, yards_per_carry_last) |>
    cor(use = "complete.obs")

## Look at stability for RYOE
ryoe_lag_r |>
    select(ryoe_per, ryoe_per_last) |>
    cor(use = "complete.obs")

## Look at assumption of linearity
par(mfrow = c(2, 2))
plot(expected_yards_r)

## save for book
png("fig_4_13.png",
    width = 6,
    height = 4.25,
    units = "in",
    res = 300,
)
par(mfrow = c(2, 2))
plot(expected_yards_r)
dev.off()

## Filter data and rebuild model
expected_yards_filter_r <-
    pbp_r_run |>
    filter(rushing_yards > 15 & rushing_yards < 90) |>
    lm(formula = rushing_yards ~ 1 + down + ydstogo +
        down:ydstogo + yardline_100 + run_location + score_differential)
par(mfrow = c(2, 2))
plot(expected_yards_filter_r)

## plot for book
png("fig_4_14.png",
    width = 6,
    height = 4.25,
    units = "in",
    res = 300,
)
par(mfrow = c(2, 2))
plot(expected_yards_filter_r)
dev.off()


## look at new model
summary(expected_yards_filter_r)
