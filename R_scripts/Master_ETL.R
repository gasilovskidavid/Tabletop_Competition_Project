# =============================================================
# MASTER ETL SCRIPT
# This script controls the entire data pipeline.
# =============================================================

library(DBI)
library(RSQLite)

run_sql_processor <- function() {
  print("--- Running SQL data processing... ---")
  sql_file_path <- "SQL_scripts/Populating_the_Tables.sql"

  con <- dbConnect(SQLite(), "DATA/Tabletop_data.db")

  tryCatch({
    # Read the SQL file
    sql_content <- paste(readLines(sql_file_path), collapse = "\n")

    # Split the content into individual statements based on semicolons
    statements <- strsplit(sql_content, ";")[[1]]

    # Start a transaction
    dbBegin(con)

    for (stmt in statements) {
      # Trim whitespace
      trimmed_stmt <- trimws(stmt)

      # Execute only if the statement is not empty
      if (nchar(trimmed_stmt) > 0) {
        dbExecute(con, trimmed_stmt)
      }
    }

    # Commit the transaction if all statements succeed
    dbCommit(con)
    print("--- SQL script executed successfully. ---")

  }, error = function(e) {
    # Rollback changes if an error occurs
    tryCatch({ dbRollback(con) }, error = function(e2) {})
    print(paste("!!! ERROR in SQL processing:", e$message))

  }, finally = {
    dbDisconnect(con)
    print("--- Database connection closed. ---")
  })
}

print(paste("ETL process started at:", Sys.time()))

tryCatch({
    print("--- Running Playin scraper... ---")
    source("R_scripts/playin.R")
    run_sql_processor()
}, error = function(e) {print(paste("!!! ERROR during Playin scrape/process:", e$message))})

tryCatch({
    print("--- Running Philibert scraper... ---")
    source("R_scripts/phil.R")
    run_sql_processor()
}, error = function(e) {print(paste("!!! ERROR during Philibert scrape/process:", e$message))})

print(paste("ETL process finished at:", Sys.time()))
