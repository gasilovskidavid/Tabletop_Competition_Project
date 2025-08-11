## Project Summary

This project is an end-to-end data pipeline that automatically scrapes product data from competitor websites, processes and stores the data in a SQL database, and visualizes the insights in an interactive Power BI dashboard. The goal is to provide actionable intelligence for e-commerce pricing and marketing strategies.

---

##  Technical Architecture

The project follows a modern ETL workflow:



1.  **Data Extraction (R):** Two separate R scripts scrape data from Ludum.fr and Philibert.net, handling dynamic content and anti-scraping measures.
2.  **Data Loading (R & SQLite):** The raw data is loaded into a staging table in a local SQLite database.
3.  **Data Transformation (SQL):** An SQL script runs to process the staged data, normalizing it into a clean, relational schema (Products, Retailors, PriceHistory).
4.  **Automation (GitHub Actions):** The entire ETL pipeline is scheduled to run automatically every night using GitHub Actions.
5.  **Visualization (Power BI):** A Power BI report connects to the SQLite database to provide analysis and insights.

---

## Key Features & Insights

* **Price Trend Analysis:** Track a single product's price across all competitors over time.
* **Actionable Alerts:** A dedicated page flags products that have just gone out of stock at a competitor, creating marketing opportunities.
* **Top 10 Price Gaps:** A dynamic table shows the 10 in-stock products with the largest current price difference between retailers.
* **Interactive Filtering:** Users can slice the data by retailer, product name, player count, and more.

---

## Tech Stack

* **Data Scraping:** R (`rvest`, `httr`, `jsonlite`)
* **Database:** SQLite
* **Data Transformation:** SQL
* **Automation:** GitHub Actions
* **Visualization:** Power BI
