# Study 1 Models

# Notes
# *     Description
# **        Script that executes Study 1 models

# Load libraries
box::use(
    duckdb[...],
    DBI[dbConnect, dbGetQuery],
    brms[...]
)

# Connect to the DB
con <- dbConnect(duckdb(), dbdir = "./chapter_3/data/clean/study_1.db", read_only=TRUE)

# Load the table
df <- dbGetQuery(con, "SELECT * FROM Clean WHERE CorrectColor=1 AND PoliticalPrime == 1;")

# Models
# *     H2
mod <- brm(
   ConversationAgree ~ BlueShirt + Dem3 + BlueShirt * Dem3 + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df,
   prior = set_prior("normal(0, 1)", class="b"),
)
# Disconnect from the database
dbDisconnect(con, shutdown=TRUE)
