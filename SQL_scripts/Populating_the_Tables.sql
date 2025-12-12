INSERT INTO Retailors (RetailorName)
SELECT DISTINCT f.Retailor
FROM PriceHistory_flat f
WHERE f.Retailor NOT IN (SELECT r.RetailorName FROM Retailors r);

INSERT INTO Products (ProductName, N_Players)
SELECT ProductName, MAX(N_Players)
FROM PriceHistory_flat f
WHERE f.ProductName NOT IN (SELECT p.ProductName FROM Products p) AND f.ProductName IS NOT NULL
GROUP BY ProductName;

INSERT INTO PriceHistory (ScrapeDate, Price, Stock, Review, ProductID, RetailorID)
SELECT
    f.ScrapeDate,
    f.Price,
	f.Stock,
    f.Reviews as Review,
    p.ProductID, 
    r.RetailorID
FROM
    PriceHistory_flat f
JOIN
    Products p ON f.ProductName = p.ProductName  
JOIN
    Retailors r ON f.Retailor = r.RetailorName;
	
DELETE FROM PriceHistory_flat;