# Study 1 Cleaning

# Notes
# *     Description
# **        Python script for the cleaning of the study 1 data.

# Load modules
box::use(
    DBI[dbConnect, dbExecute],
    duckdb[duckdb]
)

# Connect to db
con <- dbConnect(duckdb(), dbdir="./chapter_3/data/clean/study_1.db")

# Cleaning
dbExecute(
    con,
    "
    CREATE OR REPLACE VIEW
        CleanTemp
    AS
    SELECT
        /* CaseID */
        caseid,
        teamweight,
        /* 
            PoliticalPrime
                CUB3D01 - Version 1, 2, 3, 4
                0 - No political prime: Version 3, 4
                1 - Political prime: Version 1, 2
        */
        (
            CASE
                WHEN CUB3D01 <= 2 THEN 1
                WHEN CUB3D01 >= 3 THEN 0
                ELSE NULL
            END 
        ) AS PoliticalPrime,
        /*
            BlueShirt Treatment
            CUB3D01 - Version 1, 2, 3, 4
            0 - Red shirt: Version 2, 4
            1 - Blue shirt: Version 1, 3
        */
        (
            CASE
                WHEN CUB3D01 == 1 THEN 1
                WHEN CUB3D01 == 3 THEN 1
                WHEN CUB3D01 == 2 OR CUB3D01 == 4 THEN 0
                ELSE NULL
            END
        ) AS BlueShirt,
        /*
            ConversationAgree
            CUB3D02 - I am willing to have a conversation with this person
            1 - Strongly disagree: 5
            2 - Somewhat disagree: 4
            3 - Neither agree nor disagree: 3
            4 - Somewhat agree: 2
            5 - Strongly agree: 1
        */
        (
            CASE
                WHEN CUB3D02 == 5 THEN 1
                WHEN CUB3D02 == 4 THEN 2
                WHEN CUB3D02 == 3 THEN 3
                WHEN CUB3D02 == 2 THEN 4
                WHEN CUB3D02 == 1 THEN 5
                ELSE NULL
            END
        ) AS ConversationAgree,
        /*
            ViewsAgree
            CUB3D03 - I think I would agree about most things with this person
            1 - Strongly disagree: 5
            2 - Somewhat disagree: 4
            3 - Neither agree nor disagree: 3
            4 - Somewhat agree: 2
            5 - Strongly agree: 1
        */
        (
            CASE
                WHEN CUB3D03 == 5 THEN 1
                WHEN CUB3D03 == 4 THEN 2
                WHEN CUB3D03 == 3 THEN 3
                WHEN CUB3D03 == 2 THEN 4
                WHEN CUB3D03 == 1 THEN 5
                ELSE NULL
            END
        ) AS ViewsAgree,
        /*
            InitiateAgree
            CUB3D04 - I can see myself initiating the conversation with this person
            1 - Strongly disagree: 5
            2 - Somewhat disagree: 4
            3 - Neither agree nor disagree: 3
            4 - Somewhat agree: 2
            5 - Strongly agree: 1
        */
        (
            CASE
                WHEN CUB3D04 == 5 THEN 1
                WHEN CUB3D04 == 4 THEN 2
                WHEN CUB3D04 == 3 THEN 3
                WHEN CUB3D04 == 2 THEN 4
                WHEN CUB3D04 == 1 THEN 5
                ELSE NULL
            END
        ) AS InitiateAgree,
        /*
            DislikeArgue
            CUB3D05 - I dislike arguing about politics
            -2 - Strongly disagree: 5
            -1 - Somewhat disagree: 4
            0 - Neither agree nor disagree: 3
            1 - Somewhat agree: 2
            2 - Strongly agree: 1
        */
        (
            CASE
                WHEN CUB3D05 == 5 THEN -2
                WHEN CUB3D05 == 4 THEN -1
                WHEN CUB3D05 == 3 THEN 0
                WHEN CUB3D05 == 2 THEN 1
                WHEN CUB3D05 == 1 THEN 2
                ELSE NULL
            END
        ) AS DislikeArgue,
        /*
            Enjoy Challenge
            CUB3D06 - I enjoy challenging the opinions of others
            -2 - Strongly disagree: 5
            -1 - Somewhat disagree: 4
            0 - Neither agree nor disagree: 3
            1 - Somewhat agree: 2
            2 - Strongly agree: 1
        */
        (
            CASE
                WHEN CUB3D06 == 5 THEN -2
                WHEN CUB3D06 == 4 THEN -1
                WHEN CUB3D06 == 3 THEN 0
                WHEN CUB3D06 == 2 THEN 1
                WHEN CUB3D06 == 1 THEN 2
                ELSE NULL
            END
        ) AS EnjoyChallenge,
        /*
            CertainBlue
            CUB3D07 - What was the color of the shirt the avatar was wearing
            1: I am very certain it was red.
            2: I am fairly certain it was red.
            3: I am not sure.
            4: I am fairly certain it was blue.
            5: I am very certain it was blue.
        */
        CUB3D07 AS CertainBlue,
        /*
            Age
            birthyr - Birthyear
            2024-birthyr
        */
        (
            2024 - birthyr
        ) AS Age,
        /*
            Gender
            gender4 - Man, Woman, Non-Binary, Other
            1 - Man
            2 - Woman
            3 - Non-binary
            4 - Other
        */
        gender4 AS Gender,
        /*
            Education
            educ - No Hs, Hs Grad, Some college, 2-year, 4-year, post-grad
            1 - No HS
            2 - HS Grad
            3 - Some college
            4 - 2 year
            5 - 4 year
            6 - Post-grad
        */
        educ AS Education,
        /*
            White
            race - White, Black, Hispanic, Asian, Native American,
                2 or more, other, middle eastern
            0 - Not white
            1 - White
        */
        (
            CASE
                WHEN race == 1 THEN 1
                WHEN race > 1 THEN 0
                ELSE NULL
            END
        ) AS White,
        /*
            Dem3
            pid3 - Democrat, Republican, Independent, Other, Not sure
            -1 - Republican
            0 - Independent, Other, Not sure
            1 - Democrat
        */
        (
            CASE
                WHEN pid3 == 1 THEN 1
                WHEN pid3 == 2 THEN -1
                WHEN pid3 >= 3 THEN 0
                ELSE NULL
            END
        ) AS Dem3,
        /*
            Dem7
            pid7 - Strong Democrat, Not very strong Democrat, Lean Democrat
                Independent, Lean Republican, Not very strong Republican
                Strong Republican, Not Sure, Don't know
            -3 - Strong Republican
            -2 - Not very strong Republican
            -1 - Lean Republican
            0 - Independent, Not sure, Don't know
            1 - Lean Democrat
            2 - Not very strong Democrat
            3 - Strong Democrat
        */
        (
            CASE
                WHEN pid7 == 1 THEN 3
                WHEN pid7 == 2 THEN 2
                WHEN pid7 == 3 THEN 1
                WHEN pid7 == 4 OR pid7 >= 8 THEN 0
                WHEN pid7 == 5 THEN -1
                WHEN pid7 == 6 THEN -2
                WHEN pid7 == 7 THEN -3
                ELSE NULL
            END
        ) AS Dem7,
        /* 
            Attention - How often do you follow politics?
            newsint - Most of the time, some of the time, only now and then
                hardly at all, don't know
            0 - Hardly at all
            1 - Only now and then
            2 - Some of the time
            3 - Most of the time
        */
        (
            CASE
                WHEN newsint == 4 THEN 0
                WHEN newsint == 3 THEN 1
                WHEN newsint == 2 THEN 2
                WHEN newsint == 1 THEN 3
                ELSE NULL
            END
        ) AS Attention,
    FROM
        OriginalModule;
    "
)

dbExecute(
    con,
    "
    CREATE OR REPLACE TABLE
        Clean
    AS
        SELECT
            t.*,
            /*
                CorrectColor
                CertainBlue - What was the color of the shirt the avatar was wearing
                Null - Didn't notice
                0 - Not correct
                1 - Correct
            */
            (
                CASE
                    WHEN CertainBlue <= 2 AND BlueShirt == 0 THEN 1
                    WHEN CertainBlue <= 2 AND BlueShirt == 1 THEN 0
                    WHEN CertainBlue >= 4 AND BlueShirt == 1 THEN 1
                    WHEN CertainBlue >= 4 AND BlueShirt == 0 THEN 0
                    ELSE NULL
                END
            ) AS CorrectColor,
        FROM
            CleanTemp AS t;
    "
)

# Close the connection
dbDisconnect(con, shutdown=TRUE)