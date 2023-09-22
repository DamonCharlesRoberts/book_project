# Title: Chapter 2 pre-test eda

# Notes:
    #* Description:
        #** Exploratory data analysis for chapter 2 pre-test
    #* Updated:
        #** 2023-03-15
        #** by: dcr 

# Setup
    #* set working directory
#setwd("./chapter_2/code/prr")
    #* Modularly load functions
box::use(
    modelsummary[
        datasummary_skim,
        datasummary_crosstab
    ],
    ggplot2[
        ggplot,
        geom_bar,
        aes,
        labs,
        theme_minimal,
        scale_fill_manual
    ]
)
    #* Source cleaning script
source("./pre-test/01_pre-test_cleaning.R")

# Univariate EDA
    #* Make table
data_summary_table <- data[["clean"]][ # select the following columns
    , .(Female, White, age, PartyId, BlueTreatment, RedTreatment, Vote)
] |>
datasummary_skim( # make a table of descriptive statistics
    notes = c( # add some notes to the table
        "Data source: Pre-test experiment.",
        '"Unique" column includes missing values.'
    )
)

# Bivariate EDA
    #* Party as DV
        #** Plots
            #*** Red treatment
red_party_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar( # make a bar plot
    aes(
        x = PartyCat, # with this variable on the x-axis
        fill = RedTreatmentCat # change color of bars based on values of this variable
    ),
    position ="dodge" # and put them next to each other
) +
theme_minimal() + # apply this theme
scale_fill_manual( # manually choose colors based on fill variable values
    values = c("#D3D3D3", "#8F2727")
) +
labs( # add some labels
    x = "Assumed party",
    y = "Count",
    fill = "Red treatment?",
    caption = "Data source: Pre-treatment.\n Perceptions of candidate party based on yard sign in treatment."
)
            #*** blue treatment
blue_party_bivariate <- ggplot( # make a plot
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = PartyCat, # put this variable on the x axis
        fill = BlueTreatmentCat # change color of bars based on values of this variable
    ),
    position = "dodge" # and put them next to each other
) +
theme_minimal() + # apply this theme
scale_fill_manual( # manually choose colors based on fill variable values
    values = c("#D3D3D3", "#8F2727")
) +
labs( # add some labels
    x = "Assumed party",
    y = "Count",
    fill = "Blue Treatment?",
    caption = "Data source: Pre-treatment.\n Perceptions of candidate party based on yard sign in treatment."
)
            #*** white treatment
white_party_bivariate <- ggplot( # make a plot
    data = data[["clean"]]
) +
geom_bar( # specifically a bar plot
    aes(
        x = PartyCat, # put this variable on the x axis
        fill = WhiteTreatmentCat # change color of bars based on values of this variable
    ),
    position = "dodge" # and put them next to each other
) +
theme_minimal() + # apply this theme
scale_fill_manual( # manually choose colors based on fill variable values
    values = c("#D3D3D3", "#8F2727")
) +
labs( # add some labels
    x = "Assumed party",
    y = "Count",
    fill = "White Treatment?",
    caption = "Data source: Pre-treatment.\n Perceptions of candidate party based on yard sign in treatment."
)
        #** Crosstabs
            #*** red treatment
red_party_xtab <- datasummary_crosstab( # make a crosstab
    RedTreatmentCat ~ PartyCat, # with these variables left ~ top
    data = data[["clean"]]
)
            #*** blue treatment
blue_party_xtab <- datasummary_crosstab( # make a crosstab
    BlueTreatmentCat ~ PartyCat, # with these variables left ~ top
    data = data[["clean"]]
)
            #*** white treatment
white_party_xtab <- datasummary_crosstab( # make a crosstab
    WhiteTreatmentCat ~ PartyCat, # with these variables left ~ top
    data = data[["clean"]]
)
    #** Vote intention as DV
        #** Plots
            #*** red treatment
red_vote_bivariate <- ggplot( # make a plot
    data = data[["clean"]]
) +
geom_bar( # specifically a bar plot
    aes(
        x = VoteCat, # put this variable on the x axis
        fill = RedTreatmentCat # fill the color of the bars based on the values of this variable
    ),
    position ="dodge" # put the bars next to each other
) +
theme_minimal() + # apply this theme
scale_fill_manual( # specify the colors for the bars
    values = c("#D3D3D3", "#8F2727")
) +
labs( # add labels
    x = "Vote?",
    y = "Count",
    fill = "Red treatment?",
    caption = "Data source: Pre-treatment.\n Willingness to cast vote based on yard sign in treatment."
)
            #*** blue treatment
blue_vote_bivariate <- ggplot( # make a plot
    data = data[["clean"]]
) +
geom_bar( # specifically a bar plot
    aes(
        x = VoteCat, # put this variable on the x axis
        fill = BlueTreatmentCat # fill the color of the bars based on the values of this variable
    ),
    position = "dodge" # put the bars next to each other
) +
theme_minimal() + # apply this theme
scale_fill_manual( # specify the colors for the bars
    values = c("#D3D3D3", "#8F2727")
) +
labs( # add labels
    x = "Vote?",
    y = "Count",
    fill = "Blue Treatment?",
    caption = "Data source: Pre-treatment.\n Willingness to cast vote based on yard sign in treatment."
)
            #*** white treatment
white_vote_bivariate <- ggplot( # create a plot
    data = data[["clean"]]
) +
geom_bar( # specifically a bar plot
    aes(
        x = VoteCat, # put this variable on the x-axis
        fill = WhiteTreatmentCat # fill the color of the bars based on the values of this variable
    ),
    position = "dodge" # put the bars next to each other
) +
theme_minimal() + # apply this theme
scale_fill_manual( # specify the colors for the bars
    values = c("#D3D3D3", "#8F2727")
) +
labs( # add labels
    x = "Vote?",
    y = "Count",
    fill = "White Treatment?",
    caption = "Data source: Pre-treatment.\n Willingness to cast vote based on yard sign in treatment."
)
        #** Crosstabs
            #*** red treatment
red_vote_xtab <- datasummary_crosstab( # make a crosstab
    RedTreatmentCat ~ VoteCat, # with these variables Left ~ Top
    data = data[["clean"]]
)
            #*** blue treatment
blue_vote_xtab <- datasummary_crosstab( # make a crosstab
    BlueTreatmentCat ~ VoteCat, # with these variables Left ~ Top
    data = data[["clean"]]
)
            #*** white treatment
white_vote_xtab <- datasummary_crosstab( # make a crosstab
    WhiteTreatmentCat ~ VoteCat, # with these variables Left ~ Top
    data = data[["clean"]]
)