# Title: test_discrepancy

# Notes:
    #* Description
        #** test of discrepancy function
    #* Updated
        #** 2023-05-09
        #** dcr

# Setup
    #* set working directory
setwd("../src/prr/R")
    #* load functions
box::use(
    ./helper[
      generate_samples
      , discrepancy
    ]
    , brms[
        brmsformula
        , cumulative
        , prior
    ]
    , rstan[stan_model]
    , testthat[...]
)

base::suppressWarnings({
    #* execute function
        #** define compiled stan model
moveCompiled <- stan_model(
    "../STAN/move_model.stan"
)
        #** define brms formula
formula <- brmsformula(
    move ~ RedTreatment + PartyID + RedTreatment * PartyID + age + gender + white + attention
)
        #** create sample data
exampleSamples <- generate_samples(n = 100, num_samples = 2)
        #** calculate discrepancy
result <- discrepancy(
    compiled = moveCompiled
    , data = exampleSamples
    , formula = formula
    , family = cumulative(link = "logit")
    , priors = prior(
        Normal(0, 1)
        , class = b
    )
    , model = "moveModel"
)
})
# Tests
    #* check to make sure it returns a data.frame
test_that(
    "check class"
    , {
        expect_s3_class(
            result
            , "data.table"
        )
    }
)
    #* check to make sure that there are seven columns
test_that(
    "check num of columns"
    , {
        expect_true(
            ncol(result) == 7
        )
    }
)
    #* check to make sure that there are two rows
test_that(
    "check num of rows"
    , {
        expect_true(
            nrow(result) == 2
        )
    }
)
    #* expect warning
#test_that(
#    "expect warning"
#    ,{
#        expect_warning(result)
#    }
#)