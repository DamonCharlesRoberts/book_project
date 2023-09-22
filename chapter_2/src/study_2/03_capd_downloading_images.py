# Title: CAPD Image Downloading

# Notes:
    #* Description: Script to open links to images and downloading them from CAPD site
    #* Updated: 2022-11-28
    #* Updated by: dcr
    #* Other notes:
        #** Should execute at end of 02_capd_img_scraping.py


# Importing modules 
    #* From environment
#import duckdb # for database management
import polars as pl # for dataFrame management
import urllib.request # to access site
import sys # to deal with paths

    #* User-defined
from chapter_2.src.PY.helper import names

# Loading database

df = pl.read_csv(
    source = "./chapter_2/data/temp/study_2/02_output.csv"
)

links_df = df.with_columns(
    names(pl.col("candidate_name")).alias("last_name")
).to_pandas()

# Downloading the images

for index, row in links_df.iterrows():
    urllib.request.urlretrieve(row["Img_URL"], "./chapter_2/data/original/study_2/capd_yard_signs/" + row["last_name"] + "_" + str(row["year"]) + ".png")