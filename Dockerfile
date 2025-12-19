# Base R image
FROM r-base:4.3.2

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('tidyverse', 'DBI', 'RPostgreSQL', 'rvest', 'stringr', 'httr'), repos='http://cran.rstudio.com/')"

# Set working directory
WORKDIR /app

# Copy scripts
COPY R_scripts/ /app/R_scripts/
COPY SQL_scripts/ /app/SQL_scripts/

# Set the default command to run the master ETL script
CMD ["Rscript", "R_scripts/Master_ETL.R"]
