## TIP and WARNING: We highly encourage you to save you web scraped results

## Load packages
import pandas as pd
import seaborn as sns
import os.path
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf
import numpy as np
import os

## download data
## be careful to hit webpage too many time and get locked out~
url = "https://www.pro-football-reference.com/years/2022/draft.htm"

chap_7_2022_py_file = "chap_7_2022_py_file.csv"

if os.path.isfile(chap_7_2022_py_file):
    draft_py = pd.read_csv(chap_7_2022_py_file)
else:
    draft_py = pd.read_html(url, header=1)[0]
    draft_py.to_csv(chap_7_2022_py_file)


draft_py.loc[draft_py["DrAV"].isnull(), "DrAV"] = 0

print(draft_py)

draft_py[["Rnd", "Pick", "Tm", "Sk", "College/Univ", "Unnamed: 28"]]

## loop over multiple years

chap_7_all_py_file = "chap_7_all_py_file.csv"

if os.path.isfile(chap_7_all_py_file):
    draft_py = pd.read_csv(chap_7_all_py_file)
else:
    draft_py = pd.DataFrame()
    for i in range(2000, 2022 + 1):
        url = "https://www.pro-football-reference.com/years/" + str(i) + "/draft.htm"
        web_data = pd.read_html(url, header=1)[0]
        web_data["Season"] = i
        web_data = web_data.query('Tm != "Tm"')
        draft_py = pd.concat([draft_py, web_data])
    draft_py.to_csv(chap_7_all_py_file)

draft_py.reset_index(drop=True, inplace=True)

## rename teams
# the Chargers moved to Los Angeles from San Diego
# the Raiders moved from Oakland to Las Vegas
# the Rams moved from St. Louis to Los Angeles

conditions = [
    (draft_py.Tm == "SDG"),
    (draft_py.Tm == "OAK"),
    (draft_py.Tm == "STL"),
]
choices = ["LAC", "LVR", "LAR"]
draft_py["Tm"] = np.select(conditions, choices, default=draft_py.Tm)

## replace missing DrAV with 0
draft_py.loc[draft_py["DrAV"].isnull(), "DrAV"] = 0
draft_py.to_csv("data_py.csv", index=False)

print(draft_py.head())

print(draft_py.columns)

## only look at select columns of interest
draft_py_use = draft_py[["Season", "Pick", "Tm", "Player", "Pos", "wAV", "DrAV"]]

print(draft_py_use)

## Plot for DrAV
# Change theme for chapter
sns.set_theme(style="whitegrid", palette="colorblind")

draft_py_use_pre2019 = draft_py_use.query("Season <= 2019")

## format columns as numeric or integers
draft_py_use_pre2019 = draft_py_use_pre2019.astype({"Pick": int, "DrAV": float})

sns.regplot(
    data=draft_py_use_pre2019,
    x="Pick",
    y="DrAV",
    line_kws={"color": "red"},
    scatter_kws={"alpha": 0.2},
)
plt.show()

## DrAV for each pick position
draft_chart_py = draft_py_use_pre2019.groupby(["Pick"]).agg({"DrAV": ["mean"]})
draft_chart_py.columns = list(map("_".join, draft_chart_py.columns))
draft_chart_py.loc[draft_chart_py.DrAV_mean.isnull()] = 0
draft_chart_py["roll_DrAV"] = (
    draft_chart_py["DrAV_mean"].rolling(window=13, min_periods=1, center=True).mean()
)

sns.scatterplot(draft_chart_py, x="Pick", y="roll_DrAV")
plt.show()

## regression
draft_chart_py.reset_index(inplace=True)
draft_chart_py["roll_DrAV_log"] = np.log(draft_chart_py["roll_DrAV"] + 1)
DrAV_pick_fit_py = smf.ols(formula="roll_DrAV_log ~ Pick", data=draft_chart_py).fit()
print(DrAV_pick_fit_py.summary())

draft_chart_py["fitted_DrAV"] = np.exp(DrAV_pick_fit_py.predict()) - 1
draft_chart_py.head()

## are some teams better at drafting?
draft_py_use_pre2019 = draft_py_use_pre2019.merge(
    draft_chart_py[["Pick", "fitted_DrAV"]], on="Pick"
)
draft_py_use_pre2019["OE"] = (
    draft_py_use_pre2019["DrAV"] - draft_py_use_pre2019["fitted_DrAV"]
)
draft_py_use_pre2019.groupby("Tm").agg(
    {"OE": ["count", "mean", "std"]}
).reset_index().sort_values([("OE", "mean")], ascending=False)

draft_py_use_pre2019 = draft_py_use_pre2019.merge(
    draft_chart_py[["Pick", "fitted_DrAV"]], on="Pick"
)

draft_py_use_pre2019_tm = (
    draft_py_use_pre2019.groupby("Tm")
    .agg({"OE": ["count", "mean", "std"]})
    .reset_index()
    .sort_values([("OE", "mean")], ascending=False)
)

draft_py_use_pre2019_tm.columns = list(map("_".join, draft_py_use_pre2019_tm.columns))
draft_py_use_pre2019_tm.reset_index(inplace=True)

draft_py_use_pre2019_tm["se"] = draft_py_use_pre2019_tm["OE_std"] / np.sqrt(
    draft_py_use_pre2019_tm["OE_count"]
)

draft_py_use_pre2019_tm["lower_bound"] = (
    draft_py_use_pre2019_tm["OE_mean"] - 1.96 * draft_py_use_pre2019_tm["se"]
)

draft_py_use_pre2019_tm["upper_bound"] = (
    draft_py_use_pre2019_tm["OE_mean"] + 1.96 * draft_py_use_pre2019_tm["se"]
)

print(draft_py_use_pre2019_tm)
