/* --------------------------------------------------
   Data Cleaning Script
   --------------------------------------------------
   Steps:
   1. Create a cleaned table
   2. Handle missing values
   3. Standardize InvoiceDate
   4. Remove unwanted characters from Description
   5. Add derived column: total_sales
-------------------------------------------------- */

-- 1. Create cleaned copy of raw table
CREATE TABLE ecommerce_orders_cleaned AS 
SELECT * 
FROM ecommerce_orders;

-- Preview the cleaned table
SELECT * FROM ecommerce_orders_cleaned;

-- Check structure of raw table
DESCRIBE ecommerce_orders;

-- Row count
SELECT COUNT(*) AS total_rows 
FROM ecommerce_orders;

-- 2. Check for missing values
SELECT 
    SUM(CASE WHEN CustomerID IS NULL   THEN 1 ELSE 0 END) AS null_customers,
    SUM(CASE WHEN InvoiceDate IS NULL  THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN Description IS NULL  THEN 1 ELSE 0 END) AS null_descriptions,
    SUM(CASE WHEN InvoiceNo IS NULL    THEN 1 ELSE 0 END) AS null_invoices
FROM ecommerce_orders;

-- Replace NULL CustomerID with -1 (treat as Guest users)
UPDATE ecommerce_orders_cleaned
SET CustomerID = -1
WHERE CustomerID IS NULL;

-- Replace NULL product descriptions with 'Unknown'
UPDATE ecommerce_orders_cleaned
SET Description = 'Unknown'
WHERE Description IS NULL;


-- 3. Standardize InvoiceDate format
ALTER TABLE ecommerce_orders_cleaned
ADD COLUMN InvoiceDate_dt TIMESTAMP;

UPDATE ecommerce_orders_cleaned
SET InvoiceDate_dt = CASE 
    WHEN InvoiceDate LIKE '%-%-%' 
         THEN TRY_TO_TIMESTAMP(InvoiceDate, 'MM-dd-yyyy HH:mm')
    WHEN InvoiceDate LIKE '%/%/%' 
         THEN TRY_TO_TIMESTAMP(InvoiceDate, 'MM/dd/yyyy HH:mm')
    ELSE NULL
END;

-- Drop old InvoiceDate column and rename standardized column
ALTER TABLE ecommerce_orders_cleaned
DROP COLUMN InvoiceDate;

ALTER TABLE ecommerce_orders_cleaned
RENAME COLUMN InvoiceDate_dt TO InvoiceDate;


-- 4. Detect invalid product descriptions
SELECT COUNT(*) AS invalid_descriptions
FROM ecommerce_orders_cleaned
WHERE Description RLIKE '[@?*#]';

SELECT DISTINCT Description
FROM ecommerce_orders_cleaned
WHERE Description RLIKE '[^a-zA-Z0-9 ]';


-- 5. Add derived column: total_sales (Quantity * UnitPrice)
ALTER TABLE ecommerce_orders_cleaned
ADD COLUMN total_sales DOUBLE;

UPDATE ecommerce_orders_cleaned
SET total_sales = ROUND((Quantity * UnitPrice), 2);
