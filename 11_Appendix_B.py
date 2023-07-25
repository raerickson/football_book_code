## load packages
import pandas as pd
import numpy as np
import nfl_data_py as nfl

# Load all data
pbp_py = nfl.import_pbp_data([2020])

# filter out game data
gb_det_2020_py = pbp_py.query("home_team == 'GB' & away_team == 'DET'")

gb_det_2020_pass_py = gb_det_2020_py[
    ["posteam", "yards_after_catch", "air_yards", "pass_location", "qb_scramble"]
]

# describe
print(gb_det_2020_pass_py.describe())

# aggregate
print(
    gb_det_2020_pass_py.agg(
        {"air_yards": ["min", "max", "mean", "median", "std", "var", "count"]}
    )
)

print(
    gb_det_2020_pass_py.groupby("posteam").agg(
        {"air_yards": ["min", "max", "mean", "median", "std", "var", "count"]}
    )
)

## group_by
print(
    gb_det_2020_pass_py.groupby("posteam").agg(
        {
            "yards_after_catch": [
                "min",
                "max",
                "mean",
                "median",
                "std",
                "var",
                "count",
            ],
            "air_yards": ["min", "max", "mean", "median", "std", "var", "count"],
        }
    )
)
