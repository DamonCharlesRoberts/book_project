# Title: test of plot functions

# Notes:
    #* Description
        #** unit tests for plot functions
        #** NEED TO MANUALLY RUN THIS ONE
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
  , ./R/plot[...]
)
  #* Create example
    #** define sample sizes
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
    #** default model arguments
      #*** formula
formula_study_1_model_1 <- brms::brmsformula(
  notice ~ prime
)
      #*** family
family_study_1_model_1 <- brms::bernoulli(link = "logit")
      #*** priors
prior_study_1_model_1 <- brms::set_prior(
  "normal(0, 1)"
  , class = "b"
)
      #** compiled model
stan_compiled_model <- rstan::stan_model(
  file = "./STAN/study_1_model_1.stan"
  , model_name = "study_1_model_1"
)
    #** fit models
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
names(list_multiple_sample_sizes) <- list_sample_size
df_example <- rbindlist(
  list_multiple_sample_sizes
  , idcol = "sample_size"
)[
  , sample_size := factor(sample_size)
]
    #** generate plot
plot_test <- true_positive_plot(
  data_frame = df_example
)

# Tests
test_that(
  "make sure it returns one plot"
  , expect_length(
    plot_test, 1
  )
)