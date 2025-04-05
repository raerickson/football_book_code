# Football Analytics with Python and R code

This repository contains code for the book _Football Analytics with Python and R_ by Eric Eager and Richard Erickson.
The repository contains two files for each chapter, a Python file that ends in `*.py` and an R file that ends in `*.R`.
The Preface only includes R code because we used R to create the figures in this chapter and the code is not included in the book.
Likewise, Chapter 9 only includes R code because the example code was not used in the book.
The few lines of code from Appendix A are not included because these code are linear and trivial to write from the book.

**Note:** Line breaks differ in these files compared to the book because code was not limited by page width.

**Note:** Some figures were replotted to be higher resolution. These code files also include that code as additions.

**Tip:** Recreate the chapters using updated data. Our examples were written before the 2022 season, so anytime after the start of the season will have updated data for you to explore.

## Python files
To download the required libraries for the Python examples, execute the following command:

```
$ pip install -r requirements.txt
```

A brief introdution to Python environments is supplied in the `PYTHON.md` file.

## Coding Note

We coded our examples with a focus on being easy to explain and use.
We did not optimize function or code.
Thus, as you learn more about programming in either R or Python, you will likely discover more efficient methods (but likely more difficult to understand for an novice) for the methods in these example files.

## Data Note

The code will cache (that is, save code locally for use later) to avoid multiple downloads.
We include a folder to storte this data in the data.
However, we were unable to include the data files due to GitHubs limits for free repository data files.
That being said, we strongly encourage you to use updated data from future (post-2022) season.

## Repo Contents

This repository contains the following files:

- `./data/` is a folder to hold a cache copy of data pulled by the code.
- `README.md`: This file
- 'requirements.txt': Requirements file containing requirement python libraries for installation with pip.
- `00_preface.R`: R code of the preface [R only]
- `01_Football_analytics.py`: Python code for Chapter 1
- `01_Football_analytics.R`: R code for Chapter 1
- `02_Exploratory_Data_Analysis.py`: Python code for Chapter 2
- `02_Exploratory_Data_Analysis.R`: R code for Chapter 2
- `03_Simple_Linear_Regression.py`: Python code for Chapter 3
- `03_Simple_Linear_Regression.R`: R code for Chapter 3
- `04_Multiple_Regression.py`: Python code for Chapter 4
- `04_Multiple_Regression.R`: R code for Chapter 4
- `05_Generalized_Linear_Models.py`: Python code for Chapter 5
- `05_Generalized_Linear_Models.R`: R code for Chapter 5
- `06_Using_Data_Science_for_Sports_Betting.py`: Python code for Chapter 6
- `06_Using_Data_Science_for_Sports_Betting.R`: R code for Chapter 6
- `07_Web_Scraping.py`: Python code for Chapter 7
- `07_Web_Scraping.R`: Python code for Chapter 7
- `08_Principal_Component_Analysis_and_Clustering.py`: Python code for Chapter 8
- `08_Principal_Component_Analysis_and_Clustering.R`: R code for Chapter 8
- `09_Advanced_Tools_and_Next_steps.R`: R code for Bayesian example [R only]
- `11_Appendix_B.py`: Python code from Appendix B
- `11_Appendix_B.R`: R code from Appendix B
- `12_Appendix_C.py`: Python code for Appendix C
- `12_Appendix_C.R`: R code for Appendix C
- `PYTHON.md` a reader submitted and brief tutorial on Python environments
 
## Disclaimer

The code provided in this repository is provided "as is" without any warranty or guarantees.
However, pull requests are welcome.
