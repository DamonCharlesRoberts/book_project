# Title: test of sample.R functions

# Notes:
  #* Description
    #** Unit test of functions from sample.R
  #* Updated
    #** 2023-06-12
    #** dcr

# Setup
  #* set working directory
setwd("../src/prr")
#setwd("./src/prr")
  #* Modularly load functions
box::use(
  testthat[...]
  , ./R/sample[...]
)
  #* example
    #** study 1
      #** single sample
df_sample_study_1 <- single_sample()
      #** 10 samples
df_multi_study_1 <- study_simulator(study = 1, n = 100, n_samples = 10)
    #* study 2
      #** single sample
df_sample_study_2 <- single_sample(study = 2)
      #** 10 samples
df_multi_study_1 <- study_simulator(study = 1, n = 100, n_samples = 10)
# Tests
  #* Study 1
    #** single sample
test_that(
  "check class of study 1 single sample"
  , {
    expect_s3_class(
      df_sample_study_1
      , "data.frame"
    )
  }
)
test_that(
  "check ncol of study 1 single sample"
  , {
    expect_true(
      ncol(df_sample_study_1) == 13
    )
  }
)
test_that(
  "check to make sure nrow equals 100000 for single sample study 1"
  , {
    expect_true(
      nrow(df_sample_study_1) == 100000
    )
  }
)
test_that(
  "if study does not equal 1 or two, expect error"
  , {
    expect_error(
      single_sample(study = 3)
    )
  }
)
    #** multiple samples
test_that(
  "check class of study 1 multi sample"
  , {
    expect_s3_class(
      df_multi_study_1
      , "data.frame"
    )
  }
)
test_that(
  "check ncol of study 1 multi sample"
  , {
    expect_true(
      ncol(df_multi_study_1) == 14
    )
  }
)
test_that(
  "check to make sure nrow equals 1000 for multi sample study 1"
  , {
    expect_true(
      nrow(df_multi_study_1) == 1000
    )
  }
)
test_that(
  "if sample is not greater than one, expect error"
  , {
    expect_error(
      study_simulator(study = 1, sample = 0)
    )
  }
)
  #* Study 2
    #** single sample
test_that(
  "check class of study 1 single sample"
  , {
    expect_s3_class(
      df_sample_study_2
      , "data.frame"
    )
  }
)
test_that(
  "check ncol of study 2 single sample"
  , {
    expect_true(
      ncol(df_sample_study_2) == 12
    )
  }
)
test_that(
  "check to make sure nrow equals 100000 for single sample study 1"
  , {
    expect_true(
      nrow(df_sample_study_2) == 100000
    )
  }
)
    #** multiple samples
test_that(
  "check class of study 1 multi sample"
  , {
    expect_s3_class(
      df_multi_study_1
      , "data.frame"
    )
  }
)
test_that(
  "check ncol of study 1 multi sample"
  , {
    expect_true(
      ncol(df_multi_study_1) == 14
    )
  }
)
test_that(
  "check to make sure nrow equals 1000 for multi sample study 1"
  , {
    expect_true(
      nrow(df_multi_study_1) == 1000
    )
  }
)
