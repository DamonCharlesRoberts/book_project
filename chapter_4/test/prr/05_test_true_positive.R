# Title: test_true_positive

# Notes:
    #* Description 
        #** test true_positive function
    #* Updated
        #** 2023-05-10
        #** dcr

# Setup
    #* set working directory
setwd("./chapter_4/src/prr/R")
    #* load functions
box::use(
    ./helper[true_positive]
    , testthat[...]
)
    #* define vector
vector <- data.frame(
    a = c(0, 0, 0, 0)
    , b = c(0, 0, 0, 1)
    , c = c(0, 0, 1, 1)
    , d = c(0, 1, 1, 1)
    , e = c(1, 1, 1, 1)
)
new_names <- c("none", "quarter", "half", "three_quarters", "full")
# Test
    #* check to make sure it returns a digit
test_that(
    "return list"
    , {
        expect_type(
            true_positive(
                vector
                , new_names = new_names
            )
            , "list"
        )
    }
)
    #* check to make sure it returns the right number
test_that(
    "return right number"
    , {
        expect_true(
            true_positive(
                vector
                , new_names = new_names
            )[, 1] == 0.0
        )
    }
)
