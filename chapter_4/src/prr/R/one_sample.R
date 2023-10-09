'.__module__.'
#' generate a single random sample
#' @param n size of sample.
#' @param seed seed
#' @return data.table
#' @export
one_sample <- function(n=100, seed=121022) {
  set.seed(seed)
  #* define population
  dgp <- fabricate(
    N = 1000000 # N in the population
    , E = rnorm(N) # epsilon term
    , age = round( # define age variable
      runif(N, 18, 85)
    )
    , gender = draw_binary( # define binary gender identity variable
      N
      , prob = 0.5
    )
    , white = draw_binary( # define white indicator variable
      N
      , prob = 0.6
    )
    , PartyId = draw_ordered( # define party identity variable as 3-item ordinal
      x = rnorm(
        N
        , mean = 0.4 * age - 0.6 * gender + 0.7 * white + E
      )
      , breaks = c(
        -Inf, 20.14, 23.01, Inf
      )
    )
    , Attention = draw_ordered( # define Attention variable as 5-item ordinal
      x = rnorm(
        N
        , mean = 0.5 * age - 0.3 * gender + 0.1 * white + E
      )
      , breaks = c(
        -Inf, 16.5, 28.26, 36.54, 43.82, Inf
      )
    )
    , RedTreatment = draw_binary( # Simulate treatment assignment with prob 1/3
      N,
      prob = 0.5
    )
    , preference = draw_binary( # Define Preference outcome variable as 3-item ordinal
      x = rnorm(
        N
        , prob = (
          E + 1.5 * RedTreatment + 1.5 * PartyId + 2 * RedTreatment * PartyId + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
        )
      )
    )
    , move = draw_ordered( # Define move outcome variable as Likert variable
      x = rnorm(
        N
        , mean = (
          E + 1 * RedTreatment + 1 * PartyId + 2 * RedTreatment * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
        )
      )
      , breaks = c(
        -Inf, -3, -1, 1, 3, Inf
      )
    )
    , preference_post = draw_binary( # Define Preference (post new information) outcome variable as 3-item ordinal
      x = rnorm(
        N
        , prob = (
          E + 1 * RedTreatment + 2 * PartyID + 2.5 * RedTreatment * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
        )
      )
    )
    , move_post = draw_ordered(# Define move outcome variable as Likert variable
      x = rnorm(
        N
        , mean = (
          E + 0.5 * RedTreatment + 1.5 * PartyId + 2.5 * RedTreatment * PartyID + 0.5 * age + 0.3 * gender + 0.1 * white + 0.1 * attention
        )
      )
      , breaks = c(
        -Inf, -3, -1, 1, 3, Inf
      )
    )
  )
    #* take sample of population with size n
    Sampled <- dgp[sample(1:nrow(dgp), n), ]
}