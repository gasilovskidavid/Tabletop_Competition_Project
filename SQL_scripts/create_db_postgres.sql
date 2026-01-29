CREATE TABLE IF NOT EXISTS Retailors (
    RetailorID SERIAL PRIMARY KEY,
    RetailorName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Products (
    ProductID SERIAL PRIMARY KEY,
    N_Players VARCHAR(255), 
    ProductName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS PriceHistory (
    PriceLogID SERIAL PRIMARY KEY,
    ProductID INTEGER,
    RetailorID INTEGER,
    ScrapeDate DATE NOT NULL,
    Review REAL,
    Price REAL,
    Stock TEXT,
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID),
    FOREIGN KEY (RetailorID) REFERENCES Retailors (RetailorID)
);
