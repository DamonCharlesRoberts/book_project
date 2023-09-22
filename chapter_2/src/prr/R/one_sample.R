#' generate a single random sample
'.__module__.'
#' @param n size of sample.
#' @param seed seed
#' @return data.table
#' @export
one_sample <- function(n=100, seed=121022) {
    set.seed(seed)
    #* define population
    dgp <- fabricatr::fabricate(
        N = 100000, # N in the population
        E = stats::rnorm(N), # epsilon term
        age = base::round( # define age variable
            stats::runif(N, 18, 85)
        ),
        gender = fabricatr::draw_binary( # define binary gender identity variable
            N,
            prob = 0.5
        ),
        white = fabricatr::draw_binary( # define white indicator variable
            N,
            prob = 0.6
        ),
        PartyId = fabricatr::draw_ordered( # define party identification of simulated respondents
            x = stats::rnorm(
                N,
                mean = 0.4 * age - 0.6 * gender + 0.7 * white + E
            ),
            breaks = c(
                -Inf, 20.14, 23.01, Inf
            )
        ),
        Attention = fabricatr::draw_ordered( # define Attention variable
            x = stats::rnorm(
                N,
                mean = 0.5 * age - 0.3 * gender + 0.1 * white + E
            ),
            breaks = c(
                -Inf, 16.5, 28.26, 36.54, 43.82, Inf
            )
        ),
        Knowledge = stats::rnorm( # define Knowledge variable
            N,
            mean = 0.6 * age - 0.5 * gender + 0.2 * white + 0.8 * Attention + E
        )/100,
        RedTreatment = fabricatr::draw_binary( # Simulate treatment assignment
            N,
            prob = 1/3
        ),
        BlueTreatment = fabricatr::draw_binary( # Simulate treatment assignment
            N,
            prob = 1/3
        ),
        PartyGuess = fabricatr::draw_ordered( # Define PartyGuess outcome variable
            x = stats::rnorm(
                N,
                mean = 2 * RedTreatment + -2 * BlueTreatment - 0.01 * age - 0.1 * RedTreatment * age + 0.1 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E),
            breaks = c(
                -Inf, -0.5, 0, Inf
            )
        ),
        PartyGuessTrialTwo = fabricatr::draw_ordered( # Define PartyGuess outcome variable
            x = stats::rnorm(
                N,
                mean = 2 * RedTreatment + -2 * BlueTreatment - 0.01 * age - 0.1 * RedTreatment * age + 0.1 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E),
            breaks = c(
                -Inf, -0.5, 0, Inf
            )
        ),
        PartyGuessTrialThree = fabricatr::draw_ordered( # Define PartyGuessTrialTwo outcome variable
            x = stats::rnorm(
                N,
                mean = 1 * RedTreatment + -1 * BlueTreatment - 0.01 * age - 0.05 * RedTreatment * age + 0.05 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E
            ),
            breaks = c(
                -Inf, -1, 1, Inf
            )
        ),
        Vote = fabricatr::draw_ordered( # Define Vote outcome variable
            x = stats::rnorm(
                N,
                mean = 1 * RedTreatment + - 1 * BlueTreatment - 0.01 * age + 0.1 * Attention + 0.1 * Knowledge + E
            ),
            breaks = c(
                -Inf, 0, Inf
            )
        )
    )
    #* take sample of population with size n
    Sampled <- dgp[sample(1:nrow(dgp), n), ]
}