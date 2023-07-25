## load packages
library("tidyverse")
library("nflfastR")
library("ggthemes")

## import data
chap_2_file <- "./data/pbp_r_chap_2.csv"
if (!file.exists(chap_2_file)) {
    pbp_r <- load_pbp(2016:2022)
    write_csv(pbp_r, chap_2_file)
} else {
    pbp_r <- read_csv(chap_2_file)
}

## extract passing data
pbp_r_p <-
    pbp_r |>
    filter(play_type == "pass" & !is.na(air_yards))

pbp_r_p <-
    pbp_r_p |>
    mutate(
        pass_length_air_yards = ifelse(air_yards >= 20, "long", "short"),
        passing_yards = ifelse(is.na(passing_yards), 0, passing_yards)
    )

## Look at summary of passing data
pbp_r_p |>
    pull(passing_yards) |>
    summary()

## summarize by pass length
pbp_r_p |>
    filter(pass_length_air_yards == "short") |>
    pull(passing_yards) |>
    summary()

## filter and only look at long passes
pbp_r_p |>
    filter(pass_length_air_yards == "long") |>
    pull(passing_yards) |>
    summary()

## look at EPA for short passes
pbp_r_p |>
    filter(pass_length_air_yards == "short") |>
    pull(epa) |>
    summary()

## look at EPA for long passes
pbp_r_p |>
    filter(pass_length_air_yards == "long") |>
    pull(epa) |>
    summary()

ggplot(pbp_r, aes(x = passing_yards)) +
    geom_histogram()

pbp_r_p |>
    filter(pass_length_air_yards == "long") |>
    ggplot(aes(passing_yards)) +
    geom_histogram(binwidth = 1) +
    ylab("Count") +
    xlab("Yards gained (or lost) during passing plays on long passes") +
    theme_bw()

## updated for book
fig_2_4 <-
    pbp_r_p |>
    filter(pass_length_air_yards == "long") |>
    ggplot(aes(passing_yards)) +
    geom_histogram(binwidth = 1) +
    ylab("Count") +
    xlab("Yards gained (or lost) during passing plays on long passes") +
    theme_bw() +
    theme(axis.text = element_text(size = 13))
fig_2_4
ggsave("fig_2_4.png", width = 6, height = 4.25)

## boxplot of passing yards by pass length
ggplot(pbp_r_p, aes(x = pass_length_air_yards, y = passing_yards)) +
    geom_boxplot() +
    theme_bw() +
    xlab("Pass length in yards (long >= 20 yards, short < 20 yards)") +
    ylab("Yards gained (or lost) during a passing play")

fig_2_6 <-
    ggplot(pbp_r_p, aes(x = pass_length_air_yards, y = passing_yards)) +
    geom_boxplot() +
    theme_bw() +
    xlab("Pass length in yards (long >= 20 yards, short < 20 yards)") +
    ylab("Yards gained (or lost) during a passing play") +
    theme(axis.text = element_text(size = 13))
fig_2_6
ggsave("fig_2_6.png", width = 6, height = 4.25)


## player-level stability
pbp_r_p_s <- pbp_r_p |>
    group_by(passer_player_name, passer_player_id, season) |>
    summarize(
        ypa = mean(passing_yards, na.rm = TRUE),
        n = n(),
        .groups = "drop"
    )

## look at results
## you will likely want to use print(n = Inf) to see all results
pbp_r_p_s |>
    arrange(-ypa) |>
    print()

## calculate ypa and only look at players with more than 100 plays
pbp_r_p_100 <- pbp_r_p |>
    group_by(passer_id, passer, season) |>
    summarize(n = n(), ypa = mean(passing_yards), .groups = "drop") |>
    filter(n >= 100) |>
    arrange(-ypa)

## Look at top 20 results
pbp_r_p_100 |>
    print(n = 20)

## calculate at play-by-play passer data by season and pass length
air_yards_r <- pbp_r_p |>
    select(passer_id, passer, season, pass_length_air_yards, passing_yards) |>
    arrange(passer_id, season, pass_length_air_yards) |>
    group_by(passer_id, passer, pass_length_air_yards, season) |>
    summarize(n = n(), ypa = mean(passing_yards), .groups = "drop") |>
    filter(
        (n >= 100 & pass_length_air_yards == "short") |
            (n >= 30 & pass_length_air_yards == "long")
    ) |>
    select(-n)

## create lag data
air_yards_lag_r <- air_yards_r |>
    mutate(season = season + 1) |>
    rename(ypa_last = ypa)

## join lag data
pbp_r_p_s_pl <-
    air_yards_r |>
    inner_join(air_yards_lag_r,
        by = c("passer_id", "pass_length_air_yards", "season", "passer")
    )

## look at results for two passers
pbp_r_p_s_pl |>
    filter(passer %in% c("T.Brady", "A.Rodgers")) |>
    print(n = Inf)

## glimpse as dataframe
pbp_r_p_s_pl |>
    glimpse()

## see number of unique quarterbacks
pbp_r_p_s_pl |>
    distinct(passer_id) |>
    nrow()

## look at data using a scatterplot
scatter_ypa_r <-
    ggplot(pbp_r_p_s_pl, aes(x = ypa_last, y = ypa)) +
    geom_point() +
    facet_grid(cols = vars(pass_length_air_yards)) +
    labs(
        x = "Yards per Attempt, Year n",
        y = "Yards per Attempt, Year n + 1"
    ) +
    theme_bw() +
    theme(strip.background = element_blank())
print(scatter_ypa_r)

## update resolution for book
fig_2_7 <-
    scatter_ypa_r +
    theme(axis.text = element_text(size = 13))
fig_2_7
ggsave("fig_2_7.png", fig_2_7, width = 6, height = 4.25)

## add geom_smooth() to the previously saved plot
scatter_ypa_r +
    geom_smooth(method = "lm")

## update resolution for book
fig_2_8 <-
    scatter_ypa_r +
    geom_smooth(method = "lm") +
    theme(axis.text = element_text(size = 13))

print(fig_2_8)
ggsave("fig_2_8.png", fig_2_8, width = 6, height = 4.25)

## obtain correlation
pbp_r_p_s_pl |>
    filter(!is.na(ypa) & !is.na(ypa_last)) |>
    group_by(pass_length_air_yards) |>
    summarize(correlation = cor(ypa, ypa_last))
