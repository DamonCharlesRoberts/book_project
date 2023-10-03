# Title: test_one_sample

# Notes:
    #* Description:
        #** Test the one_sample function
    #* Updated
        #** 2023-05-08
        #** dcr

# Setup
    #* set working directory
setwd("../src/prr/R")
    #* load functions
box::use(
    ./one_sample[one_sample]
    , testthat[...]
)
    #* execute example function
result <- one_sample(n = 100)

# tests
    #* check to make sure data.frame object
test_that(
    "check dataframe"
    , {
        expect_s3_class(
            result
            , "data.frame"
        )
    }
)
    #* check to make sure it has 100 rows
test_that(
    "check length"
    , {
        expect_true(
            nrow(result) == 100
        )
    }
)
    #* check to make sure it has 14 columns
test_that(
    "check columns"
    , {
        expect_true(
            ncol(result) == 14
        )
    }
)