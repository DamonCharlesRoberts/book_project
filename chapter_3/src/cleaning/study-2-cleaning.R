# Study 2 Cleaning

# Notes
# *     Description
# **        Script for the cleaning of study 2 data.

# Load modules
box::use(
    DBI[dbConnect, dbExecute],
    duckdb[duckdb]
)

# Connect to db
con <- dbConnect(duckdb(), dbdir = "./chapter_3/data/clean/study-2.db")

# Cleaning
dbExecute(
    con,
    "
    CREATE OR REPLACE VIEW
        CleanTemp
    AS
    SELECT
        /* Participant ID */
        Q22 AS part_id,
        /* 
            age 
                Not changed
        */
        \"age.\" AS age,
        /*
            female
                sex - Male, Female
                0 - Male
                1 - Female
        */
        (
            CASE
                WHEN \"sex.\" == 'Male' THEN 0
                WHEN \"sex.\" == 'Female' THEN 1
                ELSE NULL
            END
        ) AS female,
        /*
            education
                education - Did not complete high school, HS Diploma, Some college, 2-year degree, Bachelor's degree, post-graduate or professional degree
                1 - Did not complete high school
                2 - High school diploma
                3 - Some college, no degree
                4 - 2-year degree
                5 - Bachelor's degree
                6 - Post-graduate or professional degree
        */
        (
            CASE
                WHEN education == 'Did not complete high school' THEN 1
                WHEN education == 'High school diploma' THEN 2
                WHEN education == 'Some college, no degree' THEN 3
                WHEN education == '2-year degree' THEN 4
                WHEN education LIKE 'Bachelor%s degree' THEN 5
                WHEN education == 'Post-graduate or professional degree' THEN 6
                ELSE NULL
            END
        ) AS education,
        /*
            white
                race - White, Black or African American, Hispanic or latino, Asian or Asian-American, Native American, Middle Eastern, Two or more races, other
                0 - Other
                1 - White
        */
        (
            CASE
                WHEN \"race.\" == 'White' THEN 1
                WHEN \"race.\" != 'White' THEN 0
                ELSE NULL
            END
        ) AS white,
        /*
            pid7
                1 = Strong Democrat
                2 = Not very strong Democrat
                3 = Lean Democrat
                4 = Independent
                5 = Lean Republican
                6 = Not very strong Republican
                7 = Strong Republican
        */
        (
            CASE
                WHEN \"pid_d.\" == 'Strong Democrat' THEN 1
                WHEN \"pid_d.\" == 'Not very strong Democrat' THEN 2
                WHEN \"pid_i.\" == 'The Democratic Party' THEN 3
                WHEN \"pid_i.\" == 'Neither' THEN 4
                WHEN \"pid_i.\" == 'The Republican Party' THEN 5
                WHEN \"pid_r\" == 'Not very strong Republican' THEN 6
                WHEN \"pid_r\" == 'Strong Republican' THEN 7
                ELSE NULL
            END
        ) AS pid7,
        /*
            attention - Always, Most of the time, About half of the time, Some of the time, Never
            1 = Never
            2 = Some of the time
            3 = About half of the time
            4 = Most of the time
            5 = Always
        */
        (
            CASE
                WHEN \"attention.\" == 'Never' THEN 1
                WHEN \"attention.\" == 'Some of the time' THEN 2
                WHEN \"attention.\" == 'About half of the time' THEN 3
                WHEN \"attention.\" == 'Most of the time' THEN 4
                WHEN \"attention.\" == 'Always' THEN 5
                ELSE NULL
            END
        ) AS attention,
        /*
            EnjoyChallenge - I enjoy challenging the opinions of others.
            1 = Strongly disagree
            2 = Disagree
            3 = Neither agree nor disagree
            4 = Agree
            5 = Strongly agree
        */
        (
            CASE
                WHEN \"conflict_avoidance._1\" == 'Strongly disagree' THEN 1
                WHEN \"conflict_avoidance._1\" == 'Disagree' THEN 2
                WHEN \"conflict_avoidance._1\" == 'Neither agree nor disagree' THEN 3
                WHEN \"conflict_avoidance._1\" == 'Agree' THEN 4
                WHEN \"conflict_avoidance._1\" == 'Strongly agree' THEN 5
                ELSE NULL
            END
        ) AS EnjoyChallenge,
        /*
            DislikeArgue - I dislike arguing about politics
            1 = Strongly disagree
            2 = Disagree
            3 = Neither agree nor disagree
            4 = Agree
            5 = Strongly agree
        */
        (
            CASE
                WHEN \"conflict_avoidance._2\" == 'Strongly disagree' THEN 1
                WHEN \"conflict_avoidance._2\" == 'Disagree' THEN 2
                WHEN \"conflict_avoidance._2\" == 'Neither agree nor disagree' THEN 3
                WHEN \"conflict_avoidance._2\" == 'Agree' THEN 4
                WHEN \"conflict_avoidance._2\" == 'Strongly agree' THEN 5
                ELSE NULL
            END
        ) AS DislikeArgue,
        /*
            BlueTreatment
            0 = treatment_red_align | treatment_red_not
            1 = treat_blue_align | treatment_blue_not
        */
        (
            CASE
                WHEN \"treatment_red_align._1\" != '' OR \"treatment_red_align._2\" != '' OR \"treatment_red_align._3\" != '' THEN 0
                WHEN \"treatment_red_not._1\" != '' OR \"treatment_red_not._2\" != '' OR \"treatment_red_not._3\" != '' THEN 0
                WHEN \"treat_blue_align._1\" != '' OR \"treat_blue_align._2\" != '' OR \"treat_blue_align._3\" != '' THEN 1
                WHEN \"treatment_blue_not._1\" != '' OR \"treatment_blue_not._2\" != '' OR \"treatment_blue_not._3\" != '' THEN 1
                ELSE NULL
            END
        ) AS BlueTreatment,
        /*
            AlignTreatment
            0 = treatment_red_not | treatment_blue_not
            1 = treatment_red_align | treat_blue_align
        */
        (
            CASE
                WHEN \"treatment_red_not._1\" != '' OR \"treatment_red_not._2\" != '' OR \"treatment_red_not._3\" != '' THEN 0
                WHEN \"treatment_blue_not._1\" != '' OR \"treatment_blue_not._2\" != '' OR \"treatment_blue_not._3\" != '' THEN 0
                WHEN \"treatment_red_align._1\" != '' OR \"treatment_red_align._2\" != '' OR \"treatment_red_align._3\" != '' THEN 1
                WHEN \"treat_blue_align._1\" != '' OR \"treat_blue_align._2\" != '' OR \"treat_blue_align._3\" != '' THEN 1
                ELSE NULL
            END
        ) AS AlignTreatment,
        /*
            WillingConversation - I am willing to have a conversation with this person.
            1 = Strongly disagree
            2 = Disagree
            3 = Neither agree nor disagree
            4 = Agree
            5 = Strongly agree
        */
        (
            CASE
                WHEN \"treatment_red_not._1\" == 'Strongly disagree' OR \"treatment_red_align._1\" == 'Strongly disagree' OR \"treatment_blue_not._1\" == 'Strongly disagree' OR \"treat_blue_align._1\" == 'Strongly disagree' THEN 1
                WHEN \"treatment_red_not._1\" == 'Disagree' OR \"treatment_red_align._1\" == 'Disagree' OR \"treatment_blue_not._1\" == 'Disagree' OR \"treat_blue_align._1\" == 'Disagree' THEN 2
                WHEN \"treatment_red_not._1\" == 'Neither agree nor disagree' OR \"treatment_red_align._1\" == 'Neither agree nor disagree' OR \"treatment_blue_not._1\" == 'Neither agree nor disagree' OR \"treat_blue_align._1\" == 'Neither agree nor disagree' THEN 3
                WHEN \"treatment_red_not._1\" == 'Agree' OR \"treatment_red_align._1\" == 'Agree' OR \"treatment_blue_not._1\" == 'Agree' OR \"treat_blue_align._1\" == 'Agree' THEN 4
                WHEN \"treatment_red_not._1\" == 'Strongly agree' OR \"treatment_red_align._1\" == 'Strongly agree' OR \"treatment_blue_not._1\" == 'Strongly agree' OR \"treat_blue_align._1\" == 'Strongly agree' THEN 5
                ELSE NULL
            END
        ) AS WillingConversation,
        /*
            InitiateConversation - I can see myself initiating the conversation with this person.
            1 = Strongly disagree
            2 = Disagree
            3 = Neither agree nor disagree
            4 = Agree
            5 = Strongly agree
        */
        (
            CASE
                WHEN \"treatment_red_not._2\" == 'Strongly disagree' OR \"treatment_red_align._2\" == 'Strongly disagree' OR \"treatment_blue_not._2\" == 'Strongly disagree' OR \"treat_blue_align._2\" == 'Strongly disagree' THEN 1
                WHEN \"treatment_red_not._2\" == 'Disagree' OR \"treatment_red_align._2\" == 'Disagree' OR \"treatment_blue_not._2\" == 'Disagree' OR \"treat_blue_align._2\" == 'Disagree' THEN 2
                WHEN \"treatment_red_not._2\" == 'Neither agree nor disagree' OR \"treatment_red_align._2\" == 'Neither agree nor disagree' OR \"treatment_blue_not._2\" == 'Neither agree nor disagree' OR \"treat_blue_align._2\" == 'Neither agree nor disagree' THEN 3
                WHEN \"treatment_red_not._2\" == 'Agree' OR \"treatment_red_align._2\" == 'Agree' OR \"treatment_blue_not._2\" == 'Agree' OR \"treat_blue_align._2\" == 'Agree' THEN 4
                WHEN \"treatment_red_not._2\" == 'Strongly agree' OR \"treatment_red_align._2\" == 'Strongly agree' OR \"treatment_blue_not._2\" == 'Strongly agree' OR \"treat_blue_align._2\" == 'Strongly agree' THEN 5
                ELSE NULL
            END
        ) AS InitiateConversation,
        /*
            AgreeConversation - I think I would agree about most things with this person.
            1 = Strongly disagree
            2 = Disagree
            3 = Neither agree nor disagree
            4 = Agree
            5 = Strongly agree
        */
        (
            CASE
                WHEN \"treatment_red_not._3\" == 'Strongly disagree' OR \"treatment_red_align._3\" == 'Strongly disagree' OR \"treatment_blue_not._3\" == 'Strongly disagree' OR \"treat_blue_align._3\" == 'Strongly disagree' THEN 1
                WHEN \"treatment_red_not._3\" == 'Disagree' OR \"treatment_red_align._3\" == 'Disagree' OR \"treatment_blue_not._3\" == 'Disagree' OR \"treat_blue_align._3\" == 'Disagree' THEN 2
                WHEN \"treatment_red_not._3\" == 'Neither agree nor disagree' OR \"treatment_red_align._3\" == 'Neither agree nor disagree' OR \"treatment_blue_not._3\" == 'Neither agree nor disagree' OR \"treat_blue_align._3\" == 'Neither agree nor disagree' THEN 3
                WHEN \"treatment_red_not._3\" == 'Agree' OR \"treatment_red_align._3\" == 'Agree' OR \"treatment_blue_not._3\" == 'Agree' OR \"treat_blue_align._3\" == 'Agree' THEN 4
                WHEN \"treatment_red_not._3\" == 'Strongly agree' OR \"treatment_red_align._3\" == 'Strongly agree' OR \"treatment_blue_not._3\" == 'Strongly agree' OR \"treat_blue_align._3\" == 'Strongly agree' THEN 5
                ELSE NULL
            END
        ) AS InitiateConversation,
        /*
            ShirtColor - What was the color of the shirt the avatar was wearing?
            1 = I am very certain it was red
            2 = I am fairly certain it was red
            3 = I am not sure
            4 = I am fairly certain it was blue
            5 = I am very certain it was blue
        */
        (
            CASE
                WHEN \"shirt_color\" == 'I am very certain it was red' OR \"shirt_color.\" == 'I am very certain it was red' OR \"shirt_color..1\" == 'I am very certain it was red' OR \"shirt_color..2\" == 'I am very certain it was red' THEN 1
                WHEN \"shirt_color\" == 'I am fairly certain it was red' OR \"shirt_color.\" == 'I am fairly certain it was red' OR \"shirt_color..1\" == 'I am fairly certain it was red' OR \"shirt_color..2\" == 'I am fairly certain it was red' THEN 2
                WHEN \"shirt_color\" == 'I am not sure' OR \"shirt_color.\" == 'I am not sure' OR \"shirt_color..1\" == 'I am not sure' OR \"shirt_color..2\" == 'I am not sure' THEN 3
                WHEN \"shirt_color\" == 'I am fairly certain it was blue' OR \"shirt_color.\" == 'I am fairly certain it was blue' OR \"shirt_color..1\" == 'I am fairly certain it was blue' OR \"shirt_color..2\" == 'I am fairly certain it was blue' THEN 4
                WHEN \"shirt_color\" == 'I am very certain it was blue' OR \"shirt_color.\" == 'I am very certain it was blue' OR \"shirt_color..1\" == 'I am very certain it was blue' OR \"shirt_color..2\" == 'I am very certain it was blue' THEN 5
                ELSE NULL
            END
        ) AS ShirtColor
    FROM
        Qualtrics;
    "
)

# Disconnect from the database
dbDisconnect(con, shutdown=TRUE)