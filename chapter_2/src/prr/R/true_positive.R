#' calculate the true positive rate
#'
'.__module__'
#' dependencies
#'
#' @param df vector to calculate the true positive rate for
#' @param new_names
#' @return data.table
#' @export
true_positive <- function (
    df
    ,new_names
) {
    rate <- data.table::as.data.table(
        base::lapply(
            df
            ,function (x) {
                base::mean(
                    x
                    ,na.rm=TRUE
                )*100
            }
        )
    )
    names(rate) <- new_names
    return(rate)
}