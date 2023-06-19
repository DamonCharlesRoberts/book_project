'.__module__.' # nolint
#' @title fit a model
#'
#' @description
#' This is a function that takes some information about a rstan model
#' and then fits the model depending on that information.
#'
#' @details
#' This function is designed to take one data.frame
#' and to fit a model on that one data.frame.
#' There are higher level functions in here that rely upon this function.
#'
#' @param list_data Should be a stan compatible list of your data.
#' Can use `brms::make_standata` to do this.
#' @param compiled_stan_model Should be a compiled stan model.
#' @param ci_level Should be a float indicating what level do you want credible
#' intervals calculated at.
#' @param parameters Should be a list of strings to indicate what parameters you
#' you want to calculate the true positive rate for.
#'
#' @returns df_discrepancy A data.table saying whether the model's posterior
#' would indicate a non-zero result.
#'
#' @examples
#'
fit_sim_model <- function( # nolint
  list_data = NULL
  , compiled_stan_model = NULL
  , ci_level = 0.95
  , parameters = c("b[1]")
) {
  # fit the stan model
  stan_fitted <- rstan::sampling(
    compiled_stan_model
    , data = list_data
    , chains = 1
    , iter = 100
    , refresh = 0
    , verbose = FALSE
  )
  # turn it into a  data.frame
  df_fitted <- data.table::as.data.table(stan_fitted)
  # calculate credible intervals at pre-specified value
  df_ci <- data.table::as.data.table(
    bayestestR::hdi(
      df_fitted
      , parameters = c("b")
      , ci = ci_level
    )
  )[
    Parameter %in% parameters # nolint
  ]
    # calculate whether there was a discrepancy
  df_discrepancy <- df_ci[
    , true_positive := data.table::fifelse( # nolint
        CI_low > 0 & CI_high > 0, 1, # nolint
        data.table::fifelse(
            CI_low < 0 & CI_high < 0, 1, 0
        )
    )
  ]
    ## return fitted model
    return(df_discrepancy)
}

#' @title fit model on multiple simulated samples
#'
#' @description
#' This is a function that takes the `fit_sim_model()` function
#' and performs it iteratively on a large data.table that contains
#' data from many simulated samples that are grouped by a ID column
#' indicating which sample that data is from.
#'
#' @param data_frame A data.table/data.frame object
#' that contains multiple samples organized by a `sample` id column.
#' @param compiled_stan_model Should be a compiled stan model.
#' @param ci_level Should be a float indicating what level do you want credible
#' intervals calculated at.
#' @param parameters Should be a list of strings to indicate what parameters you
#' you want to calculate the true positive rate for.
#'
#' @returns df_discrepancy A data.table saying whether the model's posterior
#' would indicate a non-zero result.
#'
#' @examples
#'
fit_sims <- function( # nolint
  data_frame = NULL
  , compiled_stan_model = NULL
  , ci_level = 0.95
  , parameters = c("b[1]")
  , formula = NULL
  , priors = NULL
  , family = NULL
) {
  # Take the inputed data.frame and unbind the list
  list_datatables <- split(
    data_frame
    , by = "sample"
  )
  # Convert each into their own list objects
  list_stan_data <- base::lapply(
    list_datatables
    , function(x) {
      brms::make_standata(
        formula = formula
        , data = x
        , family = family
        , prior = priors
      )
    }
  )
  # Fit the models
  list_discrepancies <- base::lapply(
    list_stan_data
    , function(x) {
      fit_sim_model(
        list_data = x
        , compiled_stan_model = compiled_stan_model
        , ci_level = ci_level
        , parameters = parameters
      )
    }
  )
  # Collapse list of discrepancies into a data.table
  df_discrepancies <- data.table::rbindlist(
    list_discrepancies
    , fill = TRUE
    , idcol = "sample"
  )[
    , c(
      "sample"
      , "Parameter"
    ) := lapply(.SD, factor), .SDcols = c( # nolint
      "sample"
      , "Parameter"
    )
  ]
  # Return result
  return(df_discrepancies)
}