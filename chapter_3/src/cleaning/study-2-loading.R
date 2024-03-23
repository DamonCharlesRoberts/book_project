# Loading data files

# Notes
# *     Description
# **        Script that loads and stores the data into a db.

# Load libraries
box::use(
    duckdb[...],
    DBI[dbConnect, dbExecute]
)

# Connect to the DB
con <- dbConnect(duckdb(), dbdir = "./chapter_3/data/clean/study-2.db")

# Load the prolific demographics file
df_demo <- read.csv(
    "./chapter_3/data/original/prolific-demo-data.csv"
)

# Load the Qualtrics data
df <- read.csv(
    "./chapter_3/data/original/study-2.csv", header=TRUE
)
df <- df[-c(1:6), ]

# Store the data in the DB
dbWriteTable(con, "Qualtrics", df, overwrite=TRUE)
dbWriteTable(con, "Prolific", df_demo, overwrite=TRUE)

# Disconnect from the database
dbDisconnect(con, shutdown=TRUE)