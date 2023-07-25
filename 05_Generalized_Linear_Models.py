## load packages
import pandas as pd
import numpy as np
import nfl_data_py as nfl
import statsmodels.formula.api as smf
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sns
import os

## load data and filter data
chap_5_file = "./data/pbp_py_chap_5.csv"
if os.path.isfile(chap_5_file):
    pbp_py = pd.read_csv(chap_5_file, low_memory=False)
else:
    seasons = range(2016, 2022 + 1)
    pbp_py = nfl.import_pbp_data(seasons)
    pbp_py.to_csv(chap_5_file)

pbp_py_pass = pbp_py.query(
    'play_type == "pass" & passer_id.notnull() &' + "air_yards.notnull()"
).reset_index()

# Change theme for chapter
sns.set_theme(style="whitegrid", palette="colorblind")

# Filter more and then plot
pass_pct_py = (
    pbp_py_pass.query("0 < air_yards <= 20")
    .groupby("air_yards")
    .agg({"complete_pass": ["mean"]})
)

pass_pct_py.columns = list(map("_".join, pass_pct_py.columns))

pass_pct_py.reset_index(inplace=True)
pass_pct_py.rename(columns={"complete_pass_mean": "comp_pct"}, inplace=True)

sns.regplot(data=pass_pct_py, x="air_yards", y="comp_pct", line_kws={"color": "red"})
plt.show()

## building a glm
complete_ay_py = smf.glm(
    formula="complete_pass ~ air_yards", data=pbp_py_pass, family=sm.families.Binomial()
).fit()

complete_ay_py.summary()

## logistic plot
sns.regplot(
    data=pbp_py_pass,
    x="air_yards",
    y="complete_pass",
    logistic=True,
    line_kws={"color": "red"},
    scatter_kws={"alpha": 0.05},
)
plt.show()

## glm completion percentage predicted
pbp_py_pass["exp_completion"] = complete_ay_py.predict()
pbp_py_pass["cpoe"] = pbp_py_pass["complete_pass"] - pbp_py_pass["exp_completion"]

## cpoe
cpoe_py = pbp_py_pass.groupby(["season", "passer_id", "passer"]).agg(
    {"cpoe": ["count", "mean"], "complete_pass": ["mean"]}
)
cpoe_py.columns = list(map("_".join, cpoe_py.columns))
cpoe_py.reset_index(inplace=True)
cpoe_py = cpoe_py.rename(
    columns={"cpoe_count": "n", "cpoe_mean": "cpoe", "complete_pass_mean": "compl"}
).query("n > 100")
print(cpoe_py.sort_values("cpoe", ascending=False))

## remove missing data and format data
pbp_py_pass["down"] = pbp_py_pass["down"].astype(str)
pbp_py_pass["qb_hit"] = pbp_py_pass["qb_hit"].astype(str)
pbp_py_pass_no_miss = pbp_py_pass[
    [
        "passer",
        "passer_id",
        "season",
        "down",
        "qb_hit",
        "complete_pass",
        "ydstogo",
        "yardline_100",
        "air_yards",
        "pass_location",
    ]
].dropna(axis=0)

## build and fit model
complete_more_py = smf.glm(
    formula="complete_pass ~ down * ydstogo + "
    + "yardline_100 + air_yards + "
    + "pass_location + qb_hit",
    data=pbp_py_pass_no_miss,
    family=sm.families.Binomial(),
).fit()

## extract output and calculate CPOE
pbp_py_pass_no_miss["exp_completion"] = complete_more_py.predict()
pbp_py_pass_no_miss["cpoe"] = (
    pbp_py_pass_no_miss["complete_pass"] - pbp_py_pass_no_miss["exp_completion"]
)

## summarize outputs, reformat, and rename
cpoe_py_more = pbp_py_pass_no_miss.groupby(["season", "passer_id", "passer"]).agg(
    {"cpoe": ["count", "mean"], "complete_pass": ["mean"], "exp_completion": ["mean"]}
)

cpoe_py_more.columns = list(map("_".join, cpoe_py_more.columns))
cpoe_py_more.reset_index(inplace=True)

cpoe_py_more = cpoe_py_more.rename(
    columns={
        "cpoe_count": "n",
        "cpoe_mean": "cpoe",
        "complete_pass_mean": "compl",
        "exp_completion_mean": "exp_completion",
    }
).query("n > 100")

## print outputs
print(cpoe_py_more.sort_values("cpoe", ascending=False))

## stability
#  keep only the columns needed
cols_keep = ["season", "passer_id", "passer", "cpoe", "compl", "exp_completion"]

# create current dataframe
cpoe_now_py = cpoe_py_more[cols_keep].copy()

# create last-year's dataframe
cpoe_last_py = cpoe_now_py[cols_keep].copy()

# rename columns
cpoe_last_py.rename(
    columns={
        "cpoe": "cpoe_last",
        "compl": "compl_last",
        "exp_completion": "exp_completion_last",
    },
    inplace=True,
)
# add 1 to season
cpoe_last_py["season"] += 1

# merge together
cpoe_lag_py = cpoe_now_py.merge(
    cpoe_last_py, how="inner", on=["passer_id", "passer", "season"]
)

## look at pass completion stability
cpoe_lag_py[["compl_last", "compl"]].corr()

## look at cpoe stability
cpoe_lag_py[["cpoe_last", "cpoe"]].corr()
