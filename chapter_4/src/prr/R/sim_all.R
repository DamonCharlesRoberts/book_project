'.__module__.'
#' do all simulations
box::use(
    ./generate_samples[generate_samples]
    , ./discrepancy[discrepancy]
)
#' sim_all
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
    n = c(200, 400, 600, 800)
    , num_samples = 500
    , formula 
    , compiled
    , family
    , priors
    , model
) {
    # generate samples
    samplesList <- lapply(
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
    modelsList <- lapply(
        samplesList
        , function(x) {
            model <- discrepancy(
                compiled = compiled
                , data = x
                , formula = formula
                , family = family
                , priors = priors
                , model = model
            )
            return(model)
        }
    )
    return(modelsList)
}
