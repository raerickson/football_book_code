## logic operators
import numpy as np

score = np.array([21, 7, 0, 14])
team = np.array(["GB", "DEN", "KC", "NYJ"])

score > 7

score <= 14

team == "GB"

position = np.array(["QB", "DE", "OLB", "ED"])
np.isin(position, ["DE", "OLB", "ED"])

np.where((score >= 7) & (team == "DEN"))

np.where((score >= 7) & (team == "DEN") | (score == 0))

## Filtering and sorting data
import pandas as pd
import numpy as np
import nfl_data_py as nfl

pbp_py = nfl.import_pbp_data([2020])

gb_det_2020_py_pass = pbp_py.query("home_team == 'GB' & away_team == 'DET'")[
    ["posteam", "yards_after_catch", "air_yards", "pass_location", "qb_scramble"]
]

print(gb_det_2020_py_pass.query("yards_after_catch > 15"))

print(gb_det_2020_py_pass.query("yards_after_catch > 15 | air_yards > 20"))

print(
    gb_det_2020_py_pass.query(
        "(yards_after_catch > 15 | \
                                air_yards > 20) & \
                                posteam == 'DET'"
    )
)

## cleaning data
wrong_number = pd.DataFrame({"col1": ["a", "b"], "col2": ["1O", "12"], "col3": [2, 44]})

wrong_number.loc[wrong_number.col2 == "1O", "col2"] = 10
wrong_number.info()

wrong_number["col2"] = pd.to_numeric(wrong_number["col2"])
wrong_number.info()

## Checking for outliers
wrong_number.describe()

## Merging data
city_data = pd.DataFrame(
    {"city": ["DET", "GB", "HOU"], "team": ["Lions", "Packers", "Texans"]}
)
schedule = pd.DataFrame({"home": ["GB", "DET"], "away": ["DET", "HOU"]})

print(schedule.merge(city_data, how="outer", left_on="home", right_on="city"))

print(schedule.merge(city_data, how="inner", left_on="home", right_on="city"))

print(schedule.merge(city_data, how="right", left_on="home", right_on="city"))

print(schedule.merge(city_data, how="left", left_on="home", right_on="city"))

step_1 = schedule.merge(city_data, how="left", left_on="home", right_on="city")
step_2 = step_1.rename(columns={"team": "home_team"}).drop(columns="city")
step_3 = step_2.merge(city_data, how="left", left_on="away", right_on="city")
schedule_name = step_3.rename(columns={"team": "home_team"}).drop(columns="city")
print(schedule_name)
