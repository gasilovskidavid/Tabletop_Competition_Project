# =============================================================
# MASTER ETL SCRIPT
# This script controls the entire data pipeline.
# =============================================================

source("R_scripts/db_connect.R")

run_sql_processor <- function() {
  print("--- Running SQL data processing... ---")

  # Connect using the helper function
  con <- get_db_connection()

  tryCatch({
    # Determine which SQL file to run based on the backend
    if (inherits(con, "PqConnection")) {
      # Postgres logic might handle inserts differently or could reuse the same logic if compatible.
      # For now, let's assume the Populating_the_Tables.sql is generic enough or we might need a variant.
      # Looking at Populating_the_Tables.sql, it uses standard INSERT INTO ... SELECT logic.
      # However, SQLite and Postgres syntax are mostly compatible for simple SQL.
      sql_file_path <- "SQL_scripts/Populating_the_Tables.sql"
    } else {
      sql_file_path <- "SQL_scripts/Populating_the_Tables.sql"
    }

    # Debug: Check if flat table has data
    if (dbExistsTable(con, "pricehistory_flat")) {
      count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM pricehistory_flat")
      print(paste("--- Rows in pricehistory_flat before processing:", count$n))
    } else {
      print("--- WARNING: pricehistory_flat table does not exist!")
    }

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
        print(paste("Executing SQL:", substr(trimmed_stmt, 1, 50), "..."))
        dbExecute(con, trimmed_stmt)
      }
    }

    # Commit the transaction if all statements succeed
    dbCommit(con)
    print("--- SQL script executed successfully. ---")

    # Debug: Check final row count
    final_count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM PriceHistory")
    print(paste("--- Total rows in PriceHistory after processing:", final_count$n))
  }, error = function(e) {
    # Rollback changes if an error occurs
    tryCatch(
      {
        dbRollback(con)
      },
      error = function(e2) {}
    )
    print(paste("!!! ERROR in SQL processing:", e$message))
  }, finally = {
    dbDisconnect(con)
    print("--- Database connection closed. ---")
  })
}

print(paste("ETL process started at:", Sys.time()))

tryCatch(
  {
    print("--- Running Playin scraper... ---")
    source("R_scripts/playin.R")
    run_sql_processor()
  },
  error = function(e) {
    print(paste("!!! ERROR during Playin scrape/process:", e$message))
  }
)

tryCatch(
  {
    print("--- Running Philibert scraper... ---")
    source("R_scripts/phil.R")
    run_sql_processor()
  },
  error = function(e) {
    print(paste("!!! ERROR during Philibert scrape/process:", e$message))
  }
)

print(paste("ETL process finished at:", Sys.time()))
