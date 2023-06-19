#' @title define breaks
#'
#' @description
#' This function takes the standard deviation
#' of the latent variables and creates quiltiles
#' for those variables to define as the
#' break values
#'
#' @param vector A column from a data.frame object.
#'
#' @param cuts A integer value of how many ordered outcomes are expected.
#'
#' @returns numeric A numeric class listing cut points.
#'
#' @examples
#' df <- data.frame(A = c(1, 2, 3, 4, 5))
#' define_break(vector = df$A, cuts = 5)
#
define_break <- function(
  vector = NULL
  , cuts = 5
) {
  # find the cuts in the data based on pre-specified number
  quintile <- stats::quantile(
    x = vector
    , probs = seq(
      0
      , 1
      , 1 / (cuts - 1)
    )
  )
  # Take the cuts and put it into a list of buckets
  if (cuts == 5) {
    list_quintile <- c(
      -Inf
      , quintile[[1]]
      , quintile[[2]]
      , quintile[[3]]
      , quintile[[4]]
      , Inf
    )
  } else if (cuts == 7) {
     list_quintile <- c(
      -Inf
      , quintile[[1]]
      , quintile[[2]]
      , quintile[[3]]
      , quintile[[4]]
      , quintile[[5]]
      , quintile[[6]]
      , Inf
     )
  } else {
    print(
      "
      Invalid number of cuts entered.
      Specify the 'cuts' option as either 5 or 7.
      "
    )
  }
  # Return the list of buckets
  return(list_quintile)
}
#' @title generate a single sample
#'
#' @description
#' This is a funciton that generates a single sample
#' based on characteristics of the study design
#'
#' @details
#'
#' The characteristics of the sample depends on which study I am doing
#'
#' @param study An integer specifying whether this is for study 1 or study 2.
#' @param seed A integer specifying which seed to use.
#'
#' @returns sample A data.frame object.
#'
#' @examples
#' df <- single_sample()
#' df_alt <- single_sample(study = 1, seed = 121022)
#'
single_sample <- function(
  study = 1 # study 1 or study 2
  , seed = 121022 # seed
) {
  # Set seed
  set.seed(seed)
  # Likert break labels
  list_likert_labels <- c(
    "Strongly disagree"
    , "Disagree"
    , "Neither disagree or agree"
    , "Agree"
    , "Strongly agree"
  )
  list_pid_labels <- c(
    "Strong Republican"
    , "Republican"
    , "Lean Republican"
    , "Neither Republican or Democrat"
    , "Lean Democrat"
    , "Democrat"
    , "Strong Democrat"
  )
  # Generate DGP
  if (study == 1) {
    dgp <- fabricatr::fabricate(
      N = 100000 # The population size
      , E = stats::rnorm(N, mean = 0, sd = 1) # the epsilon term # nolint
      , age = base::round(
        stats::runif(
          N
          , 18
          , 85
        )
      ) # define the age variable. Uniform dist with 18 as low and 85 as high
      , gender = fabricatr::draw_binary(
        N
        , prob = 0.5
      ) # define the gender variable. Binary outcome
      , education = stats::rnorm(
        N
        , mean = -0.01 * age + 0.1 * gender + 14 + E # nolint
        , sd = 0.5
      ) # define the education variable. Normal distribution
      , income = stats::rnorm(
        N
        , mean = 2 * age + 0.7 * gender + 40000 + E
        , sd = 20000
      ) # define the income variable. Normal distribution
      , conflict_raw = stats::rnorm(N, mean = 0.3 * gender + 2.5 + E)
      , conflict = fabricatr::draw_ordered(
        N
        , x = conflict_raw # nolint
        , breaks = define_break(vector = conflict_raw, cuts = 5)
        , break_labels = list_likert_labels
      ) # define the conflict avoidance question. ordered variable
      , party_id_raw = stats::rnorm(N, mean = 0.4 * age - 0.6 * gender + 0.5 * income + E) # nolint
      , party_id = fabricatr::draw_ordered(
        x = stats::rnorm(
          N
          , mean = party_id_raw # nolint
        )
        , breaks = define_break(party_id_raw, cuts = 7)
        , break_labels = list_pid_labels
      ) # define the party_id variable. ordered variable.
      , attention_raw = stats::rnorm(
        N
        , mean = 0.5 * age - 0.3 * gender + 0.1 * income + E
      )
      , attention = fabricatr::draw_ordered(
        x = attention_raw # nolint
        , breaks = define_break(vector = attention_raw, cuts = 5)
        , break_labels = list_likert_labels
      ) # define the attention variable. Ordered variable
      , prime = fabricatr::draw_binary(
        N
        , prob = 1 / 2
      ) # define prime treatment. Binary.
      , blue_shirt = fabricatr::draw_binary(
        N
        , prob = 1 / 2
      ) # defien the blue_shirt treatment. Binary.
      , notice = fabricatr::draw_binary(
        N
        , prob = 1 * prime # nolint
      )
      , willing_raw = stats::rnorm(N, mean = 0.1 * prime + 0.1 * blue_shirt + 0.1 * as.numeric(party_id) + 0.5 * prime * blue_shirt * as.numeric(party_id) + E) # nolint
      , willing = fabricatr::draw_ordered(
        x = willing_raw # nolint
        , breaks = define_break(vector = willing_raw, cuts = 5)
        , break_labels = list_likert_labels
      )
    )
    # drop _raw columns
    dgp <- dgp[
      , -grep("_raw", colnames(dgp))
    ]
  } else if (study == 2) {
    dgp <- fabricatr::fabricate(
      N = 100000 # the population size
      , E = stats::rnorm(N, mean = 0, sd = 1) # the epsilon term # nolint
      , age = base::round(
        stats::runif(
          N
          , 18
          , 85
        )
      ) # define the age variable. Uniform dist with 18 as low and 85 as high.
      , gender = fabricatr::draw_binary(
        N
        , prob = 0.5
      ) # define the gender variable. Binary outcome
      , education = stats::rnorm(
        N
        , mean = -0.01 * age + 0.1 * gender + 14 + E # nolint
      ) # define the education variable. Normal distribution
      , income = stats::rnorm(
        N
        , mean = 2 * age + 0.7 * gender + 40000 + E
        , sd = 20000
      ) # define the income variable. Normal distribution
      , conflict_raw = stats::rnorm(N, mean = 0.3 * gender + 2.5 + E)
      , conflict = fabricatr::draw_ordered(
        N
        , x = conflict_raw # nolint
        , breaks = define_break(vector = conflict_raw, cuts = 5)
        , break_labels = list_likert_labels
      ) # define the conflict avoidance question. ordered variable
      , party_id_raw = stats::rnorm(
        N
        , mean = 0.4 * age - 0.6 * gender + 0.5 * income + E # nolint
      ) # define party_id latent variable. Continuous.
      , party_id = fabricatr::draw_ordered(
        x = stats::rnorm(
          N
          , mean = party_id_raw # nolint
        )
        , breaks = define_break(party_id_raw, cuts = 7)
        , break_labels = list_pid_labels
      ) # define the party_id variable. Ordered variable.
      , attention_raw = stats::rnorm(
        N
        , mean = 0.5 * age - 0.3 * gender + 0.1 * income + E
      ) # define attention latent variable. Continuous.
      , attention = fabricatr::draw_ordered(
        x = attention_raw # nolint
        , breaks = define_break(vector = attention_raw, cuts = 5)
        , break_labels = list_likert_labels
      ) # define the attention variable. Ordered variable
      , congruent = fabricatr::draw_binary(
        N
        , prob = 1 / 2
      ) # define congruency treatment. Binary.
      , blue_shirt = fabricatr::draw_binary(
        N
        , prob = 1 / 2
      ) # define the blue_shirt treatment. Binary.
      , willing_raw = stats::rnorm(
        N
        , mean = 0.1 * congruent + 0.1 * blue_shirt + 0.1 * as.numeric(party_id) + 1 * congruent * blue_shirt * as.numeric(party_id) + E # nolint
      )
      , willing = fabricatr::draw_ordered(
        x = willing_raw # nolint
        , breaks = define_break(vector = willing_raw, cuts = 5)
        , break_labels = list_likert_labels
      )
    )
    # drop _raw columns
    dgp <- dgp[
      , -grep("_raw", colnames(dgp))
    ]
  } else {
    base::stop(
      "Invalid study number. option 'study' should either equal 1 or 2."
    )
  }
  # return sample
  return(dgp)
}
#' @title multiple random samples from dgp
#'
#' @description
#' Take the single_sample function to return the dgp
#' then take multiple random samples from it.
#'
#' @details
#' This is a wrapper function for the single_sample function.
#' This is the function that should be exported and used by the user.
#'
#' @param study An integer specifying whether this is for study 1 or study 2
#' @param n An integer specifying the number of observations in a sample
#' @param n_samples the number of samples to collect.
#' @param seed An integer specifying which seed to use
#'
#' @returns df_samples A data.frame object
#'
#' @examples
#'
#'
study_simulator <- function( # nolint
  study = 1 # study 1 or study 2
  , n = 100 # size of each sample
  , n_samples = 1 # number of samples
  , seed = 121022 # seed
) {
  if (study == 1 || study == 2 && n > 0 && n_samples > 0) {
    # Simulate the dgp/population
    df_dgp <- single_sample(
      study = study
      , seed = seed
    )

    # Sample from this df_dgp data.frame a pre-specified number of times
    df_samples <- infer::rep_sample_n(
      tbl = df_dgp
      , size = n
      , replace = TRUE
      , reps = n_samples
    ) |>
    data.table::as.data.table()

    # Make a sample column in the data.frame to record which sample it is from
    df_samples <- df_samples[
      , sample := factor(replicate)
    ][
      , replicate := NULL
    ]
    # return the data.frame samples
    return(df_samples)
  } else {
    stop("Check to make sure that the options you entered are allowed")
  }
}