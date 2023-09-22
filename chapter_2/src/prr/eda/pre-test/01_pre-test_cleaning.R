# Title: Chapter 2 pre-test cleaning script

# Notes:
    #* Description:
        #** Cleaning script for chapter 2 pre-test.
    #* Updated:
        #** 2023-03-15
        #** by: dcr
# Setup
    #* set working directory
#setwd("./chapter_2/code/prr")
    #* Modularly load functions
box::use(
    haven[read_dta],
    data.table[...]
)
    #* Create empty list object
data <- list()
    #* Import dataset
data[["original"]] <- setDT(read_dta("../../data/prr/pre-test/sps1.dta"))

# Cleaning
data[["clean"]] <- data[["original"]][
  #* Female - binary gender id of respondent
    #** gender coded as: 1 = male, 2 = female
    #** Recode to: 0 = male, 1 = female
  , Female := fifelse(
      gender == 1, 0, 1, na = NA
    )
][
    , FemaleCat := factor(
        Female,
        labels = c(
            "Male",
            "Female"
        ),
        ordered = TRUE
    )
][
  #* white - race of respondent
    #** race: 1 = Asian, 2 = African-American/Black, 3 = Hispanic/Latino, 4 = Native American, 5 = White, 6 = Other
    #** Recode to: 0 = non-White, 1 = White
  , White := fifelse(
      race == 5, 1, 0
    )
][
    , WhiteCat := factor(
        White,
        labels = c(
            "Non-White",
            "White"
        ),
        ordered = TRUE
    )
][
    #* pid - partisan identification
      #** combination of multiple questions
      #** pid: -3 = strong democrat, -2 = democrat, -1 = leans democratic, 0 = independent, 1 = leans republican, 2 = republican, 3 = strong republican
  , PartyId := fcase(
      pid == 2 & dem1 == 1, -3,
      pid == 2 & dem1 == 2, -2,
      pid == 3 & ind1 == 2, -1,
      pid == 3 & ind1 == 3, 0,
      pid == 3 & ind1 == 1, 1,
      pid == 1 & rep1 == 2, 2,
      pid == 1 & rep1 == 1, 3,
      default = NA
    )
][
    , PartyIdCat := factor(
        PartyId,
        labels = c(
            "Strong Democrat",
            "Democrat",
            "Leans Democratic",
            "Independent",
            "Leans Republican",
            "Republican",
            "Strong Republican"
        ),
        ordered = TRUE
    )
][
    #* blue_treatment - did they receive the blue yard sign treatment
      #** q265: 0 = did not display treatment, 1 = did display treatment
      #** recoded to: 0 = did not display treatment, 1 = did display treatment
  , BlueTreatment := fifelse(
      q265 == 1, 1, 0, na = 0
    )
][
    , BlueTreatmentCat := factor(
        BlueTreatment,
        labels = c(
            "Did not receive",
            "Received"
        ),
        ordered = TRUE
    )
][
    #* red_treatment - did they receive the red yard sign treatment?
      #** q421: 0 = did not display treatment, 1 = did display treatment
      #** recoded to: 0 = did not display treatment, 1 = did display treatment
  , RedTreatment := fifelse(
      q421 == 1, 1, 0, na = 0
    )
][
    , RedTreatmentCat := factor(
        RedTreatment,
        labels = c(
            "Did not receive",
            "Received"
        ),
        ordered = TRUE
    )
][
    #* white_treatment - did they receive the white yard sign treatment?
      #** q423: 0 = did not display treatment, 1 = did display treatment
      #** recoded to: 0 = did not display treatment, 1 = did display treatment
  , WhiteTreatment := fifelse(
      q423 == 1, 1, 0, na = 0
    )
][
    , WhiteTreatmentCat := factor(
        WhiteTreatment,
        labels = c(
            "Did not receive",
            "Received"
        ),
        ordered = TRUE
    )
][
    #* t_party - party of fictional candidate
      #** dr_pid: 1 = republican, 2 = democrat, 3 = neither
      #** recoded to: -1 = democrat, 0 = neither, 1 = republican
  , Party := fcase(
      dr_pid == 2, 1,
      dr_pid == 3, 2,
      dr_pid == 1, 3
    )
][
    , PartyCat := factor(
        Party,
        labels = c(
            "Democrat",
            "Independent",
            "Republican"
        ),
        ordered = TRUE
    )
][
    #* t_vote - vote for fictional candidate
        #** dr_info_4: 2 = do not vote for the candidate, 1 = vote for candidate & dr_info_5: 2 = do not avoid candidate, 1 = avoid candidate
        #** t_vote: -1 = avoid candidate, 0 = avoid & vote/do not avoid & do not vote, 1 = vote
  , Vote := fcase(
      dr_info_4 == 2 & dr_info_5 == 1, 1,
      dr_info_4 == 1 & dr_info_5 == 1, 2,
      dr_info_4 == 2 & dr_info_5 == 2, 2,
      dr_info_4 == 1 & dr_info_5 == 2, 3
    )
][
    , VoteCat := factor(
        Vote,
        labels = c(
            "Avoid",
            "Ambivalent",
            "Will vote for"
        ),
        ordered = TRUE)
]