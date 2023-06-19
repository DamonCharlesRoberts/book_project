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
import duckdb # for database access
import polars as pl # for DataFrame management
import numpy as np # for array management
    #* User-defined
from PY.helper import names

# Check out the election lab data
election_lab = pl.read_csv(
    #* lazy load the csv file
    "data/chapter_1/1976-2020-house.csv",
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
    ]).with_column(
        pl.concat_str(["state", "district"], sep = "-").alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "alaska-0")
        .then("alaska-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "vermont-0")
       .then("vermont-1")
       .otherwise(pl.col("State_District")).alias("State_District") 
    ).with_column(
        pl.when(pl.col("State_District") == "montana-0")
        .then("montana-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "wyoming-0")
        .then("wyoming-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "south dakota-0")
        .then("south dakota-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).filter(
        pl.col("totalvotes") > 0
    ).with_column(
        names(pl.col("candidate")).str.to_lowercase().alias("Last_Name")
    ).with_column(
        pl.col("year").cast(pl.Utf8).str.strptime(pl.Date, fmt = "%Y").alias("Year")
    ).drop(
        "year"
    )

mapped = election_lab.filter(
    pl.col("party") == "DEMOCRAT"
).groupby_dynamic(
    "Year", every = '2y', period = "6y", by = "State_District"
).agg(
    pl.apply(exprs = ["candidatevotes", "totalvotes"], f = lambda x: x[0]/x[1]).cast(pl.Float64).alias("Dem_Vote_Share")
).with_column(
    pl.col("Dem_Vote_Share").arr.get(0).alias("Dem_Vote_Share")
).sort(
    ["State_District", "Year"]
)

election_lab_merge = election_lab.join(
    mapped,
    on = ["State_District", "Year"],
    how = "left"
)

# Load database

db = duckdb.connect("data/dissertation_database") # connect to my database

yard_sign = pl.from_arrow(db.execute(
    '''SELECT * FROM ch_1_capd_color_detected'''
    ).fetch_arrow_table(
    #* grab the ch_1_capd_yard_signs table from the database and store it as a pandas dataframe 
    )
    #* store it as polars.DataFrame
    ).with_column(
        pl.col("State").str.to_lowercase().alias("State")
    ).with_column(
        pl.concat_str(["State", "District"], sep = "-").alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "alaska-0")
        .then("alaska-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "vermont-0")
       .then("vermont-1")
       .otherwise(pl.col("State_District")).alias("State_District") 
    ).with_column(
        pl.when(pl.col("State_District") == "montana-0")
        .then("montana-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "wyoming-0")
        .then("wyoming-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.when(pl.col("State_District") == "south dakota-0")
        .then("south dakota-1")
        .otherwise(pl.col("State_District")).alias("State_District")
    ).with_column(
        pl.col("Year").cast(pl.Utf8).str.strptime(pl.Date, fmt = "%Y").alias("Year")
    ).with_column(
        pl.col("Last_Name").str.decode(pl.Utf8).str.to_lowercase().alias("Last_Name")
    ).join(
        election_lab_merge, 
        on = ["Year", "State_District", "Last_Name"], 
        how = "left"
    ).to_arrow()

# Add merged table to database

db.execute("CREATE OR REPLACE TABLE capd_mit_merged AS SELECT * FROM yard_sign") # store merged df in database as capd_mit_merged table

print('SCRIPT COMPLETE')