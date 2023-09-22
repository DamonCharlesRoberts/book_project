# Title: descriptive stats of pavlovia data

# Notes
    #* Description
        #** A R file that generates some descriptive statistics of the sample
    #* Updated
        #** 2023-06-16
        #** dcr

# Setup
    #* Set working directory
setwd("./src")
    #* execute cleaning script
source("./eda/study_1/cleaning.R")
        #** check to make sure it ran right
ls()
str(list_df)
    #* load handy functions
box::use(
    data.table[...]
    , modelsummary[
        datasummary_skim
    ]
)

# Select columns to summarize
    #* Demographics
df_demographics_subset <- list_df[["cleaned"]][
    , c("age", "color_blind_dummy", "gender_id", "white", "hispanic", "black")
]
datasummary_skim(df_demographics_subset)
    #* Politics
df_politics_subset <- list_df[["cleaned"]][
    , c("pid_7", "attention")
]
datasummary_skim(df_politics_subset)
    #* Treatments
df_treatments_subset <- list_df[["cleaned"]][
    , c(
        "trial_1_red_stimuli"
        , "trial_2_red_stimuli"
        , "trial_3_red_stimuli"
        , "vote"
        , "trial_1_party"
        , "trial_2_party"
        , "trial_3_party")
]
datasummary_skim(df_treatments_subset)