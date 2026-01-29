library(DBI)
library(RSQLite)

# Function to get database connection
get_db_connection <- function() {
  # Check for Neon DB environment variables
  db_host <- Sys.getenv("NEON_DB_HOST")

  if (db_host != "") {
    print("--- Detected Neon DB configuration. Connecting to PostgreSQL... ---")

    # Load RPostgres strictly when needed to avoid dependency issues on systems without it
    if (!requireNamespace("RPostgres", quietly = TRUE)) {
      stop("RPostgres package is required for Neon DB connection but is not installed.")
    }
    library(RPostgres)

    con <- dbConnect(
      RPostgres::Postgres(),
      dbname = trimws(Sys.getenv("NEON_DB_NAME")),
      host = trimws(Sys.getenv("NEON_DB_HOST")),
      port = 5432,
      user = trimws(Sys.getenv("NEON_DB_USER")),
      password = trimws(Sys.getenv("NEON_DB_PASSWORD")),
      sslmode = "require"
    )

    # Initialize tables if they don't exist (using the Postgres schema)
    # We verify one table to see if initialization is needed
    if (!dbExistsTable(con, "products")) { # Checking lowercase 'products' as Postgres is often case-sensitive/lowercase
      print("--- Initializing Neon Database Schema... ---")
      init_neon_schema(con)
    }

    return(con)
  } else {
    print("--- No Neon DB configuration found. Connecting to local SQLite... ---")
    db_path <- "DATA/Tabletop_data.db"
    con <- dbConnect(RSQLite::SQLite(), db_path)
    return(con)
  }
}

# Helper to initialize Neon schema from the SQL file
init_neon_schema <- function(con) {
  sql_file_path <- "SQL_scripts/create_db_postgres.sql"

  if (file.exists(sql_file_path)) {
    sql_content <- paste(readLines(sql_file_path), collapse = "\n")
    statements <- strsplit(sql_content, ";")[[1]]

    for (stmt in statements) {
      trimmed_stmt <- trimws(stmt)
      if (nchar(trimmed_stmt) > 0) {
        tryCatch(
          {
            dbExecute(con, trimmed_stmt)
          },
          error = function(e) {
            print(paste("Error executing statement:", trimmed_stmt))
            print(e)
          }
        )
      }
    }
    print("--- Neon Database Schema Initialized. ---")
  } else {
    warning(paste("Could not find schema file:", sql_file_path))
  }
}
