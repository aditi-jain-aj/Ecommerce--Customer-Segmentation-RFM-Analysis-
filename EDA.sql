# EDA

-- total sales by country/distribution
SELECT Country, ROUND(AVG(total_sales),2) AS avg_total_sales 
FROM ecommerce_orders_cleaned
GROUP BY 1
ORDER BY 2;

-- market contribution by each country
SELECT country, ROUND(SUM(total_sales),2) AS totalsales,
ROUND(100.0 * SUM(total_sales)/ (SELECT SUM(total_sales) FROM ecommerce_orders_cleaned),2) AS pct_contribution
FROM ecommerce_orders_cleaned
GROUP BY 1
ORDER BY 3 DESC;

-- To show the distribution of total sales, average purchase size, and frequency of transactions
SELECT 
      customerID,
      COUNT(*) AS transaction_frequency, -- Frequency of transactions
      SUM(total_sales) AS total_sales, -- Total sales for the customer
      AVG(total_sales) AS avg_purchase_size -- Average purchase size
FROM ecommerce_orders_cleaned
GROUP BY customerID
ORDER BY total_sales DESC;

-- How many unique customers are active over the selected timeframe?
SELECT LEFT(invoiceDate,7) AS date, COUNT(DISTINCT customerID) AS active_customers
 FROM ecommerce_orders_cleaned
 WHERE InvoiceDate BETWEEN "2011-07-01" AND "2011-12-30"
 GROUP BY 1
 ORDER BY 1;

SELECT COUNT(DISTINCT customerid) FROM ecommerce_orders_cleaned;
