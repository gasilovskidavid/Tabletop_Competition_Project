# Installing and deploying libraries
library(dplyr)
library(DBI)
library(RPostgreSQL)
library(rvest)
library(stringr)
library(httr)

# Scraping Philipebrt first
base_url <- "https://www.philibertnet.com/fr/14505-jeux-experts"
all_products_list <- list()
user_agent_string <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36"


## Scraping loop
for (page_number in 1:19) {
  
  if (page_number == 1) {
    page_url <- base_url
  } else {
    page_url <- paste0(base_url, "?p=", page_number)
  }

response <- GET(page_url, add_headers(`User-Agent` = user_agent_string))
print(status_code(response))
print(paste('Scraping page:', page_url))

page_content <- read_html(response)

product_cards <- page_content %>% html_elements(xpath = '//*[@id="center_column"]/ul/li/div')

if (length(product_cards) == 0) {
  print("No more products found. Stopping the scraper.")
  break # Exit the loop
}

for (card in product_cards) {
  # Scrape the data just like in the single-page example
  name <- card %>% html_element(xpath = './div[2]/p[1]/a') %>% html_text2()
  price_text <- card %>% html_element(xpath = './div[3]/p[1]/span') %>% html_text2()
  reviews <- card %>% html_element(xpath = './div[2]/div[2]/div[1]/div/div[1]/span[2]') %>% html_text2()
  num_players <- card %>% html_element(xpath = './div[2]/ul/li[3]/span') %>% html_text2()
  
  stock_check <- card %>% html_element(xpath = './div[3]/div/div/div/a[1]') %>% html_attr("disabled")
  stock <- ifelse(is.na(stock_check), "In Stock", "Out of Stock") 
  
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

final_df_philibert <- bind_rows(all_products_list)

print(head(final_df_philibert))
print(paste("Total products scraped:", nrow(final_df_philibert)))

#Cleaning data
##First the price
final_df_philibert$Price <- gsub(" â\u0082¬", "", final_df_philibert$Price)
final_df_philibert$Price <- gsub(",", ".", final_df_philibert$Price) %>% as.numeric()

##Take care of the confusion in the source code between time of play and the number of players 
final_df_philibert <- final_df_philibert %>% 
  mutate(
    Players = if_else(
      str_detect(Players, "h|min"),
      NA,
      Players
    )
  )

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

final_df_philibert <- final_df_philibert %>% 
    mutate(
      N_Players = sapply(Players, generate_sequence_string)
    )

##Turn reviews into standardized number on the scale from 0 to 5
final_df_philibert <- final_df_philibert %>% 
  mutate(Reviews = as.numeric(str_extract(Reviews, '\\d+\\.?\\d*')))

##Delete all rows where the product name is NA
final_df_philibert <- final_df_philibert %>% filter(!is.na(ProductName))

##Delete all accidental duplicates
final_df_philibert <- final_df_philibert %>% distinct()

##Add the Retailor column
final_df_philibert$Retailor <- "Philibert"

##Because SQLite doesn't recognise the DATE format, we convert the ScrapeDate to
##TEXT to avoid it becoming REAL
final_df_philibert <- final_df_philibert %>% mutate(ScrapeDate = as.character(ScrapeDate))

# --- Database Interaction ---

# Create a connection to the database
con <- dbConnect(PostgreSQL(),
                 host=Sys.getenv("DB_HOST"),
                 port=Sys.getenv("DB_PORT"),
                 dbname=Sys.getenv("DB_NAME"),
                 user=Sys.getenv("DB_USER"),
                 password=Sys.getenv("DB_PASS"))

dbWriteTable(con, "PriceHistory_flat", final_df_philibert, append = TRUE)

dbDisconnect(con)

print("Data successfully scraped and saved to the database.")
