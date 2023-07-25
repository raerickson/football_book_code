## load packages
library(tidyverse)
library(ggthemes)
priors <-
    tibble(
        x = seq(0, 1, length.out = 200),
        humble = dbeta(x, 2, 2),
        over = dbeta(x, 8, 2),
        under = dbeta(x, 2, 8)
    ) |>
    pivot_longer(!x,
        names_to = "Confidence",
        values_to = "Probability"
    )

ggplot(
    priors,
    aes(
        x = x, y = Probability, color = Confidence,
        linetype = Confidence
    )
) +
    geom_line() +
    theme_bw() +
    scale_color_colorblind() +
    xlab("Prior probability of being correct")

likelihood <-
    tibble(
        x = seq(0, 1, length.out = 200),
        Probability = dbeta(x, 30, 20)
    )

ggplot(
    likelihood,
    aes(x = x, y = Probability)
) +
    geom_line() +
    theme_bw() +
    scale_color_colorblind() +
    xlab("Observed probability of being correct")

posterior <-
    tibble(
        x = seq(0, 1, length.out = 200),
        humble = dbeta(x, 2 + 30, 2 + 20),
        over = dbeta(x, 8 + 30, 2 + 20),
        under = dbeta(x, 2 + 30, 8 + 20)
    ) |>
    pivot_longer(-x,
        names_to = "Confidence",
        values_to = "Probability"
    )

ggplot(
    posterior,
    aes(
        x = x, y = Probability, color = Confidence,
        linetype = Confidence
    )
) +
    geom_line() +
    theme_bw() +
    scale_color_colorblind() +
    xlab("Prior probability of being correct")
