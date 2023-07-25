## load packages
import pandas as pd
import numpy as np
import nfl_data_py as nfl
import statsmodels.formula.api as smf
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import poisson
import os

## load data
chap_6_file = "./data/pbp_py_chap_6.csv"
if os.path.isfile(chap_6_file):
    pbp_py = pd.read_csv(chap_6_file, low_memory=False)
else:
    seasons = range(2016, 2022 + 1)
    pbp_py = nfl.import_pbp_data(seasons)
    pbp_py.to_csv(chap_6_file)

pbp_py_pass = pbp_py.query("passer_id.notnull()").reset_index()

## format data
pbp_py_pass.loc[pbp_py_pass.pass_touchdown.isnull(), "pass_touchdown"] = 0
pbp_py_pass.loc[pbp_py_pass.passer.isnull(), "passer"] = "none"
pbp_py_pass.loc[pbp_py_pass.passer_id.isnull(), "passer_id"] = "none"
pbp_py_pass_td_y = pbp_py_pass.groupby(["season", "week", "passer_id", "passer"]).agg(
    {"pass_touchdown": ["sum"], "total_line": ["count", "mean"]}
)

pbp_py_pass_td_y.columns = list(map("_".join, pbp_py_pass_td_y.columns))
pbp_py_pass_td_y.reset_index(inplace=True)

pbp_py_pass_td_y.rename(
    columns={
        "pass_touchdown_sum": "pass_td_y",
        "total_line_mean": "total_line",
        "total_line_count": "n_passes",
    },
    inplace=True,
)

pbp_py_pass_td_y = pbp_py_pass_td_y.query("n_passes >= 10")

## print summary output to screen
pbp_py_pass_td_y.groupby("pass_td_y").agg({"n_passes": "count"})

## describe data to see a different summary
pbp_py_pass_td_y.describe()

## calculate mean and use with Poisson
pass_td_y_mean_py = pbp_py_pass_td_y.pass_td_y.mean()

plot_pos_py = pd.DataFrame(
    {
        "x": range(0, 7),
        "expected": [poisson.pmf(x, pass_td_y_mean_py) for x in range(0, 7)],
    }
)

sns.histplot(pbp_py_pass_td_y["pass_td_y"], stat="probability")
plt.plot(plot_pos_py.x, plot_pos_py.expected)
plt.show()

## individual player total for QB
# pass_ty_d greater than or equal to 10 per week
pbp_py_pass_td_y_geq10 = pbp_py_pass_td_y.query("n_passes >= 10")

# take the average touchdown passes for each QB for the previous season
# and current season up to the current game
x_py = pd.DataFrame()
for season_idx in range(2017, 2022 + 1):
    for week_idx in range(1, 22 + 1):
        week_calc_py = (
            pbp_py_pass_td_y_geq10.query(
                "(season == "
                + str(season_idx - 1)
                + ") |"
                + "(season == "
                + str(season_idx)
                + "&"
                + "week < "
                + str(week_idx)
                + ")"
            )
            .groupby(["passer_id", "passer"])
            .agg({"pass_td_y": ["count", "mean"]})
        )
        week_calc_py.columns = list(map("_".join, week_calc_py.columns))
        week_calc_py.reset_index(inplace=True)
        week_calc_py.rename(
            columns={"pass_td_y_count": "n_games", "pass_td_y_mean": "pass_td_rate"},
            inplace=True,
        )
        week_calc_py["season"] = season_idx
        week_calc_py["week"] = week_idx
        x_py = pd.concat([x_py, week_calc_py])

## look at example output
x_py.query('passer == "P.Mahomes"').tail()

## include game total
pbp_py_pass_td_y_geq10 = pbp_py_pass_td_y_geq10.query("season != 2016").merge(
    x_py, on=["season", "week", "passer_id", "passer"], how="inner"
)

## Poisson regression
pass_fit_py = smf.glm(
    formula="pass_td_y ~ pass_td_rate + total_line",
    data=pbp_py_pass_td_y_geq10,
    family=sm.families.Poisson(),
).fit()

pbp_py_pass_td_y_geq10["exp_pass_td"] = pass_fit_py.predict()

print(pass_fit_py.summary())

## look at coefficients
np.exp(pass_fit_py.params)

## Look at Mahomes's for Super Bowl LVII
# specify filter criteria on own line for space
filter_by = 'passer == "P.Mahomes" & season == 2022 & week == 22'
# specify columns on own line for space
cols_look = [
    "season",
    "week",
    "passer",
    "total_line",
    "n_games",
    "pass_td_rate",
    "exp_pass_td",
]

pbp_py_pass_td_y_geq10.query(filter_by)[cols_look]

## PMF and CDF
pbp_py_pass_td_y_geq10["p_0_td"] = poisson.pmf(
    k=0, mu=pbp_py_pass_td_y_geq10["exp_pass_td"]
)
pbp_py_pass_td_y_geq10["p_1_td"] = poisson.pmf(
    k=1, mu=pbp_py_pass_td_y_geq10["exp_pass_td"]
)
pbp_py_pass_td_y_geq10["p_2_td"] = poisson.pmf(
    k=2, mu=pbp_py_pass_td_y_geq10["exp_pass_td"]
)
pbp_py_pass_td_y_geq10["p_g2_td"] = 1 - poisson.cdf(
    k=2, mu=pbp_py_pass_td_y_geq10["exp_pass_td"]
)

# specify filter criteria on own line for space
filter_by = 'passer == "P.Mahomes" & season == 2022 & week == 22'

# specify columns on own line for space
cols_look = [
    "passer",
    "total_line",
    "n_games",
    "pass_td_rate",
    "exp_pass_td",
    "p_0_td",
    "p_1_td",
    "p_2_td",
    "p_g2_td",
]

pbp_py_pass_td_y_geq10.query(filter_by)[cols_look]

## Regression coefficients
x = poisson.rvs(mu=1, size=10)
print(x)

# create dataframe for glm
df_py = pd.DataFrame({"x": x})

# fit GLM
glm_out_py = smf.glm(formula="x ~ 1", data=df_py, family=sm.families.Poisson()).fit()

print(glm_out_py.params)
print(np.exp(glm_out_py.params))

## example with regression coefficients
# subset the data
bal_td_py = (
    pbp_py.query('posteam=="BAL" & season == 2022')
    .groupby(["game_id", "week"])
    .agg({"touchdown": ["sum"]})
)

# reformat the columns
bal_td_py.columns = list(map("_".join, bal_td_py.columns))
bal_td_py.reset_index(inplace=True)

# shift week so intercept 0 = week 1
bal_td_py["week"] = bal_td_py["week"] - 1

# create list of weeks for plot
weeks_plot = np.linspace(start=0, stop=18, num=10)
weeks_plot

ax = sns.regplot(data=bal_td_py, x="week", y="touchdown_sum")
ax.set_xticks(ticks=weeks_plot, labels=weeks_plot)
plt.xlabel("Week")
plt.ylabel("Touchdowns per game")

plt.show()


glm_bal_td_py = smf.glm(
    formula="touchdown_sum ~ week", data=bal_td_py, family=sm.families.Poisson()
).fit()

print(glm_bal_td_py.params)

print(np.exp(glm_bal_td_py.params))
