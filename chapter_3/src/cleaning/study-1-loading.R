# Loading data file

# Notes
# *     Description
# **        Script that loads and stores the data into a DB

# Load libraries
box::use(
    haven[read_sav],
    duckdb[...],
    DBI[dbConnect,dbExecute]
)

# Connect to the DB
con <- dbConnect(duckdb(), dbdir = "./chapter_3/data/clean/study_1.db")

# Load the file
df <- read_sav(
    "./chapter_3/data/original/CCES23_CUB_OUTPUT.sav"
)
df_common <- read_sav(
    "./chapter_3/data/original/CCES23_COMMON_OUTPUT.sav"
)

# Store the data in the DB
dbWriteTable(con, "OriginalModule", df)
dbWriteTable(con, "OriginalCommon", df_common)

# Disconnect from the database
dbDisconnect(con, shutdown=TRUE)