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
predicted_prob_bar <- function(
  fitted_model
  , x_axis
  , treatment = "Red"
  , hypothesis = "H2"
  , level = 0.90
  , x_label = "Color of yard sign"
  , y_label = "Pr(Party of candidate)"
  , legend_title = "Party of candidate"
) {
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
      , .(
        estimate = mean(estimate)
        , conf.low = mean(conf.low)
        , conf.high = mean(conf.high)
      )
      #** this needs to be done by the group column and the
      #** independent variable
      , by = c(
        "group"
        , x_axis
      )
    ][
      #** convert the x-axis to a factor
      , x_axis_temp := factor(get(x_axis))
    ][
      #** convert the group column to a factor
      , group := factor(group)
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
          x = x_axis_temp
          , y = estimate
          , fill = group
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
          , ymin = conf.low
          , ymax = conf.high
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
      #* Change the fill colors to blue, white, and red whle labeling it
      ) +
      ggplot2::scale_fill_manual(
        labels = c(
          "Democrat"
          , "Independent"
          , "Republican"
        )
        , values = c(
          "#00AEF3"
          , "#ffffff"
          , "#ff0803"
        )
      )  +
      #* change the labels and linetype for the outcomes
      ggplot2::scale_linetype_manual(
        labels = c(
          "Democrat"
          , "Independent"
          , "Republican"
        )
        , values = c(
          "solid"
          , "solid"
          , "solid"
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
        , year = c(
          2018, 2020, 2022
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
        x = dem_vote_share
        , y = draw
      )
    ) +
      #** plot the change in predicted values
    tidybayes::stat_lineribbon(
      .width = level
      , alpha = 0.6
    ) +
      #** split this up by year
    ggplot2::facet_wrap(
      ~ year
      , ncol = 2
    ) +
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
        values = "#ff0803"
      ) +
      ggplot2::labs(
        x = "Democratic party vote share"
        , y = "Predicted proportion of red"
      )
    } else {
      plot <- plot +
      ggplot2::scale_fill_manual(
        values = "#00AEF3"
      ) +
      ggplot2::labs(
        x = "Democratic party vote share"
        , y = "Predicted proportion of blue"
      )

    }
  # If it is a logistic regression with binary outcome
  } else {
      #* Calculate the predicted probabilities of voting for the candidate
    df_pred_prob <- marginaleffects::plot_predictions(
      model = fitted_model
      , condition = c("pid_7", x_axis)
    ) +
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
      ) +
      #** use the minimal theme
      ggplot2::theme_minimal()
      #** Add some custom plot stuff depending on treatment
    if (treatment == "Red") {
        #*** if red treatment, make the ribbon red
      plot <- df_pred_prob + 
        ggplot2::scale_fill_manual(
          labels = c(
            "White"
            , "Red"
          )
          , values = c(
            "#808080"
            , "#ff0803"
          )
        )
    } else {
        #*** if blue treatment, make the ribbon blue
      plot <- df_pred_prob +
        ggplot2::scale_fill_manual(
          labels = c(
            "White"
            , "Blue"
          )
          , values = c(
            "#808080"
            , "#00AEF3"
          )
        )
    }
  }
  # Return the plot
  return(plot)
}