CREATE TABLE IF NOT EXISTS Products (
    ProductID SERIAL PRIMARY KEY,
    N_Players VARCHAR(255),
    ProductName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Retailors (
    RetailorID SERIAL PRIMARY KEY,
    RetailorName VARCHAR(255) NOT NULL UNIQUE
); 

CREATE TABLE IF NOT EXISTS PriceHistory (
    PriceLogID SERIAL PRIMARY KEY,
    ProductID INTEGER,
    RetailorID INTEGER,
    ScrapeDate DATE NOT NULL,
    Review REAL,
    Price REAL,
	Stock VARCHAR(255),
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID),
    FOREIGN KEY (RetailorID) REFERENCES Retailors (RetailorID)
);

CREATE TABLE IF NOT EXISTS PriceHistory_flat (
    ProductName VARCHAR(255),
    Price REAL,
    Reviews REAL,
    Players VARCHAR(255),
    Stock VARCHAR(255),
    ScrapeDate DATE,
    N_Players VARCHAR(255),
    Retailor VARCHAR(255)
);
