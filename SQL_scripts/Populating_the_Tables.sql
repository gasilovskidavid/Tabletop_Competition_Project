INSERT INTO retailors (retailorname)
SELECT DISTINCT f.retailor
FROM pricehistory_flat f
WHERE f.retailor NOT IN (SELECT r.retailorname FROM retailors r);

INSERT INTO products (productname, n_players)
SELECT productname, MAX(n_players)
FROM pricehistory_flat f
WHERE f.productname NOT IN (SELECT p.productname FROM products p) AND f.productname IS NOT NULL
GROUP BY productname;

INSERT INTO pricehistory (scrapedate, price, stock, review, productid, retailorid)
SELECT
    CAST(f.scrapedate AS DATE),
    f.price,
    f.stock,
    f.reviews as review,
    p.productid, 
    r.retailorid
FROM
    pricehistory_flat f
JOIN
    products p ON f.productname = p.productname  
JOIN
    retailors r ON f.retailor = r.retailorname
WHERE NOT EXISTS (
    SELECT 1 FROM pricehistory ph
    WHERE ph.scrapedate = CAST(f.scrapedate AS DATE)
      AND ph.productid = p.productid
      AND ph.retailorid = r.retailorid
);
	
DELETE FROM pricehistory_flat;