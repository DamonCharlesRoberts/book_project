'.__module__.' #nolint
#' @title plot true positive rate
#'
#' @description
#' This is a function that takes the calculated true positive rate
#' from `true_positive()` for each sample size and plots it
#' with a histogram.
#'
#' @param data_frame A data.table object returned from `true_positive()`.
#' @param var Which variable to calculate the true positive rate for.
#' @param new_names A list of names to put on the x-axis
#'
#' @returns plot A ggplot2 object.
#'
#' @examples
#'
true_positive_plot <- function(
  data_frame
  , var = "Parameter"
) {
  # split the datatable by variable
  list_true_positive <- split(
    data_frame
    , by = var
  )
  # Plot each list element
  list_plots <- base::lapply(
    list_true_positive
    , function(x) {
      plot <- ggplot2::ggplot(
        data = x
      ) +
      ggplot2::geom_bar(
        ggplot2::aes(
          y = true_positive
          , x = factor(sample_size)
        )
        , stat = "summary"
        , fun = "mean"
      ) +
      ggplot2::labs(
        x = "Sample size"
        , y = "True positive rate"
      ) +
      ggplot2::theme_minimal()
      # return plot
      return(plot)
    }
  )
  # return list of plots
  return(list_plots)
}
