# Title: Preliminary analyses of pavlovia data

# Notes
    #* Description
        #** This is a R file that performs some preliminary analyses of
        #** the pavlovia data for study 1
    #* Updated
        #** 2023-06-16
        #** dcr

# Setup
  #* set seed
set.seed(12102022)
  #* set working directory
setwd("./chapter_2/src")
  #* execute cleaning script
source("./eda/study_1/cleaning.R")
  #* load in cleaned study-2 data 
  #* (need to run each python script individually)
df_study_2 <- read.csv("../data/clean/study_2.csv") |>
  as.data.table()
  #* convert state_district and year variables  to factors
df_study_2 <- df_study_2[
  , year := tstrsplit(year, "-", keep = 1)
][
  , year := as.numeric(year)
][
  , state_district := factor(state_district)
][
  , blue_prop := blue_percent/100
][
  , red_prop := red_percent/100
]
  #* load helpful functions
box::use(
  data.table[...]
  , brms[...]
  , ordbetareg[...]
)
    #* make an empty model list object
list_fitted <- list(
  h_1 = list()
  , h_2 = list()
  , h_2a = list()
  , h_3 = list()
  , h_4 = list()
  , h_5 = list()
)
list_ppc <- list(
  h_1 = list()
  , h_2 = list()
  , h_2a = list()
  , h_3 = list()
  , h_4 = list()
  , h_5 = list()
)

# Hypothesis 1

# Hypothesis 2
    #* Fit models
list_fitted[["h_2"]][["red"]] <- brm(
  formula = trial_1_party ~ trial_1_red_stimuli
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2"]][["blue"]] <- brm(
  formula = trial_1_party ~ trial_1_blue_stimuli
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2"]][["single_model"]] <- brm(
  formula = trial_1_party ~ trial_1_red_stimuli_alt + trial_1_blue_stimuli_alt
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2"]][["red_interact"]] <- brm(
  formula = trial_1_party ~ trial_1_red_stimuli + age + trial_1_red_stimuli * age
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2"]][["blue_interact"]] <- brm(
  formula = trial_1_party ~ trial_1_blue_stimuli + age + trial_1_blue_stimuli * age
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0 , 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2"]][["red_colorblind"]] <- brm(
  formula = trial_1_party ~ trial_1_red_stimuli + color_blind_dummy + trial_1_red_stimuli * color_blind_dummy
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2"]][["blue_colorblind"]] <- brm(
  formula = trial_1_party ~ trial_1_blue_stimuli + color_blind_dummy + trial_1_blue_stimuli * color_blind_dummy
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
    #* Posterior predictive checks
list_ppc[["h_2"]][["red"]] <- pp_check(
  list_fitted[["h_2"]][["red"]]
)
list_ppc[["h_2"]][["blue"]] <- pp_check(
  list_fitted[["h_2"]][["blue"]]
)
list_ppc[["h_2"]][["single_model"]] <- pp_check(
  list_fitted[["h_2"]][["single_model"]]
)
list_ppc[["h_2"]][["red_interact"]] <- pp_check(
  list_fitted[["h_2"]][["red_interact"]]
)
list_ppc[["h_2"]][["blue_interact"]] <- pp_check(
  list_fitted[["h_2"]][["blue_interact"]]
)
list_ppc[["h_2"]][["red_colorblind"]] <- pp_check(
  list_fitted[["h_2"]][["red_colorblind"]]
)
list_ppc[["h_2"]][["blue_colorblind"]] <- pp_check(
  list_fitted[["h_2"]][["blue_colorblind"]]
)
# Hypothesis 2a
    #* Fit the models
list_fitted[["h_2a"]][["trial_2_red"]] <- brm(
  formula = trial_2_party ~ trial_2_red_stimuli
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2a"]][["trial_2_blue"]] <- brm(
  formula = trial_2_party ~ trial_2_blue_stimuli
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2a"]][["trial_2_single_model"]] <- brm(
  formula = trial_2_party ~ trial_2_red_stimuli_alt + trial_2_blue_stimuli_alt
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_2a"]][["trial_3_red"]] <- brm(
    formula = trial_3_party ~ trial_3_red_stimuli
    , data = list_df[["cleaned"]]
    , family = cumulative(link = "logit")
    , prior = set_prior("normal(0, 1)", class = "b")
    , backend = "cmdstanr"
)
list_fitted[["h_2a"]][["trial_3_blue"]] <- brm(
    formula = trial_3_party ~ trial_3_blue_stimuli
    , data = list_df[["cleaned"]]
    , family = cumulative(link = "logit")
    , prior = set_prior("normal(0, 1)", class = "b")
    , backend = "cmdstanr"
)
list_fitted[["h_2a"]][["trial_3_single_model"]] <- brm(
  formula = trial_3_party ~ trial_3_red_stimuli_alt + trial_3_blue_stimuli_alt
  , data = list_df[["cleaned"]]
  , family = cumulative(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
    #* Posterior predictive checks
list_ppc[["h_2a"]][["trial_2_red"]] <- pp_check(
  list_fitted[["h_2a"]][["trial_2_red"]]
)
list_ppc[["h_2a"]][["trial_2_blue"]] <- pp_check(
  list_fitted[["h_2a"]][["trial_3_blue"]]
)
list_ppc[["h_2a"]][["trial_2_single_model"]] <- pp_check(
  list_fitted[["h_2a"]][["trial_2_single_model"]]
)
list_ppc[["h_2a"]][["trial_3_red"]] <- pp_check(
  list_fitted[["h_2a"]][["trial_3_red"]]
)
list_ppc[["h_2a"]][["trial_3_blue"]] <- pp_check(
  list_fitted[["h_2a"]][["trial_3_blue"]]
)
list_ppc[["h_2a"]][["trial_3_single_model"]] <- pp_check(
  list_fitted[["h_2a"]][["trial_3_single_model"]]
)
# Hypothesis 3
  #* Fit the models
list_fitted[["h_3"]][["red"]] <- brm(
  formula = trial_1_vote ~ trial_1_red_stimuli + pid_7 + trial_1_red_stimuli * pid_7 + attention + age + gender_id + race_id
  , data = list_df[["cleaned"]]
  , family = bernoulli(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_3"]][["blue"]] <- brm(
  formula = trial_1_vote ~ trial_1_blue_stimuli + pid_7 + trial_1_blue_stimuli * pid_7 + attention + age + gender_id + race_id
  , data = list_df[["cleaned"]]
  , family = bernoulli(link = "logit")
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"  
)
  #* Posterior predictive checks
list_ppc[["h_3"]][["red"]] <- pp_check(
  list_fitted[["h_3"]][["red"]]
)
list_ppc[["h_3"]][["blue"]] <- pp_check(
  list_fitted[["h_3"]][["blue"]]
)
# Hypothesis 4
  #* Fit models
list_fitted[["h_4"]][["red"]] <- brm(
  formula = trial_1_time_elapsed ~ trial_1_red_stimuli + pid_7 + trial_1_red_stimuli * pid_7 + attention + age + gender_id + race_id
  , data = list_df[["cleaned"]]
  , family = negbinomial
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
list_fitted[["h_4"]][["blue"]] <- brm(
  formula = trial_1_time_elapsed ~ trial_1_blue_stimuli + pid_7 + trial_1_blue_stimuli * pid_7 + attention + age + gender_id + race_id
  , data = list_df[["cleaned"]]
  , family = negbinomial
  , prior = set_prior("normal(0, 1)", class = "b")
  , backend = "cmdstanr"
)
  #* Posterior predictive checks
list_ppc[["h_4"]][["red"]] <- pp_check(
  list_fitted[["h_4"]][["red"]]
)
list_ppc[["h_4"]][["blue"]] <- pp_check(
  list_fitted[["h_4"]][["blue"]]
)
# Hypothesis 5
  #* Fit models
list_fitted[["h_5"]][["red"]] <- ordbetareg(
  formula = red_prop ~ dem_vote_share + (1 | state_district)
  , data = df_study_2
  , threads = 4
  , backend = "cmdstanr"
  , control = list(
    adapt_delta = 0.95
  )
  , coef_prior_SD = 2
)
list_fitted[["h_5"]][["blue"]] <- ordbetareg(
  formula = blue_prop ~ dem_vote_share + (1 | state_district)
  , data = df_study_2
  , threads = 4
  , backend = "cmdstanr"
  , control = list(
    adapt_delta = 0.95
  )
  , coef_prior_SD = 2
)
  #* Posterior predictive checks
list_ppc[["h_5"]][["red"]] <- pp_check_ordbeta(
  list_fitted[["h_5"]][["red"]]
)
list_ppc[["h_5"]][["blue"]] <- pp_check_ordbeta(
  list_fitted[["h_5"]][["blue"]]
)
# Store model results
save(
    list_fitted
    , list_ppc
    , file = "../data/temp/models/study_1_fitted.RData"
)