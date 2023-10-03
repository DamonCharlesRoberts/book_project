'.__module__.'
#' get discrepancy between pt.estimates and parameters
#'
#' dependencies
#'
#' discrepancy
#' @param compiled
#' @param data
#' @param formula
#' @param family
#' @param model
#' @return data.table
#' @export
discrepancy <- function (
    compiled
    , data
    , formula
    , family
    , priors
    , model
) {
    # Define parameters
    parameters <- c(
        "b[1]"
        , "b[2]"
        , "b[3]"
        , "b[4]"
        , "b[5]"
        , "b[6]"
        , "b[7]"
    )
    # Define a empty data.table
    rejectDF <- stats::setNames(
        data.table::data.table(
            base::matrix(
                nrow=0
                ,ncol=7
            )
        ),
        parameters
    )
    # Fit the model for each sample
    sumList <- base::lapply(
        data,
        function (x) {
            # Define the stan data object
            dfList <- brms::make_standata(
                formula
                , data = x
                , family = family
                , priors = priors
            )
            # fit the stan model
            fitted <- rstan::sampling(
                compiled
                , dfList
                , chains = 1
                , iter = 100
                , refresh = 0
                , show_messages = FALSE
            )
            # convert it to a data.table object
            fittedDF <- data.table::as.data.table(fitted)
            # calculate the credible intervals
            cI <- data.table::as.data.table(
                bayestestR::hdi(
                    fittedDF
                    , parameters = c("b")
                    , ci = 0.90
                )
            )[
                Parameter %in% parameters
            ]
            # determine whether pt.estimate is outside of credible interval
            pos <- data.table::transpose(
                cI[
                    , pos := data.table::fifelse(
                        cI$CI_low > 0 && cI$CI_high > 0, 1,
                        data.table::fifelse(
                            cI$CI_low < 0 && cI$CI_high < 0, 1, 0
                        )
                    )
                ][
                    , list(Parameter, pos)
                ]
            )
            colnames(pos) <- parameters
            pos <- pos[-1, ]
            pos <- data.table::as.data.table(
                base::lapply(pos, as.numeric)
            )
            # Update the dataframe on whether to reject or not
            rejectDF <- base::rbind(
                rejectDF
                , pos
            )
        }
    )
    sumDF <- data.table::rbindlist(
        sumList
    )
    return(sumDF)
}