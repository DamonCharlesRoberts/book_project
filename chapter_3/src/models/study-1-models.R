# Study 1 Models

# Notes
# *     Description
# **        Script that executes Study 1 models

# Set the seed
set.seed(12102022)
# Initialize list for the models
mod_h1 <- list()
mod_h2 <- list()
# Load libraries
box::use(
    duckdb[...],
    DBI[dbConnect, dbGetQuery],
    brms[...],
    marginaleffects[...]
)

# Connect to the DB
con <- dbConnect(duckdb(), dbdir = "./chapter_3/data/clean/study_1.db", read_only=TRUE)

# Load the data
df_h1 <- dbGetQuery(con, "SELECT CorrectColor, DislikeArgue, PoliticalPrime, EnjoyChallenge FROM Clean;")
df_dem <- dbGetQuery(con, "SELECT * FROM Clean WHERE CorrectColor=1 AND Dem3 == 1;")
df_rep <- dbGetQuery(con, "SELECT * FROM Clean WHERE CorrectColor=1 AND Dem3 == -1;")

# Models
# *     H1
mod_h1_main <- brm(
    CorrectColor ~ PoliticalPrime,
    data = df_h1,
    prior = set_prior("normal(0, 1)", class="b"),
)
mod_h1_conflict <- brm(
    CorrectColor ~ DislikeArgue,
    data = df_h1,
    prior = set_prior("normal(0, 1)", class="b"),
)
mod_h1_conflict_b <- brm(
    CorrectColor ~ EnjoyChallenge,
    data = df_h1,
    prior = set_prior("normal(0, 1)", class="b")
)
# *     H2
mod_h2_dem <- brm(
   ConversationAgree ~ PoliticalPrime + BlueShirt + PoliticalPrime * BlueShirt + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df_dem,
   prior = set_prior("normal(0, 1)", class="b"),
   family = cumulative(link="logit")
)
mod_h2_rep <- brm(
   ConversationAgree ~ PoliticalPrime + BlueShirt + PoliticalPrime * BlueShirt + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df_rep,
   prior = set_prior("normal(0, 1)", class="b"),
   family = cumulative(link="logit")
)
mod_h2_agree_dem <- brm(
   ViewsAgree ~ PoliticalPrime + BlueShirt + PoliticalPrime * BlueShirt + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df_dem,
   prior = set_prior("normal(0, 1)", class="b"),
   family = cumulative(link="logit")
)
mod_h2_agree_rep <- brm(
   ViewsAgree ~ PoliticalPrime + BlueShirt + PoliticalPrime * BlueShirt + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df_rep,
   prior = set_prior("normal(0, 1)", class="b"),
   family = cumulative(link="logit")
)
mod_h2_initiate_dem <- brm(
   InitiateAgree ~ PoliticalPrime + BlueShirt + PoliticalPrime * BlueShirt + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df_dem,
   prior = set_prior("normal(0, 1)", class="b"),
   family = cumulative(link="logit")
)
mod_h2_initiate_rep <- brm(
   InitiateAgree ~ PoliticalPrime + BlueShirt + PoliticalPrime * BlueShirt + White + Education + Attention + DislikeArgue + EnjoyChallenge,
   data = df_rep,
   prior = set_prior("normal(0, 1)", class="b"),
   family = cumulative(link="logit")
)
# Save model results
save(
    df_h1, df,
    mod_h1_main, mod_h1_conflict, mod_h1_conflict_b,
    mod_h2_dem, mod_h2_rep,
    mod_h2_agree_dem, mod_h2_agree_rep,
    mod_h2_initiate_dem, mod_h2_initiate_rep,
    file="./chapter_3/data/models/study-1-models.RData"
)
# Disconnect from the database
dbDisconnect(con, shutdown=TRUE)
