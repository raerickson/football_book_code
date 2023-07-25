## load packages
library(tidyverse)
library(rvest)
library(htmlTable)
library(multiUS)
library(ggthemes)
library(RColorBrewer)


chap_8_combine_r_file <- "./data/chap_8_combine_r_file.csv"
if (!file.exists(chap_8_combine_r_file)) {
    combine_r <- tibble()
    for (i in seq(from = 2000, to = 2023)) {
        url <- paste0(
            "https://www.pro-football-reference.com/draft/",
            i, "-combine.htm"
        )
        web_data <-
            read_html(url) |>
            html_table()
        web_data_clean <-
            web_data[[1]] |>
            mutate(Season = i) |>
            filter(Ht != "Ht")
        combine_r <- bind_rows(combine_r, web_data_clean)
    }
    write_csv(combine_r, chap_8_combine_r_file)
} else {
    combine_r <- read_csv(chap_8_combine_r_file)
}

combine_r <-
    combine_r |>
    mutate(
        ht_ft = as.numeric(str_sub(Ht, 1, 1)),
        ht_in = str_sub(Ht, 2, 4),
        ht_in = as.numeric(str_remove(ht_in, "-")),
        Ht = ht_ft * 12 + ht_in
    ) |>
    select(-ht_ft, -ht_in)

summary(combine_r)

ggplot(combine_r, aes(x = Ht, y = Wt)) +
    geom_point() +
    theme_bw() +
    xlab("Player Height (inches)") +
    ylab("Player Weight (pounds)") +
    geom_smooth(method = "lm", formula = y ~ x)

ggplot(combine_r, aes(x = Wt, y = `40yd`)) +
    geom_point() +
    theme_bw() +
    xlab("Player Weight (pounds)") +
    ylab("Player 40-yard dash (seconds)") +
    geom_smooth(method = "lm", formula = y ~ x)

ggplot(combine_r, aes(x = `40yd`, y = Vertical)) +
    geom_point() +
    theme_bw() +
    xlab("Player 40-yard dash (seconds)") +
    ylab("Player vertical jump (inches)") +
    geom_smooth(method = "lm", formula = y ~ x)

## save figure for book
fig_8_6 <-
    ggplot(combine_r, aes(x = `40yd`, y = Vertical)) +
    geom_point() +
    theme_bw() +
    xlab("Player 40-yard dash (seconds)") +
    ylab("Player vertical jump (inches)") +
    geom_smooth(method = "lm", formula = y ~ x)
ggsave("fig_8_6.png", fig_8_6, width = 6, height = 4.25)

ggplot(combine_r, aes(x = `40yd`, y = `3Cone`)) +
    geom_point() +
    theme_bw() +
    xlab("Player 40-yard dash (seconds)") +
    ylab("Player 3 cone drill (inches)") +
    geom_smooth(method = "lm", formula = y ~ x)

## save figure for book
fig_8_9 <-
    ggplot(combine_r, aes(x = `40yd`, y = `3Cone`)) +
    geom_point() +
    theme_bw() +
    xlab("Player 40-yard dash (seconds)") +
    ylab("Player 3 cone drill (inches)") +
    geom_smooth(method = "lm", formula = y ~ x)
ggsave("fig_8_9.png", fig_8_9, width = 6, height = 4.25)


## impute missing data
combine_knn_r_file <- "combine_knn_r.csv"
if (!file.exists(combine_knn_r_file)) {
    imput_input <-
        combine_r |>
        select(Ht:Shuttle) |>
        as.data.frame()
    knn_out_r <-
        KNNimp(imput_input, k = 10, scale = TRUE, meth = "median") |>
        as_tibble()
    combine_knn_r <-
        combine_r |>
        select(Player:College, Season) |>
        bind_cols(knn_out_r)
    write_csv(x = combine_knn_r, file = combine_knn_r_file)
} else {
    combine_knn_r <- read_csv(combine_knn_r_file)
}

combine_knn_r |>
    summary()

## PCA
wt_ht_r <-
    combine_r |>
    select(Wt, Ht) |>
    filter(!is.na(Wt) & !is.na(Ht))
pca_fit_wt_ht_r <-
    prcomp(wt_ht_r)

summary(pca_fit_wt_ht_r)

pca_fit_wt_ht_r$x |>
    as_tibble() |>
    ggplot(aes(x = PC1, y = PC2)) +
    geom_point() +
    theme_bw()

print(pca_fit_wt_ht_r)

## PCA on all data
scaled_combine_knn_r <-
    scale(combine_knn_r |>
        select(Ht:Shuttle))
pca_fit_r <-
    prcomp(scaled_combine_knn_r)

print(pca_fit_r$rotation)

print(pca_fit_r$sdev^2)

pca_var_r <-
    pca_fit_r$sdev^2
pca_percent_r <-
    round(pca_var_r / sum(pca_var_r) * 100, 2)
print(pca_percent_r)

combine_knn_r <-
    combine_knn_r |>
    bind_cols(pca_fit_r$x)

ggplot(combine_knn_r, aes(x = PC1, y = PC2)) +
    geom_point() +
    theme_bw() +
    xlab(paste0("PC1 = ", pca_percent_r[1], "%")) +
    ylab(paste0("PC2 = ", pca_percent_r[2], "%"))

ggplot(combine_knn_r, aes(x = PC1, y = PC2, color = PC3)) +
    geom_point() +
    theme_bw() +
    xlab(paste0("PC1 = ", pca_percent_r[1], "%")) +
    ylab(paste0("PC2 = ", pca_percent_r[2], "%")) +
    scale_color_continuous(paste0(
        "PC3 = ",
        pca_percent_r[3], "%"
    ), low = "skyblue", high = "navyblue")


color_count <- length(unique(combine_knn_r$Pos))
get_palette <- colorRampPalette(brewer.pal(9, "Set1"))

ggplot(combine_knn_r, aes(x = PC1, y = PC2, color = Pos)) +
    geom_point(alpha = 0.75) +
    theme_bw() +
    xlab(paste0("PC1 = ", pca_percent_r[1], "%")) +
    ylab(paste0("PC2 = ", pca_percent_r[2], "%")) +
    scale_color_manual("Player position", values = get_palette(color_count))

## Combine cluster data
set.seed(123)
k_means_fit_r <-
    kmeans(
        combine_knn_r |>
            select(PC1, PC2),
        centers = 6, iter.max = 10
    )

combine_knn_r <-
    combine_knn_r |>
    mutate(cluster = k_means_fit_r$cluster)

combine_knn_r |>
    select(Pos, Ht:Shuttle, cluster) |>
    head()

combine_knn_r |>
    filter(cluster == 1) |>
    group_by(Pos) |>
    summarize(n = n(), Ht = mean(Ht), Wt = mean(Wt)) |>
    arrange(-n) |>
    print(n = Inf)

combine_knn_r_cluster <-
    combine_knn_r |>
    group_by(cluster, Pos) |>
    summarize(
        n = n(), Ht = mean(Ht),
        Wt = mean(Wt), .groups = "drop"
    )

combine_knn_r_cluster |>
    ggplot(aes(x = n, y = Pos)) +
    geom_col(position = "dodge") +
    theme_bw() +
    facet_wrap(vars(cluster)) +
    theme(strip.background = element_blank()) +
    ylab("Position") +
    xlab("Count")

## update figure for book
fig_8_19 <-
    combine_knn_r_cluster |>
    ggplot(aes(x = n, y = Pos)) +
    geom_col(position = "dodge") +
    theme_bw() +
    facet_wrap(vars(cluster)) +
    theme(
        strip.background = element_blank(),
        axis.text = element_text(size = 9)
    ) +
    ylab("Position") +
    xlab("Count")
ggsave("fig_8_19.png", fig_8_19, width = 6, height = 4.75, dpi = 600)

combine_knn_r_cluster |>
    group_by(cluster) |>
    summarize(ave_ht = mean(Ht), ave_wt = mean(Wt))
