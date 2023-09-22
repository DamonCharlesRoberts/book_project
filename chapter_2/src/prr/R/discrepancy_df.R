#' discrepancy_df
#'
'.__module__.'
#' dependencies
box::use(
    ./true_positive[true_positive]
    ,data.table[
        rbindlist
        ,fcase
        ,`:=`
    ]
)
#' discrepancy_df
#' @param list list of data.tables of discrepancies
#' @param new_names list of new names for variables
#' @returns data.table
#' @export
discrepancy_df <- function (
    list
    ,new_names
) {
    # calculate true positives for each sample size
    #truePositivesList <- base::lapply(
    #    list
    #    ,true_positive
    #    ,new_names=new_names
    #)
    # combine the true positive rate for each sample size
    truePositivesDF <- data.table::rbindlist(
        list
        ,use.names=TRUE
        ,idcol=TRUE
    )[
        ,`.id`:=data.table::fcase(
            `.id`==1,"n=200"
            ,`.id`==2,"n=400"
            ,`.id`==3,"n=600"
            ,`.id`==4,"n=800"
        )
    ]
    names(truePositivesDF) <- new_names
    return(truePositivesDF)
}
