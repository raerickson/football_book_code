## load packages
library(tidyverse)
library(nflfastR)
library(broom)

## load data and filter data
chap_5_file <- "./data/pbp_r_chap_5.csv"
if (!file.exists(chap_5_file)) {
    pbp_r <- load_pbp(2016:2022)
    write_csv(pbp_r, chap_5_file)
} else {
    pbp_r <- read_csv(chap_5_file)
}


pbp_r_pass <-
    pbp_r |>
    filter(
        play_type == "pass" & !is.na(passer_id) & !is.na(air_yards)
    )

## filter more and then plot
pass_pct_r <-
    pbp_r_pass |>
    filter(0 < air_yards & air_yards <= 20) |>
    group_by(air_yards) |>
    summarize(comp_pct = mean(complete_pass), .groups = "drop")

pass_pct_r |>
    ggplot(aes(x = air_yards, y = comp_pct)) +
    geom_point() +
    stat_smooth(method = "lm") +
    theme_bw() +
    ylab("Percent completion") +
    xlab("Air yards")

## building a glm
complete_ay_r <-
    glm(complete_pass ~ air_yards,
        data = pbp_r_pass, family = "binomial"
    )
summary(complete_ay_r)

## logistic plot
ggplot(data = pbp_r_pass, aes(x = air_yards, y = complete_pass)) +
    geom_jitter(height = 0.05, width = 0, alpha = 0.05) +
    stat_smooth(method = "glm", method.args = list(family = "binomial")) +
    theme_bw() +
    ylab("Completed pass (1 = yes, 0 = no)") +
    xlab("air yards")

## glm completion percentage predicted
pbp_r_pass <-
    pbp_r_pass |>
    mutate(
        exp_completion = predict(complete_ay_r, type = "resp"),
        cpoe = complete_pass - exp_completion
    )

## cpoe
pbp_r_pass |>
    group_by(season, passer_id, passer) |>
    summarize(
        n = n(),
        cpoe = mean(cpoe, na.rm = TRUE),
        compl = mean(complete_pass, na.rm = TRUE),
        .groups = "drop"
    ) |>
    filter(n >= 100) |>
    arrange(-cpoe) |>
    print(n = 20)

## remove missing data and format
pbp_r_pass_no_miss <-
    pbp_r_pass |>
    mutate(
        down = factor(down),
        qb_hit = factor(qb_hit)
    ) |>
    filter(
        complete.cases(
            down, qb_hit, complete_pass, ydstogo,
            yardline_100, air_yards, pass_location, qb_hit
        )
    )

## run model and save outputs
complete_more_r <-
    pbp_r_pass_no_miss |>
    glm(
        formula = complete_pass ~ down * ydstogo +
            yardline_100 + air_yards + pass_location + qb_hit,
        family = "binomial"
    )

## cpoe
pbp_r_pass_no_miss <-
    pbp_r_pass_no_miss |>
    mutate(
        exp_completion = predict(complete_more_r, type = "resp"),
        cpoe = complete_pass - exp_completion
    )

## summarize data
cpoe_more_r <-
    pbp_r_pass_no_miss |>
    group_by(season, passer_id, passer) |>
    summarize(
        n = n(),
        cpoe = mean(cpoe, na.rm = TRUE),
        compl = mean(complete_pass),
        exp_completion = mean(exp_completion),
        .groups = "drop"
    ) |>
    filter(n > 100)

## print outputs
cpoe_more_r |>
    arrange(-cpoe) |>
    print(n = 20)

## stability
# create current dataframe
cpoe_now_r <-
    cpoe_more_r |>
    select(-n)

# create last-year's dataframe
# and add 1 to season
cpoe_last_r <-
    cpoe_more_r |>
    select(-n) |>
    mutate(season = season + 1) |>
    rename(
        cpoe_last = cpoe, compl_last = compl,
        exp_completion_last = exp_completion
    )

# merge together
cpoe_lag_r <-
    cpoe_now_r |>
    inner_join(cpoe_last_r,
        by = c("passer_id", "passer", "season")
    ) |>
    ungroup()

## pass completion stability
cpoe_lag_r |>
    select(compl_last, compl) |>
    cor(use = "complete.obs")

## CPOE stability
cpoe_lag_r |>
    select(cpoe_last, cpoe) |>
    cor(use = "complete.obs")

## stability expected completions
cpoe_lag_r |>
    select(exp_completion_last, exp_completion) |>
    cor(use = "complete.obs")

## odds ratios
complete_ay_r |>
    tidy(exponentiate = TRUE, conf.int = TRUE)

## summarize raw data
pbp_r_pass |>
    summarize(comp_pct = mean(complete_pass)) |>
    mutate(odds = comp_pct / (1 - comp_pct), log_odds = log(odds))

## global intercept
complete_global_r <-
    glm(complete_pass ~ 1,
        data = pbp_r_pass,
        family = "binomial"
    )

complete_global_r |>
    tidy()

complete_global_r |>
    tidy(exponentiate = TRUE)
