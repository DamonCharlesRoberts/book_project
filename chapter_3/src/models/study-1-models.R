# Study 1 Models

# Notes
# *     Description
# **        Script that executes Study 1 models

# Initialize list for the models
mod_h1 <- list()
mod_h2 <- list()
# Load libraries
box::use(
    duckdb[...],
    DBI[dbConnect, dbGetQuery],
    brms[...]
)

# Connect to the DB
con <- dbConnect(duckdb(), dbdir = "./chapter_3/data/clean/study_1.db", read_only=TRUE)

# Load the table
df_h1 <- dbGetQuery(con, "SELECT CorrectColor, DislikeArgue, PoliticalPrime FROM Clean;")
df <- dbGetQuery(con, "SELECT * FROM Clean WHERE CorrectColor=1 AND PoliticalPrime == 1;")

# Models
# *     H1
mod_h1["main"] <- brm(
    CorrectColor ~ PoliticalPrime,
    data = df_h1,
    prior = set_prior("normal(0, 1)", class="b"),
)
mod_h1["conflict"] <- brm(
    CorrectColor ~ DislikeArgue,
    data = df_h1,
    prior = set_prior("normal(0, 1)", class="b"),
)
# *     H2
mod_h2["main"] <- brm(
   ConversationAgree ~ BlueShirt + Dem3 + BlueShirt * Dem3 + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df,
   prior = set_prior("normal(0, 1)", class="b"),
)

# Save model results
save(
    mod_h1, mod_h2,
    file="./chapter_3/data/models/study-1-models.RData"
)
# Disconnect from the database
dbDisconnect(con, shutdown=TRUE)
