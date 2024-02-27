#' generate a single random sample
#' @param N size of sample.
#' @param seed seed
#' @return data.table
#' @export
one_sample <- function(n = 100, seed = 121022) {
    base::set.seed(seed)
    #* define population
    dgp <- fabricatr::fabricate(
        N = 1000000 # N in the population
        , E = stats::rnorm(N) # epsilon term
        , age = base::round( # define age variable
          stats::runif(N, 18, 85)
        )
        , gender = fabricatr::draw_binary( # define binary gender identity variable
          N
          , prob = 0.5
        )
        , white = fabricatr::draw_binary( # define white indicator variable
          N
          , prob = 0.6
        )
        , PartyID = fabricatr::draw_ordered( # define party identity variable as 3-item ordinal
          x = stats::rnorm(
            N
            , mean = 0.4 * age - 0.6 * gender + 0.7 * white + E
          )
          , breaks = base::c(
            -Inf, 20.14, 23.01, Inf
          )
        )
        , attention = fabricatr::draw_likert( # define Attention variable as 5-item ordinal
          x = stats::rnorm(
            N
            , mean = 0.5 * age - 0.3 * gender + 0.1 * white + E
          )
          , min = 0
          , max = 100
          , bins = 5
        )
        , RedTreatment = fabricatr::draw_binary( # Simulate treatment assignment with prob 1/3
            N
            , prob=1/2
        )
        , RepTreatment = base::sample(
            -1:1
            , N
            , replace=TRUE
        )
        , preference = fabricatr::draw_likert( # Define Preference outcome variable as 5-item ordinal
            x = stats::rnorm(
                N
                , mean = E + 1.5 * RedTreatment + 1.5 * PartyID + 2 * RedTreatment * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
            )
            , min = 0
            , max = 100
            , bins = 2
        )
        , move = fabricatr::draw_likert( # Define move outcome variable as Likert variable
            x = stats::rnorm(
                N
                , mean = (
                    E + 1.5 * RedTreatment + 1.5 * PartyID + 2 * RedTreatment * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
                )
            )
            , min = 0
            , max = 60
            , breaks = 5
        )
        , preference_post = fabricatr::draw_likert( # Define Preference (post new information) outcome variable as 3-item ordinal
            x = stats::rnorm(
                N
                , mean = E + 1 * RedTreatment + 1 * RepTreatment + 2 * PartyID + 2.5 * RedTreatment * RepTreatment * PartyID * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
            )
            , min = 0
            , max = 100
            , bins = 2
        )
        , move_post = fabricatr::draw_likert(# Define move outcome variable as Likert variable
            x = stats::rnorm(
                N
            , mean = (
                E + 0.5 * RedTreatment + 0.5 * RepTreatment + 1.5 * PartyID + 2.5 * RedTreatment * RepTreatment * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
            )
          )
          , min = 0
          , max = 100
          , bins = 5
        )
    )
    #* take sample of population with size n
    sampled <- dgp[base::sample(1:base::nrow(dgp), n), ]
    # return it 
    return(sampled)
}

#' @title generate_samples
#' @description Generate multiple samples
#' @param n list of sample sizes
#' @param num_samples number of samples for each n
#' @param seed seed
#' @return list of data.table
#' @export
generate_samples <- function(n = base::c(100), num_samples = 1, seed = 121022) {
    # set seed
    base::set.seed(seed)
    # create empty list
    sampleData <- base::list()
    # if there is only one sample size passed, get one sample for the specified size
    if (length(n) == 1 && num_samples == 1) {
        sampleData <- one_sample(n)
    # if there are multiple sample sizes passed but only one sample at each size, get a sample for each size
    } else if (length(n) != 1 && num_samples == 1) {
        sampleData <- lapply(n, one_sample)
    # if there are multiple at multiple sample sizes, do it multiple times for each sample size
    } else {
        sampleData <- replicate(
            num_samples,
            lapply(n, one_sample)
        )
    }
}

#' @title discrepancy
#' @description get discrepancy between pt.estimates and parameters
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
    , cores
) {
    # Define parameters
    parameters <- base::c(
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
                nrow = 0
                , ncol = 7
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
                , cores = cores
                , show_messages = FALSE
            )
            # convert it to a data.table object
            fittedDF <- data.table::as.data.table(fitted)
            # calculate the credible intervals
            cI <- data.table::as.data.table(
                bayestestR::hdi(
                    fittedDF
                    , parameters = base::c("b")
                    , ci = 0.90
                )
            )[Parameter %in% parameters, ]
            # determine whether pt.estimate is outside of credible interval
            pos <- data.table::transpose(
                cI[
                    , pos := data.table::fifelse(
                        cI$CI_low > 0 & cI$CI_high > 0, 1,
                        data.table::fifelse(
                            cI$CI_low < 0 & cI$CI_high < 0, 1, 0
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

#' @title sim_all
#' @description simulate all of the samples and fit the models...
#' ... and calculate their discrepancies
#' @param n size of sample
#' @param num_samples number of samples
#' @param formula formula for model
#' @param compiled compiled stan model
#' @param family family of model
#' @param priors priors of model
#' @param model model name
#' @returns list of lists
#' @export
sim_all <- function(
    n = base::c(200, 400, 600, 800)
    , num_samples = 500
    , formula 
    , compiled
    , family
    , priors
    , model
    , cores
) {
    # generate samples
    samplesList <- base::lapply(
        n
        , function(x) {
            sample <- generate_samples(
                n = x
                , num_samples = num_samples
            )
            return(sample)
        }
    )
    # execute models on sample
    modelsList <- base::lapply(
        samplesList
        , function(x) {
            model <- discrepancy(
                compiled = compiled
                , data = x
                , formula = formula
                , family = family
                , priors = priors
                , model = model
                , cores = cores
            )
            return(model)
        }
    )
    return(modelsList)
}

#' @title true_positive
#' @description calculate the true positive rate for a single sample
#' @param df vector to calculate the true positive rate for
#' @param new_names
#' @return data.table
#' @export
true_positive <- function(
    df
    , new_names
) {
    rate <- data.table::as.data.table(
        base::lapply(
            df
            , function(x) {
                base::mean(
                    x
                    , na.rm = TRUE
                ) * 100
            }
        )
    )
    names(rate) <- new_names
    return(rate)
}

#' @title true_positive_hist
#' @description plot a histogram of the true positive rate
#' @param df data.frame
#' @param var variable on x-axis
#' @return ggplot
#' @export
true_positive_hist <- function(
    df
    , var
) {
    # define ggplot
    plot <- ggplot2::ggplot(
        data = df
    ) +
    ggplot2::geom_bar(
        ggplot2::aes(
            y = .data[[var]]
            , x = factor(`Sample size`)
        )
        , stat = "summary"
        , fun = "mean"
    ) +
    ggplot2::labs(
        x = "Sample size"
        , y = "True positive rate"
    ) +
    ggplot2::theme_minimal()
    return(plot)
}

#' @title discrepancy_df
#' @description Make a data.table of discrepancies for the different sample sizes
#' @param list list of data.tables of discrepancies
#' @param new_names list of new names for variables
#' @returns data.table
#' @export
discrepancy_df <- function(
    list
    , new_names
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
        , use.names = TRUE
        , idcol = TRUE
    )[
        ,`.id` := data.table::fcase(
            `.id` == 1, "n=200"
            , `.id` == 2, "n=400"
            , `.id` == 3, "n=600"
            , `.id` == 4, "n=800"
        )
    ]
    names(truePositivesDF) <- new_names
    return(truePositivesDF)
}