## TIP and WARNING: We highly encourage you to save you web scraped results

## load packages
library(janitor)
library(tidyverse)
library(rvest)
library(htmlTable)
library(zoo)
library(kableExtra)

## web scrape
chap_7_file <- "./data/chap_7_all_r_file.csv"
if (!file.exists(chap_7_file)) {
    draft_r <- tibble()
    for (i in seq(from = 2000, to = 2022)) {
        url <- paste0(
            "https://www.pro-football-reference.com/years/",
            i,
            "/draft.htm"
        )
        web_data <-
            read_html(url) |>
            html_nodes(xpath = '//*[@id="drafts"]') |>
            html_table()
        web_df <-
            web_data[[1]]
        web_df_clean <-
            web_df |>
            janitor::row_to_names(row_number = 1) |>
            janitor::clean_names(case = "none") |>
            mutate(Season = i) |> # add seasons
            filter(Tm != "Tm") # Remove any extra column headers
        draft_r <- bind_rows(draft_r, web_df_clean)
    }
    write_csv(draft_r, chap_7_file)
    draft_r <- read_csv(chap_7_file)
} else {
    draft_r <- read_csv(chap_7_file)
}

## rename teams
# the chargers moved to Los Angeles from San Diego
# the Raiders moved from Oakland to Las Vegas
# the Rams moved from St. Louis to Los Angeles
draft_r <-
    draft_r |>
    mutate(
        Tm = case_when(
            Tm == "SDG" ~ "LAC",
            Tm == "OAK" ~ "LVR",
            Tm == "STL" ~ "LAR",
            TRUE ~ Tm
        ),
        DrAV = ifelse(is.na(DrAV), 0, DrAV)
    )

draft_r_use <-
    draft_r |>
    select(Season, Pick, Tm, Player, Pos, wAV, DrAV)
print(draft_r_use)

## plot DrAV
draft_r_use_pre2019 <- draft_r_use |>
    mutate(
        DrAV = as.numeric(DrAV),
        wAV = as.numeric(wAV),
        Pick = as.integer(Pick)
    ) |>
    filter(Season <= 2019)

ggplot(draft_r_use_pre2019, aes(Pick, DrAV)) +
    geom_point(alpha = 0.2) +
    stat_smooth() +
    theme_bw()

## DrAV each position
draft_chart_r <-
    draft_r_use_pre2019 |>
    group_by(Pick) |>
    summarize(mean_DrAV = mean(DrAV, na.rm = TRUE)) |>
    mutate(
        mean_DrAV = ifelse(is.na(mean_DrAV), 0, mean_DrAV)
    ) |>
    mutate(
        roll_DrAV = rollapply(mean_DrAV,
            width = 13, FUN = mean,
            na.rm = TRUE, fill = "extend", partial = TRUE
        )
    )

ggplot(draft_chart_r, aes(Pick, roll_DrAV)) +
    geom_point() +
    geom_smooth() +
    theme_bw() +
    ylab("Rolling average (\u00B1 6) DrAV") +
    xlab("Draft pick")

DrAV_pick_fit_r <-
    draft_chart_r |>
    lm(formula = log(roll_DrAV + 1) ~ Pick)
summary(DrAV_pick_fit_r)

draft_chart_r <-
    draft_chart_r |>
    mutate(
        fitted_DrAV = pmax(0, exp(predict(DrAV_pick_fit_r)) - 1)
    )
draft_chart_r |>
    head()

## Jets/Colts 2018 trade evaluated
future_pick <-
    tibble(
        Pick = "Future 2nd round",
        Value = "14.8 (discounted at rate of 25%)"
    )

team <- tibble("Receiving team" = c("Jets", rep("Colts", 4)))

tbl_1 <-
    draft_chart_r |>
    filter(Pick %in% c(3, 6, 37, 49)) |>
    select(Pick, fitted_DrAV) |>
    rename(Value = fitted_DrAV) |>
    mutate(Pick = as.character(Pick), Value = as.character(round(Value, 1))) |>
    bind_rows(future_pick)

team |>
    bind_cols(tbl_1) |>
    kbl(format = "pipe") |>
    kable_styling()

future_pick <-
    tibble(
        Pick = "Future 2nd round",
        Value = "14.8 (discounted at rate of 25)"
    )

results_trade <-
    tibble(
        Team = c("Jets", rep("Colts", 5)),
        Pick = c(
            3, 6, 37,
            "49-traded for 52",
            "49-traded for 169",
            "52 in 2019"
        ),
        Player = c(
            "Sam Darnold", "Quenton Nelson", "Braden Smith",
            "Kemoko Turay", "Jordan Wilkins", "Rock Ya-Sin"
        ),
        "DrAV" = c(25, 55, 32, 5, 8, 11)
    )

results_trade |>
    kbl(format = "pipe") |>
    kable_styling()


## Are some teams better at drafting?
## R draft
draft_r_use_pre2019 <-
    draft_r_use_pre2019 |>
    left_join(draft_chart_r |>
        select(Pick, fitted_DrAV), by = "Pick")

draft_r_use_pre2019 |>
    group_by(Tm) |>
    summarize(
        total_picks = n(),
        DrAV_OE = mean(DrAV - fitted_DrAV, na.rm = TRUE),
        DrAV_sigma = sd(DrAV - fitted_DrAV, na.rm = TRUE)
    ) |>
    arrange(-DrAV_OE) |>
    print(n = Inf)

draft_r_use_pre2019 |>
    group_by(Tm) |>
    summarize(
        total_picks = n(),
        DrAV_OE = mean(DrAV - fitted_DrAV, na.rm = TRUE),
        DrAV_sigma = sd(DrAV - fitted_DrAV, na.rm = TRUE)
    ) |>
    mutate(
        se = DrAV_sigma / sqrt(total_picks),
        lower_bound = DrAV_OE - 1.96 * se,
        upper_bound = DrAV_OE + 1.96 * se
    ) |>
    arrange(-DrAV_OE) |>
    print(n = Inf)
