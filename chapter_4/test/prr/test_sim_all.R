# Title: test_sim_all

# Notes:
    #* Description
        #** test the sim_all function
    #* Updated
        #** 2023-05-09
        #** dcr

# Setup
    #* set working directory
setwd("../src/prr/R")
    #* load functions
box::use(
    ./sim_all[sim_all]
    ,brms[
        brmsformula
        , cumulative
        , prior
    ]
    , rstan[stan_model]
    , testthat[...]
)
    #* define some arguments
formula <- brmsformula(
    PartyGuess ~ RedTreatment + BlueTreatment + age +
    RedTreatment:age + BlueTreatment:age +
    Attention + Knowledge
)
base::suppressWarnings({
    compiled <- stan_model(
            "../STAN/vote_guess_simulated_model.stan"
            , model_name = "partyGuess"
    )
})
family <- cumulative(link="logit")
priors <- prior(
    stats::Normal(0,1)
    , class = b
)
# tests
    #* if I specify a model with 2 samples at 100 rows each...
    #* should expect 1 list with with dataframe in it with two rows
test_that(
    "expect list"
    , {
        expect_type(
            base::suppressWarnings({
                sim_all(
                    n = 100
                    , num_samples = 2
                    , formula = formula
                    , compiled = compiled
                    , family = family
                    , priors = priors
                    , model = "1List"
                )
            })
            , "list"
        )
    }
)
test_that(
    "1 list"
    , {
        expect_true(
            base::suppressWarnings({
                length(
                    sim_all(
                        n = 100
                        , num_samples = 2
                        , formula = formula
                        , compiled = compiled
                        , family = family
                        , priors = priors
                        , model = "1List"
                    )
                ) == 1
            })
        )
    }
)
test_that(
    "expect data.frames"
    , {
        expect_s3_class(
            base::suppressWarnings({
                sim_all(
                    n = 100
                    , num_samples = 2
                    , formula = formula
                    , compiled = compiled
                    , family = family
                    , priors = priors
                    , model = "1List"
                )[[1]]
            })
            , "data.table"
        )
    }
)
test_that(
    "expect 2 data.frames"
    , {
        expect_true(
            base::suppressWarnings({
                nrow(
                    sim_all(
                        n = 100
                        , num_samples = 2
                        , formula = formula
                        , compiled = compiled
                        , family = family
                        , priors = priors
                        , model = "1List"
                    )[[1]]
                )
            }) == 2
        )
    }
)
    #* If I specify a model with two samples of different sizes...
    #* I should expect a list with 2 dataframes in it
test_that(
    "data.frame"
    , {
        expect_s3_class(
            base::suppressWarnings({
                sim_all(
                    n = c(50,100)
                    , num_samples = 2
                    , formula = formula
                    , compiled = compiled
                    , family = family
                    , priors = priors
                    , model = "1List"
                )[[1]]
            })
            , "data.table"
        )
    }
)
test_that(
    "2 data.frame"
    , {
        expect_true(
            base::suppressWarnings({
                length(
                    sim_all(
                        n = c(50,100)
                        , num_samples = 2
                        , formula = formula
                        , compiled = compiled
                        , family = family
                        , priors = priors
                        , model = "1List"
                    )
                ) == 2
            })
        )
    }
)
test_that(
    "2 row data.frame"
    , {
        expect_true(
            base::suppressWarnings({
                nrow(
                    sim_all(
                        n = c(50,100)
                        , num_samples = 2
                        , formula = formula
                        , compiled = compiled
                        , family = family
                        , priors = priors
                        , model = "1List"
                    )[[1]]
                )
            }) == 2
        )
    }
)
