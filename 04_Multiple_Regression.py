## load packages
import pandas as pd
import numpy as np
import nfl_data_py as nfl
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import seaborn as sns
import os

## load data
chap_4_file = "./data/pbp_py_chap_4.csv"
if os.path.isfile(chap_4_file):
    pbp_py = pd.read_csv(chap_4_file, low_memory=False)
else:
    seasons = range(2016, 2022 + 1)
    pbp_py = nfl.import_pbp_data(seasons)
    pbp_py.to_csv(chap_4_file)


pbp_py_run = pbp_py.query(
    'play_type == "run" & rusher_id.notnull() &'
    + "down.notnull() & run_location.notnull()"
).reset_index()

pbp_py_run.loc[pbp_py_run.rushing_yards.isnull(), "rushing_yards"] = 0

## set theme
sns.set_theme(style="whitegrid", palette="colorblind")

# Change down to be an integer
pbp_py_run.down = pbp_py_run.down.astype(str)

# Plot rushing yards by down
g = sns.FacetGrid(data=pbp_py_run, col="down", col_wrap=2)
g.map_dataframe(sns.histplot, x="rushing_yards")
plt.show()

plt.figure(figsize=(6, 4.25), dpi=600)
g = sns.FacetGrid(data=pbp_py_run, col="down", col_wrap=2)
g.map_dataframe(sns.histplot, x="rushing_yards")
plt.savefig("fig_4_1.png", dpi=600)
plt.close()

## Look at only plays with 10 yards to go
sns.boxplot(data=pbp_py_run.query("ydstogo == 10"), x="down", y="rushing_yards")
plt.show()

## scatterplot for trendline
sns.regplot(
    data=pbp_py_run,
    x="yardline_100",
    y="rushing_yards",
    scatter_kws={"alpha": 0.25},
    line_kws={"color": "red"},
)
plt.show()

## Bin and plot
pbp_py_run_y100 = pbp_py_run.groupby("yardline_100").agg({"rushing_yards": ["mean"]})
pbp_py_run_y100.columns = list(map("_".join, pbp_py_run_y100.columns))
pbp_py_run_y100.reset_index(inplace=True)

sns.regplot(
    data=pbp_py_run_y100,
    x="yardline_100",
    y="rushing_yards_mean",
    scatter_kws={"alpha": 0.25},
    line_kws={"color": "red"},
)
plt.show()

## Boxplot by run location
sns.boxplot(data=pbp_py_run, x="run_location", y="rushing_yards")
plt.show()

## Score differential
pbp_py_run_sd = pbp_py_run.groupby("score_differential").agg(
    {"rushing_yards": ["mean"]}
)
pbp_py_run_sd.columns = list(map("_".join, pbp_py_run_sd.columns))
pbp_py_run_sd.reset_index(inplace=True)

## plot score differential
sns.regplot(
    data=pbp_py_run_sd,
    x="score_differential",
    y="rushing_yards_mean",
    scatter_kws={"alpha": 0.25},
    line_kws={"color": "red"},
)
plt.show()

## Multiple regression Python
pbp_py_run.down = pbp_py_run.down.astype(str)
expected_yards_py = smf.ols(
    data=pbp_py_run,
    formula="rushing_yards ~ 1 + down + ydstogo + "
    + "down:ydstogo + yardline_100 + "
    + "run_location + score_differential",
).fit()
pbp_py_run["ryoe"] = expected_yards_py.resid

## Look at model outputs
print(expected_yards_py.summary())

## Analyze RYOE
ryoe_py = pbp_py_run.groupby(["season", "rusher_id", "rusher"]).agg(
    {"ryoe": ["count", "sum", "mean"], "rushing_yards": ["mean"]}
)
ryoe_py.columns = list(map("_".join, ryoe_py.columns))
ryoe_py.reset_index(inplace=True)
ryoe_py = ryoe_py.rename(
    columns={
        "ryoe_count": "n",
        "ryoe_sum": "ryoe_total",
        "ryoe_mean": "ryoe_per",
        "rushing_yards_mean": "yards_per_carry",
    }
).query("n > 50")
print(ryoe_py.sort_values("ryoe_total", ascending=False))

## sort by RYOE per carry
print(ryoe_py.sort_values("ryoe_per", ascending=False))

## RYOE stability
#  keep only the columns needed
cols_keep = ["season", "rusher_id", "rusher", "ryoe_per", "yards_per_carry"]

# create current dataframe
ryoe_now_py = ryoe_py[cols_keep].copy()

# create last-year's dataframe
ryoe_last_py = ryoe_py[cols_keep].copy()

# rename columns
ryoe_last_py.rename(
    columns={"ryoe_per": "ryoe_per_last", "yards_per_carry": "yards_per_carry_last"},
    inplace=True,
)

# add 1 to season
ryoe_last_py["season"] += 1

# merge together
ryoe_lag_py = ryoe_now_py.merge(
    ryoe_last_py, how="inner", on=["rusher_id", "rusher", "season"]
)

## Stability for yards per carry
ryoe_lag_py[["yards_per_carry_last", "yards_per_carry"]].corr()

## Stability for RYOE
ryoe_lag_py[["ryoe_per_last", "ryoe_per"]].corr()
