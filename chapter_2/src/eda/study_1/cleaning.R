# Title: cleaning script for pavlovia data

# Notes
  #* Description
    #**This is a cleaning script for the pavlovia data.
    #** It takes the csv files, extracts some data from them,
    #** merges in the prolific demographic data, then removes
    #** duplicated rows based on session_id, then converts
    #** columns to correct data types.
  #* Updated:
    #** 2023-08-07
    #** dcr

# Setup
  #* Load useful functions
box::use(
  data.table[...]
  , ./R/clean_data[clean_data]
)
# Cleaning
  #* Do basic cleaning to return a minimally usable data.frame
list_df <- list() # create an empty list for my data_frames
list_df[["original"]] <- clean_data(
  folder = "../data/original/study_1/data"
  , prolific_data = "../data/clean/prolific_demographic_data.csv"
)
  #* Create measures
list_df[["cleaned"]] <- list_df[["original"]][
    #** Generate 7-item pid measure
    #** Coded as -3 = Strong Democrat, 3 = Strong republican
  , pid_7 := fcase(
    pid_3 == "Democrat" & pid_d_str == "Strong", -3
    , pid_3 == "Democrat" & pid_d_str == "Not very strong", -2
    , pid_3 == "Democrat" & is.na(pid_d_str), -1
    , pid_3 == "Independent" & ind_lean == "Closer to Democratic", -1
    , pid_3 == "Other" & ind_lean == "Closer to Democratic", -1
    , pid_3 == "Independent" | pid_3 == "Other" & ind_lean == "Neither", 0
    , pid_3 == "Other" & ind_lean == "Closer to Republican party", 1
    , pid_3 == "Independent" & ind_lean == "Closer to Republican party", 1
    , pid_3 == "Republican" & is.na(pid_r_str), 1
    , pid_3 == "Republican" & pid_r_str == "Not very strong", 2
    , pid_3 == "Republican" & pid_r_str == "Strong", 3
  )
]
#* Recoding/adding factors
list_df[["cleaned"]] <- list_df[["cleaned"]][
  #** convert age to numeric
  , age := as.numeric(age)
][
  #** convert attention to numeric
  , attention := fcase(
    attention == "Never", 0
    , attention == "Some of the time", 1
    , attention == "About half the time", 2
    , attention == "Most of the time", 3
    , attention == "Always", 4
  )
][
  #** convert color blindness to dummy variable
  , color_blind_dummy := fcase(
    color_blind == "[Color blindness (any form)]", 1
    , color_blind != "[Color blindness (any form)]", 0
  )
][
  #** convert gender_id to factor variable
  , gender_id := factor(gender_id)
][
  #** convert sex to dummy variable
  , female_sex := fcase(
      sex != "Female", 0
      , sex == "Female", 1
  )
][
  #** convert race_id to factor variable
  , race_id := factor(race_id)
][
  #** make a white dummy variable
  , white := fcase(
    race_id != "White, non-hispanic", 0
    , race_id == "White, non-hispanic", 1
  )
][
  #** make a latino/hispanic dummy variable
  , hispanic := fcase(
    race_id != "Hispanic", 0
    , race_id == "Hispanic", 1
  )
][
  #** make a Black dummy variable
  , black := fcase(
    race_id != "Black, non-hispanic", 0
    , race_id == "Black, non-hispanic", 1
  )
][
  #** convert trial 1 party guess to numeric
  , trial_1_party := fcase(
    trial_1_party == "Democrat", 1
    , trial_1_party == "Neither", 2
    , trial_1_party == "Republican", 3
  )
][
  , trial_2_party := fcase(
    trial_2_party == "Democrat", 1
    , trial_2_party == "Neither", 2
    , trial_2_party == "Republican", 3
  )
][
  , trial_3_party := fcase(
    trial_3_party == "Democrat", 1
    , trial_3_party == "Neither", 2
    , trial_3_party == "Republican", 3
  )
][
  #** convert vote intention to numeric
  , vote := fcase(
    vote == "The <strong>first </strong>yard sign", 1
    , vote == "The <strong>second</strong> yard sign", 2
    , vote == "The <strong>third </strong>yard sign", 3
  )
][
  #** make dummy for trial 1 vote intention
  , trial_1_vote := fcase(
    vote == 1, 1
    , vote != 1, 0
  )
][
  #** convert stimuli into dummies
  , trial_1_red_stimuli := fcase(
    trial_1_stimulus == "White", 0
    , trial_1_stimulus == "Red", 1
  )
][
  , trial_1_blue_stimuli := fcase(
    trial_1_stimulus == "White", 0
    , trial_1_stimulus == "Blue", 1
  )
][
  , trial_2_red_stimuli := fcase(
    trial_2_stimulus == "White", 0
    , trial_2_stimulus == "Red", 1
  )
][
  , trial_2_blue_stimuli := fcase(
    trial_2_stimulus == "White", 0
    , trial_2_stimulus == "Blue", 1
  )
][
  , trial_3_red_stimuli := fcase(
    trial_3_stimulus == "White", 0
    , trial_3_stimulus == "Red", 1
  )
][
  , trial_3_blue_stimuli := fcase(
    trial_3_stimulus == "White", 0
    , trial_3_stimulus == "Blue", 1
  )
][
  , trial_1_red_stimuli_alt := fcase(
    trial_1_stimulus != "Red", 0
    , trial_1_stimulus == "Red", 1
  )
][
  , trial_1_blue_stimuli_alt := fcase(
    trial_1_stimulus != "Blue", 0
    , trial_1_stimulus == "Blue", 1
  )
][
  , trial_2_red_stimuli_alt := fcase(
    trial_2_stimulus != "Red", 0
    , trial_2_stimulus == "Red", 1
  )
][
  , trial_2_blue_stimuli_alt := fcase(
    trial_2_stimulus != "Blue", 0
    , trial_2_stimulus == "Blue", 1
  )
][
  , trial_3_red_stimuli_alt := fcase(
    trial_3_stimulus != "Red", 0
    , trial_3_stimulus == "Red", 1
  )
][
  , trial_3_blue_stimuli_alt := fcase(
    trial_3_stimulus != "Blue", 0
    , trial_3_stimulus == "Blue", 1
  )
][
  #* Turn trial_#_party outcome into factor
  , trial_1_party := factor(trial_1_party, ordered = TRUE)
][
  , trial_2_party := factor(trial_2_party, ordered = TRUE)
][
  , trial_3_party := factor(trial_3_party, ordered = TRUE)
][
  # Turn trial_1_vote outcome into factor
  , trial_1_vote := factor(trial_1_vote, ordered = TRUE)
]

# Store the cleaned data in a csv temp file
write.csv(
  list_df[["cleaned"]]
  , file = "../data/clean/cleaned_pavlovia.csv"
)