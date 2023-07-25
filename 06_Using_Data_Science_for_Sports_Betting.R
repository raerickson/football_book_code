## load packages
library(nflfastR)
library(tidyverse)
library(broom)

## load data
chap_6_file <- "./data/pbp_r_chap_6.csv"
if (!file.exists(chap_6_file)) {
    pbp_r <- load_pbp(2016:2022)
    write_csv(pbp_r, chap_6_file)
} else {
    pbp_r <- read_csv(chap_6_file)
}

pbp_r_pass <-
    pbp_r |>
    filter(!is.na(passer_id))

## format data
pbp_r_pass_td_y <- pbp_r_pass |>
    mutate(
        pass_touchdown = ifelse(is.na(pass_touchdown), 0, pass_touchdown)
    ) |>
    group_by(season, week, passer_id, passer) |>
    summarize(
        n_passes = n(), pass_td_y = sum(pass_touchdown),
        total_line = mean(total_line)
    ) |>
    filter(n_passes >= 10)

## print summary output to screen
pbp_r_pass_td_y |>
    group_by(pass_td_y) |>
    summarize(n = n())

## use summary to see different summary of data
pbp_r_pass_td_y |>
    ungroup() |>
    select(-passer, -passer_id) |>
    summary()

## calculate mean and use with Poisson
pass_td_y_mean_r <-
    pbp_r_pass_td_y |>
    pull(pass_td_y) |>
    mean()

plot_pos_r <-
    tibble(x = seq(0, 7)) |>
    mutate(expected = dpois(x = x, lambda = pass_td_y_mean_r))

ggplot() +
    geom_histogram(
        data = pbp_r_pass_td_y,
        aes(x = pass_td_y, y = after_stat(count / sum(count))),
        binwidth = 0.5
    ) +
    geom_line(
        data = plot_pos_r, aes(x = x, y = expected),
        color = "red", linewidth = 1
    ) +
    theme_bw() +
    xlab("Touchdown passes per player per game for 2016 to 2022") +
    ylab("Probability")

## individual player total for QB
# pass_ty_d greater than or equal to 10 per week
pbp_r_pass_td_y_geq10 <-
    pbp_r_pass_td_y |>
    filter(n_passes >= 10)

# take the average touchdown passes for each QB for the previous season
# and current season up to the current game
x_r <- tibble()

for (season_idx in seq(2017, 2022)) {
    for (week_idx in seq(1, 22)) {
        week_calc_r <-
            pbp_r_pass_td_y_geq10 |>
            filter((season == (season_idx - 1)) |
                (season == season_idx & week < week_idx)) |>
            group_by(passer_id, passer) |>
            summarize(
                n_games = n(),
                pass_td_rate = mean(pass_td_y),
                .groups = "keep"
            ) |>
            mutate(season = season_idx, week = week_idx)
        x_r <- bind_rows(x_r, week_calc_r)
    }
}

## look at example output
x_r |>
    filter(passer == "P.Mahomes") |>
    tail()

## include game totals
pbp_r_pass_td_y_geq10 <-
    pbp_r_pass_td_y_geq10 |>
    inner_join(x_r, by = c("season", "week", "passer_id", "passer"))

## weekly plots totals
weekly_passing_id_r_plot <-
    pbp_r_pass_td_y_geq10 |>
    ggplot(aes(x = week, y = pass_td_y, group = passer_id)) +
    geom_line(alpha = 0.25) +
    facet_wrap(vars(season), nrow = 3) +
    theme_bw() +
    theme(strip.background = element_blank()) +
    ylab("Total passing touchdowns") +
    xlab("Week of season")
weekly_passing_id_r_plot

## save for book
fig_6_3 <-
    weekly_passing_id_r_plot +
    theme(text = element_text(size = 13))
fig_6_3
ggsave("fig_6_3.png", fig_6_3, width = 6, height = 4.25)

## include trend line
weekly_passing_id_r_plot +
    geom_smooth(
        method = "glm", method.args = list("family" = "poisson"),
        se = FALSE,
        linewidth = 0.5, color = "blue", alpha = 0.25
    )

## save for book
fig_6_4 <-
    weekly_passing_id_r_plot +
    theme(text = element_text(size = 13))
fig_6_4
ggsave("fig_6_4.png", fig_6_4, width = 6, height = 4.25)

## Poisson regression
pass_fit_r <-
    glm(pass_td_y ~ pass_td_rate + total_line,
        data = pbp_r_pass_td_y_geq10, family = "poisson"
    )

pbp_r_pass_td_y_geq10 <-
    pbp_r_pass_td_y_geq10 |>
    ungroup() |>
    mutate(exp_pass_td = predict(pass_fit_r, type = "response"))

summary(pass_fit_r) |>
    print()

tidy(pass_fit_r, exponentiate = TRUE, conf.int = TRUE)

pbp_r_pass_td_y_geq10 |>
    filter(passer == "P.Mahomes", season == 2022, week == 22) |>
    select(-pass_td_y, -n_passes, -passer_id, -week, -season, -n_games)

## PMF and CDF
pbp_r_pass_td_y_geq10 <-
    pbp_r_pass_td_y_geq10 |>
    mutate(
        p_0_td = dpois(
            x = 0,
            lambda = exp_pass_td
        ),
        p_1_td = dpois(
            x = 1,
            lambda = exp_pass_td
        ),
        p_2_td = dpois(
            x = 2,
            lambda = exp_pass_td
        ),
        p_g2_td = ppois(
            q = 2,
            lambda = exp_pass_td,
            lower.tail = FALSE
        )
    )

pbp_r_pass_td_y_geq10 |>
    filter(passer == "P.Mahomes", season == 2022, week == 22) |>
    select(-pass_td_y, -n_games, -n_passes, -passer_id, -week, -season)

## Regression coefficients
x <- rpois(n = 10, lambda = 1)
print(x)

glm_out_r <-
    glm(x ~ 1, family = "poisson")

print(tidy(glm_out_r))
print(tidy(glm_out_r, exponentiate = TRUE))

## example with regression coefficients
bal_td_r <- pbp_r |>
    filter(posteam == "BAL" & season == 2022) |>
    group_by(game_id, week) |>
    summarize(td_per_game = sum(touchdown, na.rm = TRUE), .groups = "drop") |>
    mutate(week = week - 1)

ggplot(bal_td_r, aes(x = week, y = td_per_game)) +
    geom_point() +
    theme_bw() +
    stat_smooth(
        method = "glm",
        formula = "y ~ x", method.args = list(family = "poisson")
    ) +
    xlab("Week") +
    ylab("Touchdowns per game") +
    scale_y_continuous(breaks = seq(0, 6)) +
    scale_x_continuous(breaks = seq(1, 20, by = 2))

## save for book
fig_6_6 <-
    ggplot(bal_td_r, aes(x = week, y = td_per_game)) +
    geom_point() +
    theme_bw() +
    stat_smooth(
        method = "glm",
        formula = "y ~ x", method.args = list(family = "poisson")
    ) +
    xlab("Week") +
    ylab("Touchdowns per game") +
    scale_y_continuous(breaks = seq(0, 6)) +
    scale_x_continuous(breaks = seq(1, 20, by = 2)) +
    theme(text = element_text(size = 13))
fig_6_6
ggsave("fig_6_6.png", fig_6_6, width = 6, height = 4.25)

glm_bal_td_r <-
    glm(td_per_game ~ week, data = bal_td_r, family = "poisson")

print(tidy(glm_bal_td_r))

print(tidy(glm_bal_td_r, exponentiate = TRUE))
