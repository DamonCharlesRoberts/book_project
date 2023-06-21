# Title: CAPD detecting colors

# Notes: 
    #* Description: Script to detect the colors on the yard signs
    #* Updated: 2022-11-28
    #* Updated by: dcr

# Load modules
    #* From visual_env 
#import duckdb # to access the database
import numpy as np # to wrangle arrays
import polars as pl # to wrangle dataFrames
import re # to wrangle strings
import cv2 # to do color detection
import os # to wrangle local files
    #* User defined
from chapter_2.src.PY.helper import names, colorDetector

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
                    "last_name": ["Test"],
                    "year": ["2023"],
                    "white_percent": [1.2],
                    "blue_percent": [1.2],
                    "red_percent": [1.2]
})

for filename in os.listdir("./chapter_2/data/original/study_2/capd_yard_signs"):
    #* check to make sure the file is a png file
    if filename.endswith('.png'):
    #* join the directory to the file name
            f = os.path.join("./chapter_2/data/original/study_2/capd_yard_signs", filename)
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
            whitePercent, _, _ = colorDetector(img = img, color_lower = [255,255,255], color_upper = [255,255,255])
            print("calculated whitePercent")
    #* calculate the percent of the image that is blue
            bluePercent, _, _ = colorDetector(img = img, color_upper = blue_higher, color_lower = blue_lower)
            print("calculated bluePercent")
    #* calculate the percent of the image that is red
            redPercent, _, _ = colorDetector(img = img, color_upper = red_higher, color_lower = red_lower)
            print("calculated redPercent")
    #* store these things in a temporary dataframe
            tempDf = pl.DataFrame({
                                    "last_name":[lastName], 
                                    "year":[year], 
                                    "white_percent":[whitePercent],
                                    "blue_percent":[bluePercent],
                                    "red_percent":[redPercent]
                                    })
            print("stored in tempDf")
    #* append the temporary dataframe to the main dataframe
            df = pl.concat(
                [df,tempDf], rechunk = True
                ).filter(
                    pl.col("last_name") != "Test"
                )
            
df = df.with_columns(
      pl.col("year")
      .cast(pl.Int64)
      .alias("year")
)
# Merge this information to the yard_signs table

df_cont = pl.read_csv(
      source = "./chapter_2/data/temp/study_2/02_output.csv"
)

yard_signs = df_cont.with_columns(
    #* Create Last_Name column from Candidate_Name
        names(pl.col("candidate_name")).alias("last_name")
    ).join(
    #* Left-join the yard_signs table to the df table by Last_Name and Year value
        df, on = ["last_name", "year"], how = "left"
    )

# Store dataframe
yard_signs.write_csv(
      file = "./chapter_2/data/temp/study_2/04_output.csv"
)