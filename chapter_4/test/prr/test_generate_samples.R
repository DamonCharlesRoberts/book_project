# Title: test_generate_samples

# Notes:
    #* Description:
        #** Test the generate_samples function
    #* Updated
        #** 2023-05-08
        #** dcr

# Setup
setwd("../src/prr/R/")
    #* load functions
box::use(
    ./generate_samples[generate_samples]
    , testthat[...]
)
    #* execute function
result_one_sample <- generate_samples(
    n = 100
)
result_one_sample_two_size <- generate_samples(
    n = c(100, 200)
)
result_multiple_sample_one_size <- generate_samples(
    n = 100
    , num_samples = 2
)
result_multiple_sample_multiple_size <- generate_samples(
    n = c(100, 200)
    , num_samples = 2
)

# tests
    #* check classes
        #** for one sample of one size
test_that(
    "check data.frame"
    , {
        expect_s3_class(
            result_one_sample
            , "data.frame"
        )
    }
)
        #** for one sample of two sizes
test_that(
    "check list two sizes"
    , {
        expect_type(
            result_one_sample_two_size
            , "list"
        )
    }
)
        #** for two samples of one size
test_that(
    "check list two samples"
    , {
        expect_type(
            result_multiple_sample_one_size
            , "list"
        )
    }
)
        #** for two samples of two sizes
test_that(
    "check list two samples of multiple sizes"
    , {
        expect_type(
            result_multiple_sample_multiple_size
            , "list"
        )
    }
)
    #* check dimensions
        #** for one sample one size
test_that(
    "check size of one sample one size"
    , {
        expect_true(
            nrow(result_one_sample) == 100
        )
    }
)
        #** for one sample two sizes
test_that(
    "check size of one sample two sizes"
    , {
        expect_true(
            length(result_one_sample_two_size) == 2
        )
    }
)
        #** for two sample one size
test_that(
    "check size of two sample one size"
    , {
        expect_true(
            length(result_multiple_sample_one_size) == 2
        )
    }
)
        #** for two samples two sizes
test_that(
    "check size of two sample two size"
    , {
        expect_true(
            length(result_multiple_sample_multiple_size) == 4
        )
    }
)
    #* check that data.frames are inside lists
test_that(
    "check that data.frames are inside lists"
    , {
        expect_s3_class(
            result_multiple_sample_multiple_size[[1]]
            , "data.frame"
        )
    }
)
    #* check that data.frames with 100 rows are inside lists
test_that(
    "check that data.frames inside lists are nrow=100"
    , {
        expect_true(
            nrow(result_multiple_sample_multiple_size[[1]]) == 100
        )
    }
)