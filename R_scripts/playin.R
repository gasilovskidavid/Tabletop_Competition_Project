# Installing and deploying libraries
install.packages(c("tidyverse", "DBI", "RSQLite", "rvest", "stringr"))
library(dplyr)
library(DBI)
library(RSQLite)
library(rvest)
library(stringr)
library(httr)

# Scraping Play-in third 
base_url <- "https://www.play-in.com/jeux_de_societe/recherche/8-jeux_experts"
all_products_list <- list()
user_agent_string <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36"


## Scraping loop
for (page_number in 1:26) {
  
  if (page_number == 1) {
    page_url <- base_url
  } else {
    page_url <- paste0(base_url, "?p=", page_number)
  }
  
  response <- GET(page_url, add_headers(`User-Agent` = user_agent_string))
  print(status_code(response))
  print(paste('Scraping page:', page_url))
  
  page_content <- read_html(response)
  
  product_cards <- page_content %>% html_elements(xpath = '//*[@id="wrapper"]/div[1]/div[4]/div[2]/div[1]/div')
  
  if (length(product_cards) == 0) {
    print("No more products found. Stopping the scraper.")
    break # Exit the loop
  }
  
  for (card in product_cards) {
    # Scrape the data just like in the single-page example
    name <- card %>% html_element(xpath = './div/div[2]/a/div[1]') %>% html_text2()
    price_text <- card %>% html_element(xpath = './div/div[3]/div[1]/div') %>% html_text2()
    reviews <- card %>% html_element(xpath = './div/div[2]/div[3]/div[2]') %>% html_attr("title")
    num_players <- card %>% html_element(xpath = './div/div[2]/div[1]/a[1]/div/div/span') %>% html_text2()
    
    stock_check <- card %>% html_element(xpath = './div/div[3]/div[2]/div/form/div[2]')
    stock <- ifelse(is.na(stock_check), "Out of Stock", "In Stock") 

    all_products_list[[length(all_products_list) + 1]] <- data.frame(
      ProductName = name,
      Price = price_text,
      Reviews = reviews, 
      Players = num_players,
      Stock = stock,
      ScrapeDate = Sys.Date()
    )
  }
  
  Sys.sleep(1) # Pause for 1 second
}

final_df_playin <- bind_rows(all_products_list)

print(head(final_df_playin))
print(paste("Total products scraped:", nrow(final_df_playin)))


#Cleaning data
##First the price
final_df_playin$Price <- gsub(" €", "", final_df_playin$Price)
final_df_playin$Price <- gsub(",", ".", final_df_playin$Price) %>% as.numeric()

##Now take the number of players and turn them into analysable numerics 
generate_sequence_string <- function(text_input) {
  numbers <- as.numeric(unlist(str_extract_all(text_input, "\\d+")))
  
  if (length(numbers) == 0) {
    return(NA_character_)
  } else if (length(numbers) == 1) {
    return(as.character(numbers))
  } else {
    full_sequence <- numbers[1]:numbers[2]
    return(paste(full_sequence, collapse = ","))
  }
}

final_df_playin <- final_df_playin %>% 
  mutate(
    N_Players = sapply(Players, generate_sequence_string)
  )

##Same with the reviews
final_df_playin <- final_df_playin %>% 
  mutate(Reviews = as.numeric(str_extract(Reviews, "\\d+\\.?\\d*")))

##Delete all rows where the product name is NA
final_df_playin <- final_df_playin %>% filter(!is.na(ProductName))

##Delete all accidental duplicates
final_df_playin <- final_df_playin %>% distinct()

##Add the Retailor column
final_df_playin$Retailor <- "Playin"

##Because SQLite doesn't recognise the DATE format, we convert the ScrapeDate to
##TEXT to avoid it becoming REAL
final_df_playin <- final_df_playin %>% mutate(ScrapeDate = as.character(ScrapeDate))

# --- Database Interaction ---

db_path <- 'DATA/Tabletop_data.db'

## Create a connection to the database
con <- dbConnect(RSQLite::SQLite(), db_path)

dbWriteTable(con, "PriceHistory_flat", final_df_playin, append = TRUE)

dbDisconnect(con)

print("Data successfully scraped and saved to the database.")
