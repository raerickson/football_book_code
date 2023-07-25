# Football Analytics with Python and R code

This repository contains code for the book _Football Analytics with Python and R_ by Eric Eager and Richard Erickson.
The repository contains two files for each chapter, a Python file that ends in `*.py` and an R file that ends in `*..
The Preface only includes R code because we use R to create the figures in this chapter and the code is not included in the book.
Likewise, Chapter 9 only includes R code because the example code was not used in the book.
The few lines of code from Appendix A are not included because this linear are trivial to write from the book.

**Note:** Line breaks differ in these files compared to the book because code was not limited by page width.

**Note:** Some figures were replotted to be higher resolution. These code files also include that code as additions.

**Tip:** Recreate the chapters using updated data. Our examples were written before the 2022 season, so anytime after the start of the season will have updated data for you to explore.

## Coding Note

We coded our examples with a focus on being easy to explain and use.
We did not optimize function or code.
Thus, as you learn more about programming in either R or Python, you will likely discover more efficient methods (but likely more difficult to understand for an novice) for the methods in these example files.

## Data Note

We include a folder containing data used for the book.
However, we were unable to include the data files due to GitHubs limits for free repository data files.
However, we also include our "cache" code in each chapter so that you avoid loading data to speed up code.
We strongly encourage you to use updated data from future (post-2022) season.

## To do:

- [X] check code in chapter 2 for hidden verses viz code
- [X] Add in all file names to files
- [x] run chapter 3 and save needed figures
- [x] relint chapter 3
- [x] relint chapter and 4
- [X] run chapter 4 and save needed figures
- [X] run chapter 5 and save needed figures
- [ ] re-run all chapters a final time to check
- [ ] Check code for Chapter 7 against book, especially R code.
- [ ] re-run chapter 4 to re-save python figure that was overwritten


## Directory Contents

This repository contains the following files:

- `./data/` is a folder to hold a cache copy of data pulled by the code.
- `README.md`: This file
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

## Disclaimer

The code provided in this repository is provided "as is" without any warranty or guarantees.
However, pull requests are welcome.