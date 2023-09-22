# Title: testing the functions in model.R

# Notes:
    #* Description
        #** Unit tests for the functions in model.R
    #* Updated
        #** 2023-06-13
        #** dcr

# Setup
  #* Set working directory
setwd("../src/prr")
  #* Load relevant functions
box::use(
  testthat[...]
  , data.table[...]
  , ./R/sample[...]
  , ./R/model[...]
)
  #* examples
    #** define a list of different sample sizes
list_sample_size <- c(100, 150, 200, 250)
    #** sample the data at different sample sizes
list_simulated <- lapply(
  list_sample_size
  , function(x) {
    df_sample <- study_simulator(
      study = 1
      , n = x
      , n_samples = 10
      , seed = 121022
    )
    # Return df_sample
    return(df_sample)
  }
)
    #** default arguments
formula_study_1_model_1 <- brms::brmsformula(
  notice ~ prime
)
family_study_1_model_1 <- brms::bernoulli(link = "logit")
prior_study_1_model_1 <- brms::set_prior(
  "normal(0, 1)"
  , class = "b"
)
stan_compiled_model <- rstan::stan_model(
  file = "./STAN/study_1_model_1.stan"
  , model_name = "study_1_model_1"
)
    #** fitting a single model
df_example <- list_simulated[[1]][
  sample == 1,
]
standata_example <- brms::make_standata(
  formula = formula_study_1_model_1
  , data = df_example
  , family = family_study_1_model_1
  , prior = prior_study_1_model_1
)
stan_single_fitted <- fit_sim_model(
  list_data = standata_example
  , compiled_stan_model = stan_compiled_model
  , parameters = c("b[1]")
)
    #** fitting multiple models
df_example_2 <- list_simulated[[1]]

stan_multiple_fitted <- fit_sims(
  data_frame = df_example_2
  , compiled_stan_model = stan_compiled_model
  , formula = formula_study_1_model_1
  , family = family_study_1_model_1
  , prior = prior_study_1_model_1
)
  #** fitting multiple models at different sample sizes
list_multiple_sample_sizes <- base::lapply(
  list_simulated
  , function(x) {
    fit_sims(
      data_frame = x
      , compiled_stan_model = stan_compiled_model
      , formula = formula_study_1_model_1
      , family = family_study_1_model_1
      , prior = prior_study_1_model_1
    )
  }
)

# Tests
  #** for a single sample
test_that(
  "single sample class"
  , expect_s3_class(
    stan_single_fitted
    , "data.table"
  )
)
test_that(
  "single sample ncol"
  , expect_true(
    ncol(stan_single_fitted) == 5
  )
)
test_that(
  "single sample nrow"
  , expect_true(
    nrow(stan_single_fitted) == 1
  )
)
  #** For multiple samples
test_that(
  "multiple sample class"
  , expect_s3_class(
    stan_multiple_fitted
    , "data.table"
  )
)
test_that(
  "multiple sample ncol"
  , expect_true(
    ncol(stan_multiple_fitted) == 6
  )
)
test_that(
  "multiple sample nrow"
  , expect_true(
    nrow(stan_multiple_fitted) == 10
  )
)
  #** For multiple sample sizes
test_that(
  "multiple sample sizes class"
  , expect_type(
    list_multiple_sample_sizes
    , "list"
  )
)
test_that(
  "multiple sample sizes list length"
  , expect_true(
    length(list_multiple_sample_sizes) == length(list_sample_size)
  )
)