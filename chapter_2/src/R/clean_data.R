#' @title stimuli extractor
#' 
#' @description
#' This is a function that extracts information about what stimuli was used
#' for the mouseview trials.
#' 
#' @details
#' This function takes a data.table object from the raw csv loading.
#' It takes the tasks column, takes the stimulus column,
#' and parses out the information to then return a named list of strings
#' with the information about whether the treatment was Red, Blue, or White
#' and which trial that was.
#' 
#' @param data_frame A data.table object containing data from the raw csv
#' 
#' @return list_str A named list of which trial and which stimulus was used.
#' 
#' @examples
#' 
stimuli_extractor <- function(data_frame = df_stimuli) {
  # Make a list of trials recorded (not all trials for folks who skipped)
    #* Initial list
  list_trials <- data_frame[["task"]] |> # find the task column
    as.list() # and record the trials as a list
    #* Take the list of trials and put it in the format of trial_#_stimulus
  list_trials <- base::lapply(
    list_trials
    , FUN = function(x) {
      shortened <- gsub(" ", "_", x)
      specific <- paste(shortened, "_stimulus", sep = "")
    }
  )
  # Take the data frame, find the stimulus column and record whether it was
  # red, white, or blue
  list_str <- base::apply(
    data_frame
    , 1
    , function(x) {
      # Grab the cell for the correct trial
      str <- x["stimulus"]
      # Then change the character to Red, White, or Blue 
      # depending on stimuli filename
      if (base::grepl("rep", str) == TRUE) {
        str <- "Red"
      } else if (base::grepl("cont", str) == TRUE) {
        str <- "White"
      } else if (base::grepl("dem", str) == TRUE) {
        str <- "Blue"
      } else {
        str <- "NULL"
      }
      # Return updated str
      return(str)
    }
  ) |>
  base::as.list() # covert this to a list
  # Add names to the list based off of the trial
  base::names(list_str) <- list_trials
  # Return list
  return(list_str)
}

#' @title mouseview data handler
#' 
#' @description
#' This is a function that takes the data reported from mouseview
#' converts it to a vector, takes the absolute difference between
#' positions on that vector, and then calculates the average
#' movement for that vector.
#' 
#' @details
#' The mouseview data comes in as an array but stored as character
#' form when initially loaded in from CSV. This function splits up
#' the array, converts it all to numerics, takes the difference between
#' values in the array, and then calculates the average. This gives
#' a average movement across the x and y axis. For recording of time,
#' it records the average amount of time taken between movements.
#' It does this for each trial and records which trial this happened for.
#' 
#' @param data_frame A data.table object that is essentially from
#' the raw csv.
#' @param var A string indicating which column to perform this on.
#' 
#' @return list_num A mean value of movement on that particular axis.
#' 
#' @examples
#' 
mouseview_handler <- function(data_frame = df_mouseview, var) {
  # Make a list of the trials recorded (not three for everyone)
    #* Take the trials from the task column.
  list_trials <- data_frame$task |> 
    as.list() # and store it as a list
    #* Take the list of trials and standardize it
    #* in the format of trial_#_difference
  list_trials <- base::lapply(
    list_trials
    , FUN = function(x) {
      shortened <- gsub(" ", "_", x)
      specific <- paste(shortened, "_difference", "_", var, sep = "")
    }
  )
  # Clean the mouseview cursor data and store in list
  list_num <- base::lapply(
    # Grab the data_frame at the specified column
    data_frame[[var]]
    , function(x) {
      num <- x |> # grab the first to third trial data
        data.table::tstrsplit(split = ",") |> # split the character column into a list
        base::unlist() |> # unlist it to make it a vector
        base::as.numeric() |> # convert the elements into numerics
        base::diff() |> # take the difference between the numbers
        base::abs() |> # take the absolute difference of it
        base::mean(na.rm = TRUE) # calculate the mean value


      # return num
      return(num)
    }
  )
  # Take the list of mouseview data, and name it with trial it was from
  names(list_num) <- list_trials
  # return list_num
  return(list_num)
} 

#' @title clean a csv
#' 
#' @description
#' This function takes a single csv file from study 1
#' and cleans it to work in a data.table object.
#' 
#' @details
#' Holy shit was this hard. Okay, so it is doing a lot of things
#' and does it partially because it has to do a whole lot of error catching.
#' The data from the raw csv's are not standardized at all.
#' e.g. if there is no data recorded for the participant, then there is nothing
#' for that variable. This made things more complicated than if it were marked
#' but left empty or given some default NULL value. It wasn't though. The data
#' are stored in a long format. Most of the data that I cared about was
#' put into one column called responses, and was a character string
#' meshed with the variable name. It has to separate that out,
#' transpose that dataset into wide format, and then merge in mouseview
#' and stimuli data, along with participant and submission id information.
#' But the aforementioned issue made this process more complicated.
#' 
#' @param df_temp A data.table object that is passed by the clean_data wrapper
#' function
#' 
#' @return df_clean A data.table object with the extracted data from the csv
#' 
#' @examples
#' 
extract_file <- function(df_temp) {
  # Make sure the passed data frame is a data.table object
  df_dirty <- df_temp |>
  data.table::as.data.table() # convert it to data.table
  # Extract participant_id from one of the cells
  participant_id <- df_dirty[
    , .(subject_id)
  ][1]
  # Extract submission_id from one of the cells
  submission_id <- df_dirty[
    , .(session_id)
  ][1]
  # Extract mouseview data
    #* First determine whether there is a row in trial_type
    #* for Mouseview. If not, means participant didn't participate
    #* and I'll need to make a named list with NA's as values instead
  df_mouseview <- df_dirty[
    trial_type == "Mouseview-Stop"
  ]
    #* If they did at least one of the mouseview trials 
    #* (the mouseview_handler function handles those who did more than one but
    #* not necessarily three), then run the mouseview_handler function on each
    #* column (X, Y, and TIME)
    #* This will return 3 lists with 3 named elements each.
  if (nrow(df_mouseview) > 0){
    list_mouseview_x <- mouseview_handler(data_frame = df_mouseview, var = "X")
    list_mouseview_y <- mouseview_handler(data_frame = df_mouseview, var = "Y")
    list_mouseview_time <- mouseview_handler(data_frame = df_mouseview, var = "Time")
    #* If they didn't do any of the mouseview trials, then make a named
    #* list with NA values filled in.
  } else {
    list_mouseview_x <- list(trial_1_difference_X = NA, trial_2_difference_X = NA, trial_3_difference_X = NA)
    list_mouseview_y <- list(trial_1_difference_Y = NA, trial_2_difference_Y = NA, trial_3_difference_Y = NA)
    list_mouseview_time <- list(trial_1_difference_Time = NA, trial_2_difference_Time = NA, trial_3_difference_Time = NA)
  }
  # Extract stimulus data
    #* First determine whether there is a row in trial_type
    #* indicating that they saw a yard sign. If not, means participant
    #* didn't see any stimuli and I need to make a named list with NA's
    #* as values instead.
  df_stimuli <- df_dirty[
    trial_type == "image-button-response"
  ]
    #* If the participant saw at least one yard sign, then run
    #* the stimuli_extractor function on it. For those that got
    #* at least one but not necessarily all three, the stimuli_extractor
    #* function will handle that. This will return one list with 
    #* three named elements in it.
  if (nrow(df_stimuli) > 0) {
    list_trial_stimuli <- stimuli_extractor(data_frame = df_stimuli)
    #* For participants that didn't see at least one yard sign,
    #* then make a named list with NA values filled in instead.
  } else {
    list_trial_stimuli <- list(trial_1_stimulus = NA, trial_2_stimulus = NA, trial_3_stimulus = NA)
  }
  # Extract data on time taken between mouseview start and stop
  if ("task" %in% colnames(df_dirty)) {
    #* if it has a Mouseview-Start and Mouseview-Stop row
    df_time <- df_dirty[
        trial_type == "Mouseview-Start" | trial_type == "Mouseview-Stop", 
      ][
        #** take the difference between those rows per trial
      , start_stop_diff := time_elapsed - data.table::shift(time_elapsed), by = task
      ]
        #** keep the Mouseview_Stop row as that is what will record what elapsed
      df_time <- df_time[
        trial_type == "Mouseview-Stop"
      ]
    #* grab the names of the trials
    list_time_elapsed_names <- as.list(df_time$task)
      #** clean the names of the trials to be good column names
    list_time_elapsed_names <- base::lapply(
      list_time_elapsed_names
      , FUN = function(x) {
        shortened <- gsub(" ", "_", x)
        specific <- paste(shortened, "_time_elapsed", sep = "")
        return(specific)
      }
    )
      #* convert the rows into a list
    list_time_elapsed <- as.list(df_time$start_stop_diff)
      #* and name the list elements so that they can be column names later
    names(list_time_elapsed) <- list_time_elapsed_names
  } else {
      #* if there isn't anything recording a task, just make an empty list and move on
    list_time_elapsed <- list(trial_1_time_elapsed = NA, trial_2_time_elapsed = NA, trial_3_time_elapsed = NA)
  }
  # Have all the data, now time to organize it
    #* Need to make a standardized data.frame listing all of the variables.
    #* Still documented as rows in the variable column. 
    #* Made a data.frame that has all of the possible variables they could
    #* have responded to (excluding mouseview and prolific stuff).
  df_full <- data.table::data.table(
    variable = c(
      "age"
        , "gender_id"
        , "sex"
        , "race_id"
        , "color_blind"
        , "attention"
        , "pid_3"
        , "pid_d_str"
        , "pid_r_str"
        , "ind_lean"
        , "attn_chk_1"
        , "trial_1_party"
        , "trial_2_party"
        , "trial_3_party"
        , "vote"
    )
  )
    #* If there is a response column in the raw csv file, then I need to parse
    #* the data out. Specifically, I need to take the column from something like
    #* this: {"age": "20"} and put it into two columns (variable, and responses)
  if ("response" %in% colnames(df_dirty)) {
      #** Grab the raw data and select the response, trial_type, and task columns
    df_responses <- df_dirty[
      , c("response", "trial_type", "task")
    ][
      #** if trial_type indicates they responded to a survey question,
      #** then grab those rows
      trial_type == "survey-multi-choice" | trial_type == "survey-multi-select" | trial_type == "survey-text",
    ][
      #** Get rid of {, ", and } characters in the response column
      , response := base::gsub('\\{|\\"|\\}', '', response)
    ][
      #** Now, split the response column by the colon
      #** and grab the first bit of that and store it in 
      #** a new column called variable
      , variable := data.table::tstrsplit(response, split = ":", fill = NA, fixed = TRUE)[1]
    ][
      #** Split the response column again, but this time
      #** grab the second element of that and store it in
      #** the response column.
      #** Couldn't find a way to get these two tasks to happen
      #** together by doing .(variable, response) without 
      #** data.table throwing errors at me...
      , response := data.table::tstrsplit(response, split = ":", fill = NA, fixed = TRUE)[2]
    ]
      #** Once I have done that, I need to rename a couple of things.
      #** All responses to the question of perception of candidate's
      #** party id are marked as Q0. Well, that isn't great. So let's
      #** mark it with the trial it is from instead. So, for the rows
      #** that are marked as Q0, I can leverage the task column and record
      #** the trial that was there to come up with a more informative name.
    df_responses <- df_responses[
      , variable := data.table::fcase(
        df_responses$variable == "Q0" & df_responses$task == "trial 1", "trial_1_party"
        , df_responses$variable == "Q0" & df_responses$task == "trial 2", "trial_2_party"
        , df_responses$variable == "Q0" & df_responses$task == "trial 3", "trial_3_party"
        , df_responses$variable != "Q0", df_responses$variable
      )
    ]
      #** Now left_join this with the df_full dataset. I do this because some
      #** people participated fully or in many ways but there are some
      #** bits of data I didn't fully get. This merge makes sure that
      #** the variable column is fully filled out with all possible varialbes
      #** and just fills in NA's for people that didn't answer that particular
      #** question.
    df_responses_full <- merge(df_full, df_responses, by = "variable", all.x = TRUE)
      #** For the people that didn't answer any questions (there were some)
      #** just fill it out with the df_full dataset and add empty bits for
      #** response and task
  } else {
    df_responses_full <- df_full[
      , response := NA
    ][
      , task := NA
    ]
  }
    #* Now that I've done this, let's take that variable column
    #* and convert the rows into column names by transposing it.
    #* I'm going to select the first row, cause it keeps some junk
    #* I don't need in other rows while I am at it. 
  df_responses_transpose <- data.table::transpose(
    df_responses_full
    , make.names = "variable"
  )[1]
    #* Take the transposed data.frame and start adding in some of the
    #* other bits of data.
      #** Add the named list of mouseview data for the x-axis.
      #** I don't specify column names here, it'll just use
      #** the name index from the list. Have to do it with
      #** setDT and build on an existing dataframe with the names of the 
      #** existing data.frame.
  df_clean_x <- df_responses_transpose[
    , data.table::setDT(list_mouseview_x)
    , by = names(df_responses_transpose)
  ]
      #** Add the named list of mouseview data for the y-axis.
      #** I don't specify column names here, it'll just use
      #** the name index from the list. Have to do it with
      #** setDT and build on an existing dataframe with the names of the 
      #** existing data.frame.
  df_clean_y <- df_clean_x[
    , data.table::setDT(list_mouseview_y)
    , by = names(df_clean_x)
  ]
      #** Add the named list of mouseview data for the time data.
      #** I don't specify column names here, it'll just use
      #** the name index from the list. Have to do it with
      #** setDT and build on an existing dataframe with the names of the 
      #** existing data.frame.
  df_clean_time <- df_clean_y[
    , data.table::setDT(list_mouseview_time)
    , by = names(df_clean_y)
  ]
      #** Add the named list of mouseview data for the total elapsed time.
      #** I don't specify colum names here, it'll just use
      #** the name index from the list. Have to do it with 
      #** setDT and build on an existing dataframe with the names of the
      #** existing data.frame.
  df_clean_time_elapsed <- df_clean_time[
    , data.table::setDT(list_time_elapsed)
    , by = names(df_clean_time)
  ]
      #** Add the named list of mouseview data for the stimuli.
      #** I don't specify column names here, it'll just use
      #** the name index from the list. Have to do it with
      #** setDT and build on an existing dataframe with the names of the 
      #** existing data.frame. Also, add in the participant_id and
      #** submission_id info while I am at it. This will help with merging
      #** the prolific demographic data in with it later.
  df_clean <- df_clean_time_elapsed[
    , data.table::setDT(list_trial_stimuli)
    , by = names(df_clean_time_elapsed)
  ][
    , participant_id := participant_id
  ][
    , submission_id := submission_id
  ]
  # return the clean dataset
  return(df_clean)
}

#' @title clean data
#' 
#' @description
#' This is a function that takes the extract_file function and applies
#' it to a whole directory of csv files
#' 
#' @details
#' This is the pentultimate, wrapper, function for the cleaning. This function
#' reads the csv's in, pulls them in as a data.frame, then recursively passes
#' them into the extract_file function.
#' 
#' @param folder A string indicating a directory path.
#' 
#' @returns df_return A data.table object with a cleaned dataset in wide format.
#' 
#' @examples
#'
clean_data <- function(
  folder
  , prolific_data) {
    # Read all of the csv files
      #* Get a list of file names for the csv's; the full paths.
    list_filenames <- base::list.files(
        path = folder
        , full.names = TRUE
    ) |>
    base::as.list()
    # Recursively load the csv files.
    #* and store them as a list of data.frames.
    list_pavlovia_data <- base::lapply(
        list_filenames
        , FUN = utils::read.csv
    )
    # Recursively go through the csv files and clean them.
    list_dataframes <- base::lapply(
        list_pavlovia_data
        , FUN = extract_file
    )
    # Collapse the list of cleaned dataframes into one dataframe
    df_clean <- data.table::rbindlist(
      list_dataframes
      , fill = TRUE
    )
    # Merge with the prolific data
    df_prolific <- utils::read.csv(
      file = prolific_data
    )
    df_merged <- base::merge(
      df_clean
      , df_prolific
      , by.x = c("submission_id", "participant_id")
      , by.y = c("Submission.id", "Participant.id")
    )
    # Store the resulting data.frame in a csv
    utils::write.csv(
      df_merged
      , file = "../data/clean/extracted_pavlovia.csv"
    )
    # Remove duplicated rows (from participants starting and restarting)
    df_cleaned <- base::unique(df_merged, by = "submission_id")
    # Return dataframe
    return(df_cleaned)
}