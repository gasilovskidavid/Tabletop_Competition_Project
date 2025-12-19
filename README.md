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

## Running with Docker

This project is configured to run with Docker and Docker Compose.

### Prerequisites

* Docker
* Docker Compose

### Running the Application

1. **Build and run the services:**
   ```bash
   docker-compose up --build
   ```

2. **Accessing the database:**
   Once the services are running, you can connect to the PostgreSQL database using the following credentials:
   - **Host:** `localhost`
   - **Port:** `5432`
   - **Database:** `tabletop`
   - **User:** `user`
   - **Password:** `password`

---

## Tech Stack

* **Data Scraping:** R (`rvest`, `httr`, `jsonlite`)
* **Database:** PostgreSQL (with Docker)
* **Data Transformation:** SQL
* **Automation:** GitHub Actions
* **Visualization:** Power BI
