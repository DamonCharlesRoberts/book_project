# Title: CAPD detecting colors

# Notes: 
    #* Description: Script to detect the colors on the yard signs
    #* Updated: 2022-11-28
    #* Updated by: dcr

# Load modules
    #* From visual_env 
import duckdb # to access the database
import numpy as np # to wrangle arrays
import polars as pl # to wrangle dataFrames
import re # to wrangle strings
import cv2 # to do color detection
import os # to wrangle local files
    #* User defined
from PY.helper import names, colorDetector

# Connect to database

db = duckdb.connect('data/dissertation_database')

# Define colors to detect
    #* White
        #** Not defined. Default for colorDetector()
    #* Red
republican_red = [232, 27, 35] # target color
red_lower = [93, 9, 12] # lower end of spectrum for red
red_higher = [237, 69, 75] # higher end of spectrum for red
    #* Blue
democrat_blue = [0, 174, 243] # target color
blue_lower = [0, 18, 26] # lower end of spectrum for blue
blue_higher = [102, 212, 255] # higher end of spectrum for blue

# Detect colors
    #* Create an empty dataframe to store them in
df = pl.DataFrame({
                    "Last_Name": ["Test"],
                    "Year": ["2022"],
                    "White_Percent": [1.2],
                    "Blue_Percent": [1.2],
                    "Red_Percent": [1.2]
})

for filename in os.listdir("data/chapter_1/capd_yard_signs"):
    #* check to make sure the file is a png file
    if filename.endswith('.png'):
    #* join the directory to the file name
            f = os.path.join("data/chapter_1/capd_yard_signs", filename)
            print("read file")
    #* split the file name and store the information
            lastName, year, file = re.split(r'[_.]', filename)
            print("split file name")
    #* open the image's file
            #pil = Image.open(f).convert('RGB')
            #pilCv = np.array(pil)
            #img = pilCv[:,:,::-1].copy()
            img = cv2.imdecode(np.fromfile(f, dtype=np.uint8), cv2.IMREAD_COLOR)
            print("load file")
    #* calculate the percent of the image that is white
            whitePercent = colorDetector(img = img, color_lower = [255,255,255], color_upper = [255,255,255])
            print("calculated whitePercent")
    #* calculate the percent of the image that is blue
            bluePercent = colorDetector(img = img, color_upper = blue_higher, color_lower = blue_lower)
            print("calculated bluePercent")
    #* calculate the percent of the image that is red
            redPercent = colorDetector(img = img, color_upper = red_higher, color_lower = red_lower)
            print("calculated redPercent")
    #* store these things in a temporary dataframe
            tempDf = pl.DataFrame({
                                    "Last_Name":[lastName], 
                                    "Year":[year], 
                                    "White_Percent":[whitePercent],
                                    "Blue_Percent":[bluePercent],
                                    "Red_Percent":[redPercent]
                                    })
            print("stored in tempDf")
    #* append the temporary dataframe to the main dataframe
            df = pl.concat(
                [df,tempDf], rechunk = True
                ).filter(
                    pl.col("Last_Name") != "Test"
                )

# Merge this information to the yard_signs table

yard_signs = pl.from_arrow(
    #* grab the ch_1_capd_yard_signs table
    db.execute("SELECT * FROM ch_1_capd_yard_signs").fetch_arrow_table()
    ).with_column(
    #* Create Last_Name column from Candidate_Name
        names(pl.col("Candidate_Name")).alias("Last_Name")
    ).join(
    #* Left-join the yard_signs table to the df table by Last_Name and Year value
        df, on = ["Last_Name", "Year"], how = "left"
    ).to_arrow()

# Store data as new table

db.execute("CREATE OR REPLACE TABLE ch_1_capd_color_detected AS SELECT * FROM yard_signs")