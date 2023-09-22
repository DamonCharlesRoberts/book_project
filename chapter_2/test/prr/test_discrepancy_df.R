# Title: test_discrepancy_df

# Notes:
    #* Description
        #** Test of discrepancy_df function
    #* Updated
        #** 2023-05-10
        #** dcr

# Setup
    #* set working directory
setwd("chapter_2/test")
setwd("../src/prr/R")
    #* load functions
box::use(
    ./discrepancy_df[discrepancy_df]
    ,testthat[...]
)
    #* load example list
load(
    file="../../../data/models/prr/sim/sim.RDS"
)
   #* specify args
new_names <- c(
  "Red treatment"
  ,"Blue treatment"
  ,"Age"
  ,"Red treatment x Age"
  ,"Blue treatment x Age"
  ,"Attention"
  ,"Knowledge"
)

# Tests
    #* expect data.table
test_that(
    "expect data.table"
    ,{
        expect_s3_class(
            discrepancy_df(
                list=modelDiscrepancies
                ,new_names=new_names
            )
            ,"data.table"
        )
    }
)
    #* expect four rows
test_that(
    "expect four rows"
    ,{
        expect_true(
            nrow(
                discrepancy_df(
                    list=modelDiscrepancies
                    ,new_names=new_names
                )
            ) == 4
        )
    }
)