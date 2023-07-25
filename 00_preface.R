## Load packages
library(tidyverse)
library(nflfastR)
library(ggthemes)

# load data
game_schedule <-
  nflreadr::load_schedules(2016:2022)

# format data
gb_games <-
  game_schedule |>
  as_tibble() |>
  filter(away_team == "GB" | home_team == "GB") |>
  mutate(
    gb_score = ifelse(away_team == "GB", away_score, home_score),
    other_score = ifelse(away_team != "GB", away_score, home_score),
    gb_home = ifelse(away_team == "GB", "Away", "Home"),
    gb_home = factor(gb_home, c("Home", "Away"))
  ) |>
  select(
    away_team, home_team, away_score, home_score,
    gb_score, other_score, gb_home, game_id
  ) |>
  mutate(
    score_diff = gb_score - other_score,
    gb_win = ifelse(gb_score > other_score, "Win", "Lose"),
    gb_win = factor(gb_win, levels = c("Win", "Lose"))
  )

# create and save plot 1
plot_1 <-
  ggplot(
    gb_games |> filter(score_diff != 0),
    aes(x = gb_home, y = score_diff)
  ) +
  geom_point() +
  theme_bw() +
  scale_color_colorblind() +
  ylab("Point difference") +
  xlab("Game location")
plot_1
ggsave("plot_1.png", plot_1, width = 6, heigh = 4)

# create and save plot 2
plot_2 <-
  ggplot(
    gb_games |> filter(score_diff != 0),
    aes(
      x = gb_home, y = score_diff,
      group = gb_win,
      shape = gb_win
    )
  ) +
  geom_point(position = position_dodge(width = 0.1)) +
  theme_bw() +
  scale_shape("Green Bay\noutcome") +
  ylab("Point difference") +
  xlab("Game location")
print(plot_2)
ggsave("plot_2.png", plot_2, width = 6, heigh = 4, dpi = 400)

# extract out summary statistics for in text use
gb_games |>
  filter(score_diff != 0) |>
  group_by(gb_home) |>
  summarize(mean_diff = mean(score_diff))

gb_games |>
  filter(score_diff != 0) |>
  group_by(gb_win, gb_home) |>
  summarize(mean_diff = mean(score_diff))

gb_games |>
  filter(score_diff != 0) |>
  summarize(mean_diff = mean(score_diff))
