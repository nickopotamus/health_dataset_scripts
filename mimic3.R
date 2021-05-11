library(tidyverse)
library(data.table)
library(DBI)
library(RSQLite)

# Assumes you have all the relevant CSV files from 
# https://physionet.org/content/mimiciii/1.4/

# Build sqlite database
con = dbConnect(RSQLite::SQLite(), "mimiciii.sqlite")
str(con)

# Set datafolder
datafolder = getwd()
list.files(datafolder, full.names = TRUE, patter = "*.csv")

# Extract list of CSV names
csv_names <- list.files(datafolder)
csv_names <- csv_names[str_detect(csv_names, "csv")]

# Use data.table for speed
system.time({
  for (table_name in csv_names) {
    csv_name <- str_c(datafolder, "/", table_name)
    tmp <- fread(csv_name)
    table_name <- str_remove(table_name, ".csv")
    dbWriteTable(con, table_name, tmp, overwrite = TRUE)
  }})

# Check by isting tables in database
dbListTables(con)

# disconnect from database
dbDisconnect(con)
