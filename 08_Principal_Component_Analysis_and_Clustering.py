## load packages
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib
import numpy as np
import os
from sklearn.impute import KNNImputer
from sklearn.decomposition import PCA
from scipy.cluster.vq import vq, kmeans

## download, format, and save data
chap_8_combine_py_file = "./data/chap_8_combine_py_file.csv"
if os.path.isfile(chap_8_combine_py_file):
    combine_py = pd.read_csv(chap_8_combine_py_file)
else:
    combine_py = pd.DataFrame()
    for i in range(2000, 2023 + 1):
        url = "https://www.pro-football-reference.com/draft/" + str(i) + "-combine.htm"
        web_data = pd.read_html(url)[0]
        web_data["Season"] = i
        web_data = web_data.query('Ht != "Ht"')
        combine_py = pd.concat([combine_py, web_data])
    combine_py.reset_index(drop=True, inplace=True)

combine_py[["Ht-ft", "Ht-in"]] = combine_py["Ht"].str.split("-", expand=True)

combine_py = combine_py.astype(
    {
        "Wt": float,
        "40yd": float,
        "Vertical": float,
        "Bench": float,
        "Broad Jump": float,
        "3Cone": float,
        "Shuttle": float,
        "Ht-ft": float,
        "Ht-in": float,
    }
)
combine_py["Ht"] = combine_py["Ht-ft"] * 12.0 + combine_py["Ht-in"]
combine_py.drop(["Ht-ft", "Ht-in"], axis=1, inplace=True)

combine_py.to_csv("combine_data_py.csv", index=False)
combine_py.describe()

## several plots to look at combine data
sns.set_theme(style="whitegrid", palette="colorblind")

sns.regplot(data=combine_py, x="Ht", y="Wt")
plt.show()

sns.regplot(data=combine_py, x="Wt", y="40yd", line_kws={"color": "red"})
plt.show()

sns.regplot(data=combine_py, x="40yd", y="Vertical", line_kws={"color": "red"})
plt.show()

sns.regplot(data=combine_py, x="40yd", y="3Cone", line_kws={"color": "red"})
plt.show()

## impute missing data

combine_knn_py_file = "combine_knn_py.csv"
col_impute = ["Ht", "Wt", "40yd", "Vertical", "Bench", "Broad Jump", "3Cone", "Shuttle"]

if not os.path.isfile(combine_knn_py_file):
    combine_knn_py = combine_py.drop(col_impute, axis=1)
    imputer = KNNImputer(n_neighbors=10)
    knn_out_py = imputer.fit_transform(combine_py[col_impute])
    knn_out_py = pd.DataFrame(knn_out_py)
    knn_out_py.columns = col_impute
    combine_knn_py = pd.concat([combine_knn_py, knn_out_py], axis=1)
    combine_knn_py.to_csv(combine_knn_py_file)
else:
    combine_knn_py = pd.read_csv(combine_knn_py_file)

## PCA
pca_wt_ht = PCA(svd_solver="full")
wt_ht_py = combine_py[["Wt", "Ht"]].query("Wt.notnull() & Ht.notnull()").copy()
pca_fit_wt_ht_py = pca_wt_ht.fit_transform(wt_ht_py)

print(pca_wt_ht.explained_variance_ratio_)

plt.plot(pca_fit_wt_ht_py[:, 0], pca_fit_wt_ht_py[:, 1], "o")
plt.show()

pca_wt_ht.components_

scaled_combine_knn_py = (
    combine_knn_py[col_impute] - combine_knn_py[col_impute].mean()
) / combine_knn_py[col_impute].std()

### PCA on all data
pca = PCA(svd_solver="full")
pca_fit_py = pca.fit_transform(scaled_combine_knn_py)

rotation = pd.DataFrame(pca.components_, index=col_impute)
print(rotation)

print(pca.explained_variance_)

pca_percent_py = pca.explained_variance_ratio_.round(4) * 100
print(pca_percent_py)

pca_fit_py = pd.DataFrame(pca_fit_py)
pca_fit_py.columns = ["PC" + str(x + 1) for x in range(len(pca_fit_py.columns))]
combine_knn_py = pd.concat([combine_knn_py, pca_fit_py], axis=1)

sns.scatterplot(data=combine_knn_py, x="PC1", y="PC2")
plt.show()

sns.scatterplot(data=combine_knn_py, x="PC1", y="PC2", hue="PC3")
plt.show()


sns.scatterplot(data=combine_knn_py, x="PC1", y="PC2", hue="Pos")
plt.show()

## combine clustering data
k_means_fit_py = kmeans(combine_knn_py[["PC1", "PC2"]], 6, seed=1234)

combine_knn_py["cluster"] = vq(combine_knn_py[["PC1", "PC2"]], k_means_fit_py[0])[0]

print(
    combine_knn_py.query("cluster == 1")
    .groupby("Pos")
    .agg({"Ht": ["count", "mean"], "Wt": ["count", "mean"]})
)

combine_knn_py_cluster = combine_knn_py.groupby(["cluster", "Pos"]).agg(
    {"Ht": ["count", "mean"], "Wt": ["mean"]}
)

combine_knn_py_cluster.columns = list(map("_".join, combine_knn_py_cluster.columns))

combine_knn_py_cluster.reset_index(inplace=True)

combine_knn_py_cluster.rename(
    columns={"Ht_count": "n", "Ht_mean": "Ht", "Wt_mean": "Wt"}, inplace=True
)

combine_knn_py_cluster.cluster = combine_knn_py_cluster.cluster.astype(str)

sns.catplot(
    combine_knn_py_cluster, x="n", y="Pos", col="cluster", col_wrap=3, kind="bar"
)
plt.show()

## update figure for book
plt.figure(figsize=(6, 4.25), dpi=600)
sns.set(font_scale=1.5)
sns.catplot(
    combine_knn_py_cluster,
    x="n",
    y="Pos",
    col="cluster",
    col_wrap=3,
    kind="bar",
)
plt.savefig("fig_8_18.png", dpi=600)

combine_knn_py_cluster.groupby("cluster").agg({"Ht": ["mean"], "Wt": ["mean"]})
