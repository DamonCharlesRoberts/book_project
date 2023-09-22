# Title: Merging MIT Election Lab Data to Yard Signs dataset

# Notes:
    #* Description: Script to merge MIT Election Lab US House 1976-2020 Election Returns dataset to Yard signs table
    #* Updated: 2022-11-28
    #* Updated by: dcr
    #* Other notes:
        #** To access dataset go to:
        #** https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/IG0UN2

# Load modules
    #* from env
#import duckdb # for database access
import polars as pl # for DataFrame management
import numpy as np # for array management
    #* User-defined
from chapter_2.src.PY.helper import names

# Check out the election lab data
election_lab = pl.read_csv(
    #* lazy load the csv file
    "./chapter_2/data/original/study_2/1976-2020-house.csv",
    null_values=""
    ).select([
    #* select the following columns
        "year",
        "state",
        "district",
        "candidate",
        "party",
        "candidatevotes",
        "totalvotes"
    ]).with_columns([
    #* convert state column to lowercase
        pl.col("state").str.to_lowercase().alias("state"),
    #* create candidate_Name column
        #pl.col("candidate").str.to_lowercase().alias("Candidate_Name")
    ]).with_columns(
        pl.concat_str(["state", "district"], separator = "-").alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "alaska-0")
        .then("alaska-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "vermont-0")
       .then("vermont-1")
       .otherwise(pl.col("state_district")).alias("state_district") 
    ).with_columns(
        pl.when(pl.col("state_district") == "montana-0")
        .then("montana-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "wyoming-0")
        .then("wyoming-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "south dakota-0")
        .then("south dakota-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).filter(
        pl.col("totalvotes") > 0
    ).with_columns(
        names(pl.col("candidate")).str.to_lowercase().alias("last_name")
    ).with_columns(
        pl.col("year").cast(pl.Utf8).str.strptime(pl.Date, format = "%Y").alias("year")
    )

mapped = election_lab.filter(
    pl.col("party") == "DEMOCRAT"
).groupby_dynamic(
    "year", every = '2y', period = "6y", by = "state_district"
).agg(
    pl.apply(exprs = ["candidatevotes", "totalvotes"], function = lambda x: x[0]/x[1]).cast(pl.Float64).alias("dem_vote_share")
).with_columns(
    pl.col("dem_vote_share").list.get(0).alias("dem_vote_share")
).sort(
    ["state_district", "year"]
)

election_lab_merge = election_lab.join(
    mapped,
    on = ["state_district", "year"],
    how = "left"
)

# Load database

df = pl.read_csv(
    source = "./chapter_2/data/temp/study_2/04_output.csv"
).with_columns(
        pl.col("state").str.to_lowercase().alias("state")
    ).with_columns(
        pl.concat_str(["state", "district"], separator = "-").alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "alaska-0")
        .then("alaska-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "vermont-0")
       .then("vermont-1")
       .otherwise(pl.col("state_district")).alias("state_district") 
    ).with_columns(
        pl.when(pl.col("state_district") == "montana-0")
        .then("montana-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "wyoming-0")
        .then("wyoming-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.when(pl.col("state_district") == "south dakota-0")
        .then("south dakota-1")
        .otherwise(pl.col("state_district")).alias("state_district")
    ).with_columns(
        pl.col("year").cast(pl.Utf8).str.strptime(pl.Date, format = "%Y").alias("year")
    ).with_columns(
        pl.col("last_name").str.to_lowercase().alias("last_name")
    )


yard_sign = df.join(
        election_lab_merge, 
        on = ["year", "state_district", "last_name"], 
        how = "inner"
    )

# Save stored dataset
yard_sign.write_csv(
    file = "./chapter_2/data/clean/study_2.csv"
)