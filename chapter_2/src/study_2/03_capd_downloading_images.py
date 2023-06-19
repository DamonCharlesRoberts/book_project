# Title: CAPD Image Downloading

# Notes:
    #* Description: Script to open links to images and downloading them from CAPD site
    #* Updated: 2022-11-28
    #* Updated by: dcr
    #* Other notes:
        #** Should execute at end of 02_capd_img_scraping.py


# Importing modules 
    #* From environment
import duckdb # for database management
import polars as pl # for dataFrame management
import urllib.request # to access site
import sys # to deal with paths

    #* User-defined
sys.path.append("code/") # set path for imported modules
from fun import names

# Loading database

db = duckdb.connect("data/dissertation_database")

links_df = pl.from_arrow(
    db.execute("SELECT * FROM ch_1_capd_yard_signs").fetch_arrow_table()
).with_column(
    names(pl.col("Candidate_Name")).alias("Last_Name")
).to_pandas()

# Downloading the images

for index, row in links_df.iterrows():
    urllib.request.urlretrieve(row["Img_URL"], "data/chapter_1/capd_yard_signs/" + row["Last_Name"] + "_" + str(row["Year"]) + ".png")