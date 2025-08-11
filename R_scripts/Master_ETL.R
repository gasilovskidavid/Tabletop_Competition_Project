# =============================================================
# MASTER ETL SCRIPT
# This script controls the entire data pipeline.
# =============================================================

print(paste("ETL process started at:", Sys.time()))

# --- Step 1: Run Scraper for Playin ---
tryCatch({
  print("--- Running Playin scraper... ---")
  source("R_scripts/playin.r") # Assumes your scraper is in an R_Scripts folder
  print("--- Playin scraper finished successfully. ---")
}, error = function(e) {
  print(paste("!!! ERROR in Playin scraper:", e$message))
})

# --- Step 2: Run Scraper for Philibert ---
tryCatch({
  print("--- Running Philibert scraper... ---")
  source("R_scripts/phil.r")
  print("--- Philibert scraper finished successfully. ---")
}, error = function(e) {
  print(paste("!!! ERROR in Philibert scraper:", e$message))
})

print(paste("ETL process finished at:", Sys.time()))