# Title: CAPD Text scraping 

# Notes:
    #* Description: Jupyter Notebook to scrape CAPD site for yard signs in 2018-2022 national elections
    #* Updated: 2023-06-20
    #* Updated by: dcr 

# Load Modules
import time # library to help with sleep and wait times
from selenium import webdriver # to setup the driver
from selenium.webdriver.chrome.options import Options # to specify options for my chrome webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager # use the driver manager so that I don't have to download it and keep track of versions myself
from selenium.webdriver.support.ui import WebDriverWait # use this so that I can wait on my driver to load the page completely before searching
from selenium.webdriver.common.by import By # using the By function to help with the xpath searching
from selenium.webdriver.support import expected_conditions as EC # load the expected_conditions function to make sure all elements matching the xpath happen before the driver stops waiting on the loading
import polars as pl # need the pandas package for dataFrames
#import duckdb # need to store data into database

# Scraping of CAPD site

## Driver and scraping
options = Options() # set webdriver options
options.add_argument("start-maximized") # set an option for the webdriver to automatically open chrome browser that I can interact with the page

driver = webdriver.Chrome() # setup chrome webdriver

wait = WebDriverWait(driver, 100000) # specify wait time for the page before stopping it from collecting links in xpath

url = "https://www.politicsanddesign.com/"

driver.get(url) # Make sure to turn off year filter on page that pops up and scroll all the way down

wait.until(EC.presence_of_all_elements_located((By.XPATH, "//div[@class='candidate-card-text']/ul"))) # tell driver to search along this path, but to not stop the search until it everything has been collected
time.sleep(10) # add an some extra time incase needed 
txt_url = driver.find_elements(By.XPATH, "//div[@class='candidate-card-text']/ul") # go ahead and collect all the elements
txt_url2 = [] # make empty list object to store urls in
for i in txt_url:
    txt_url2.append(i.text) # grab the text for each of the sessions

driver.close() # close the driver

# Data wrangling
txt_url4 = [i for i in txt_url2 if i] # take the elements of txt_url2 and place them in a list

yard_signs = pl.DataFrame({
    #* Put the txt_url4 list into a column called Full
    "full": txt_url4}).with_columns([
    #* Take the Full column and split it to make the Candidate_Name column 
    pl.col("full").str.split(by = " (").list.get(0).alias("candidate_name"),
    #* Take the full column and split it to make the party column
    pl.col("full").str.split(by = " (").list.get(1).alias("party")
    ]).with_columns([
    #* Take the Party column and split it to retain the Party and strip the )
    pl.col("party").str.split("\n").list.get(0).str.strip(")"),
    #* Take the Party column and split it to make the State column
    pl.col("party").str.split("\n").list.get(1).alias("state")
]).with_columns([
    #* Take the State column and split it to retain the State
    pl.col("state").str.split("-").list.get(0),
    #* Take the State column and split it to create the District column
    pl.col("state").str.split("-").list.get(1).alias("district")
]).with_columns([
    #* Take the District column and split it to retain the District
    pl.col("district").str.split(",").list.get(0),
    #* Take the District column and split it to make the Office column
    pl.col("district").str.split(",").list.get(1).alias("office"),
    #* Take the District column and split it to make the Year column
    pl.col("district").str.split(",").list.get(2).alias("year")
]).drop(
    # drop the Full column
    "full"
    )

# Store Data

yard_signs.write_csv(
    file = "./chapter_2/data/temp/study_2/01_output.csv"
    , separator = ","
)


# Notes:
#* Now run 02_capd_img_scraping.py