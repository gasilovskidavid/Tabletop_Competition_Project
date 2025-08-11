# =============================================================
# MASTER ETL SCRIPT
# This script controls the entire data pipeline.
# =============================================================

library(DBI)
library(RSQLite)

run_sql_processor <- function() {
  print("--- Running SQL data processing... ---")
  db_path <- "DATA/Tabletop_data.db"
  sql_file_path <- "SQL_scripts/Populating_the_Tables.sql"
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  tryCatch({
    sql_command <- paste(readLines(sql_file_path), collapse = "\n")
    dbExecute(con, sql_command)
    print("--- SQL script executed successfully. ---")
  }, error = function(e) {
    print(paste("!!! ERROR in SQL processing:", e$message))
  }, finally = {
    dbDisconnect(con)
    print("--- Database connection closed. ---")
  })
}

print(paste("ETL process started at:", Sys.time()))

tryCatch({
    print("--- Running Playin scraper... ---")
    source("R_Scripts/Playin.R")
    run_sql_processor()
}, error = function(e) {print(paste("!!! ERROR during Playin scrape/process:", e$message))})

tryCatch({
    print("--- Running Philibert scraper... ---")
    source("R_Scripts/phil.R")
    run_sql_processor()
}, error = function(e) {print(paste("!!! ERROR during Philibert scrape/process:", e$message))})

print(paste("ETL process finished at:", Sys.time()))
