'.__module__.'
#' make graph of true_positive rates for modelDiscrepancies
#'
#' dependencies
box::use(
    ./true_positive[true_positive]
)
#' true_positive_hist
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
