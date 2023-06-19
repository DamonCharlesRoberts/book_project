# Title: test clean_data function

# Notes:
    #* Description
        #** testing of the clean_data funciton
    #* Updated
        #** 2023-06-12
        #** dcr

# Setup
    #* set working directory
#setwd("../src/")
setwd("./src/")
    #* load relevat packages
box::use(
    ./R/clean_data[...]
    , data.table[...]
)
    #* examples
        #** load single file
df_temp <- read.csv(
    file = "/Users/dcr/Library/CloudStorage/Dropbox/current_projects/dissertation/chapter_2/data/original/study_1/data/diss_ch_1_pre-reg_PARTICIPANT_SESSION_2023-06-12_10h09.02.63.csv"
)

df_test <- extract_file(df_temp)

      #** Full test
df_test <- clean_data(
    folder = "../data/original/study_1/data"
    , prolific_data = "../data/clean/prolific_demographic_data.csv"
)