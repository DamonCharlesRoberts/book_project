#' generate multiple samples
'.__module__.'
box::use(
    ./one_sample[
        one_sample
    ]
)
#' generate_samples
#' @param n list of sample sizes
#' @param num_samples number of samples for each n
#' @param seed seed
#' @return list of data.table
#' @export
generate_samples <- function(n=c(100),num_samples=1,seed=121022) {
    # set seed
    set.seed(seed)
    # create empty list
    sampleData <- list()
    # if there is only one sample size passed, get one sample for the specified size
    if (length(n) == 1 & num_samples == 1) {
        sampleData <- one_sample(n)
    # if there are multiple sample sizes passed but only one sample at each size, get a sample for each size
    } else if (length(n) != 1 & num_samples == 1) {
        sampleData <- lapply(n, one_sample)
    # if there are multiple at multiple sample sizes, do it multiple times for each sample size
    } else {
        sampleData <- replicate(
            num_samples,
            lapply(n, one_sample)
        )
    }
}