# Data Cleaning

CREATE TABLE ecommerce_orders_cleaned AS SELECT * FROM ecommerce_orders;

SELECT * FROM ecommerce_orders_cleaned;

-- Check the structure of the table
DESCRIBE ecommerce_orders;

-- Check number of rows and columns
SELECT COUNT(*) FROM ecommerce_orders;

-- Check for missing values (NULLs)
SELECT 
SUM(CASE WHEN customerid IS NULL THEN 1 ELSE 0 END) AS null_customers,
SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS null_dates,
SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS null_descriptions,
SUM(CASE WHEN InvoiceNo IS NULL THEN 1 ELSE 0 END) AS null_invoices
FROM ecommerce_orders;

UPDATE ecommerce_orders_cleaned
SET CustomerID = -1
WHERE CustomerID IS NULL;

UPDATE ecommerce_orders_cleaned
SET Description = "Unknown"
WHERE Description IS NULL;

-- added new column invoicedate_dt
ALTER TABLE ecommerce_orders
ADD COLUMN InvoiceDate_dt TIMESTAMP

UPDATE ecommerce_orders_cleaned
SET InvoiceDate_dt = CASE 
    WHEN InvoiceDate LIKE '%-%-%' 
         THEN try_to_timestamp(InvoiceDate, 'MM-dd-yyyy HH:mm')
    WHEN InvoiceDate LIKE '%/%/%' 
         THEN try_to_timestamp(InvoiceDate, 'MM/dd/yyyy HH:mm')
    ELSE NULL
END;

ALTER TABLE ecommerce_orders_cleaned
DROP COLUMN InvoiceDate;

ALTER TABLE ecommerce_orders_cleaned
RENAME COLUMN InvoiceDate_dt TO InvoiceDate;


SELECT count(*) FROM ecommerce_orders_cleaned
WHERE Description RLIKE "[@?*#]";

SELECT DISTINCT Description
FROM ecommerce_orders_cleaned
WHERE Description rlike '[^a-zA-Z0-9 ]';

ALTER TABLE ecommerce_orders_cleaned
ADD COLUMN total_sales DOUBLE;

UPDATE ecommerce_orders_cleaned
SET total_sales = ROUND((Quantity*UnitPrice),2);
