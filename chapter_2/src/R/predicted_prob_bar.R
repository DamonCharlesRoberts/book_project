#' @title make barplots for predicted probabilities from ordered logit
#'
#' @description
#' This is a function that makes ggplot2 barplots by taking a fitted
#' ordered logit model, calculating the predicted probabilities,
#' and then plotting it with barplots and including error bars.
#'
#' @details
#' This function takes a brmsfit object. It uses the marginalefffects
#' package to calculate the predicted probabilities.
#'
#' @param
#'
#' @return plot A ggplot2 object.
#'
#' @example
#'
predicted_prob_bar <- function( # nolint: object_usage_linter.
  fitted_model
  , x_axis
  , treatment = "Red"
  , hypothesis = "H2"
  , level = 0.90
  , x_label = "Color of yard sign"
  , y_label = "Pr(Party of candidate)"
  , legend_title = "Party of candidate"
  , gray = TRUE
) {
  # Create a list of options for what to do when need to switch to grayscale
  if (gray != TRUE) {
    color_values <- list(
      "Democrat" = c("#00AEF3", "dotted")
      , "Independent" = c("#ffffff", "solid")
      , "Republican" = c("#ff0803", "dashed")
    )
  } else {
    color_values <- list(
      "Democrat" = c("#404040", "dotted")
      , "Independent" = c("#D3D3D3", "solid")
      , "Republican" = c("#808080", "dashed")
    )
  }

  # If this is for a ordered logit, I'll have to do some stacked
  if (hypothesis == "H2") {
    #* Calculate the predicted probabilities for the model
    df_pred_prob <- marginaleffects::predictions(
      model = fitted_model
      , conf_level = level
    )|>
    data.table::as.data.table() # convert it to a data.table
    #* Need to clean up the pred prob data.frame some
    df_pred_prob_cleaned <- df_pred_prob[
      #** aggregate the estimate, conf.low, and conf.high columns with
      #** a mean to calculate the average conditional predicted probabilities
      , .( # nolint: object_usage_linter.
        estimate = mean(estimate) # nolint: object_usage_linter.
        , conf.low = mean(conf.low) # nolint: object_usage_linter.
        , conf.high = mean(conf.high) # nolint: object_usage_linter.
      )
      #** this needs to be done by the group column and the
      #** independent variable
      , by = c(
        "group"
        , x_axis
      )
    ][
      #** convert the x-axis to a factor
      , x_axis_temp := factor(get(x_axis)) # nolint: object_usage_linter.
    ][
      #** convert the group column to a factor
      , group := factor(group) # nolint: object_usage_linter.
    ]
    # Make plot
      #* take the cleaned pred_prob dataframe
    plot <- ggplot2::ggplot(
      data = df_pred_prob_cleaned
    ) +
      #* make a barplot
      ggplot2::geom_bar(
        ggplot2::aes(
          #** put the IV on the x-axis, estimate on y
          #** and change the fill color based on group
          #** column which reflects the value of the outcome
          #** variable
          x = x_axis_temp # nolint: object_usage_linter.
          , y = estimate # nolint: object_usage_linter.
          , fill = group # nolint: object_usage_linter.
        )
          #** take the raw y value
        , stat = "identity"
          #** don't stack the bars
        , position = "dodge"
          #** add a black outline to each bar
        , color = "#000000"
      ) +
      #* Add error bars to plot
      ggplot2::geom_errorbar(
        ggplot2::aes(
          #** the x-axis location should be determined by the IV
          x = x_axis_temp
          #** the height of the bars should be based on the average
          #** high and low of the credible interval
          , ymin = conf.low # nolint: object_usage_linter.
          , ymax = conf.high # nolint: object_usage_linter.
          , linetype = group
        )
        , position = "dodge"
      ) +
      ggplot2::scale_x_discrete(
      #* Make the ticks for the x-axis not be numbers but the treatment
        labels = c(
          "White"
          , treatment
        )
      #* Change the fill colors to blue, white, and red while labeling it
      ) +
      ggplot2::scale_fill_manual(
        labels = names(color_values)
        , values = c(
          color_values[[1]][[1]]
          , color_values[[2]][[1]]
          , color_values[[3]][[1]]
        )
      )  +
      #* change the labels and linetype for the outcomes
      ggplot2::scale_linetype_manual(
        labels = names(color_values)
        , values = c(
          color_values[[1]][[2]]
          , color_values[[2]][[2]]
          , color_values[[3]][[2]]
        )
      ) +
      #* adjust the labels of the plot
      ggplot2::labs(
        x = x_label
        , y = y_label
        , linetype = legend_title
        , fill = legend_title
      ) +
      ggplot2::theme_minimal()
  # If this is for a ordered beta regression
  } else if (hypothesis == "H5") {
    df_pred_prob <- marginaleffects::predictions(
      model = fitted_model
      , newdata = marginaleffects::datagrid(
        model = fitted_model
        , dem_vote_share = c(
          0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
        )
      )
      , re_formula = NA
    ) |>
    marginaleffects::posterior_draws()
    #* make predictions
      #** define plot
    plot <- ggplot2::ggplot(
      data = df_pred_prob
      , ggplot2::aes(
        x = dem_vote_share # nolint: object_usage_linter.
        , y = draw # nolint: object_usage_linter.
      )
    ) +
      #** plot the change in predicted values
    tidybayes::stat_lineribbon(
      .width = level
      , alpha = 0.6
    ) +
    ggplot2::scale_color_manual(values = "#000000") +
      #** use the minimal theme
    ggplot2::theme_minimal() +
      #** exclude legend
    ggplot2::theme(
      legend.position = "none"
    )
      #** if this is for red yard signs
    if (treatment == "Red") {
      plot <- plot +
      #** change the color of the ribbon
      ggplot2::scale_fill_manual(
        values = color_values[[3]][[1]]
      ) +
      ggplot2::labs(
        x = "Democratic party vote share"
        , y = "Predicted proportion of red"
      )
    } else {
      plot <- plot +
      ggplot2::scale_fill_manual(
        values = color_values[[1]][[1]]
      ) +
      ggplot2::labs(
        x = "Democratic party vote share"
        , y = "Predicted proportion of blue"
      )

    }
  # If it is a logistic regression with binary outcome
  } else {
    if (gray == TRUE) {
      df_pred_prob <- marginaleffects::plot_predictions(
        model = fitted_model
        , condition = c("pid_7", x_axis)
        , conf_level = level
        , gray = TRUE
      ) +
      ggplot2::scale_linetype_manual(
        labels = c("White", treatment)
        , values = c(
          "solid"
          , "dashed"
        )
      )
    } else {
      df_pred_prob <- marginaleffects::plot_predictions(
        model = fitted_model
        , condition = c("pid_7", x_axis)
        , conf_level = level
      )
      if (treatment == "Red") {
        df_pred_prob <- df_pred_prob +
          ggplot2::scale_fill_manual(
            labels = c(
              "White"
              , treatment
            )
            , values = c(
              '#808080'
              , color_values[[3]][[1]]
            )
          )
      } else {
        df_pred_prob <- df_pred_prob +
          ggplot2::scale_fill_manual(
            labels = c(
              "White"
              , treatment
            )
            , values = c(
              '#808080'
              , color_values[[1]][[1]]
            )
          )
      }
    }
    plot <- df_pred_prob +
      #** define the line color for the plot
      ggplot2::scale_color_manual(
          labels = c(
            "White"
            , treatment
          )
          , values = c(
            "#000000"
            , "#000000"
          )
        ) +
      #** add some custom x-axis tick labels
      ggplot2::scale_x_continuous(
        breaks = c(-3, 0, 3)
        , labels = c(
          "Strong Democrat"
          , "Independent"
          , "Strong Republican"
        )
      ) +
      #** add some axis and legend labels
      ggplot2::labs(
        x = x_label
        , y = y_label
        , color = legend_title
        , fill = legend_title
        , linetype = legend_title
      ) +
      #** use the minimal theme
      ggplot2::theme_minimal()
  }
      #** Add some custom plot stuff depending on treatment
#    if (treatment == "Red") {
#        #*** if red treatment, make the ribbon red
#      plot <- df_pred_prob +
#        ggplot2::scale_fill_manual(
#          labels = c(
#            "White"
#            , treatment
#          )
#          , values = c(
#            color_values[[2]][[1]]
#            , color_values[[3]][[1]]
#          )
#        ) +
#        ggplot2::scale_linetype_manual(
#          labels = c(
#            "White"
#            , treatment
#          )
#          , values = c(
#            color_values[[2]][[2]]
#            , color_values[[3]][[2]]
#          )
#        )
#    } else {
#        #*** if blue treatment, make the ribbon blue
#      plot <- df_pred_prob +
#        ggplot2::scale_fill_manual(
#          labels = c(
#            "White"
#            , treatment
#          )
#          , values = c(
#            color_values[[2]][[1]]
#            , color_values[[1]][[1]]
#          )
#        ) +
#        ggplot2::scale_linetype_manual(
#          labels = c(
#            "White"
#            , treatment
#          )
#          , values = c(
#            color_values[[2]][[2]]
#            , color_values[[1]][[2]]
#          )
#        )
#    }
  # Return the plot
  return(plot)
}