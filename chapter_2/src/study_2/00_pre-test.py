# Title: Pre-test

# Notes:
    ## Description: script to place pre-test.dta file in database
    ## Updated: 2022-11-04
    ## Updated by: dcr

# Load modules
import pandas as pd
import duckdb

# Load dta file

pre_test = pd.read_stata("data/chapter_1/pre-test/sps1.dta")

# Store pre-test data in db

db = duckdb.connect('data/dissertation_database')

db.execute("CREATE OR REPLACE TABLE pre_test AS SELECT * FROM pre_test")