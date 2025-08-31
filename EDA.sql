/* --------------------------------------------------
   Exploratory Data Analysis (EDA)
   --------------------------------------------------
   Goals:
   1. Analyze country-level sales & contributions
   2. Understand customer purchase behavior
   3. Track active customers over time
-------------------------------------------------- */

-- 1. Average total sales by country
SELECT 
    Country, 
    ROUND(AVG(total_sales), 2) AS avg_total_sales
FROM ecommerce_orders_cleaned
GROUP BY Country
ORDER BY avg_total_sales DESC;


-- 2. Market contribution by each country
SELECT 
    Country, 
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(
        100.0 * SUM(total_sales) / (SELECT SUM(total_sales) FROM ecommerce_orders_cleaned), 
        2
    ) AS pct_contribution
FROM ecommerce_orders_cleaned
GROUP BY Country
ORDER BY pct_contribution DESC;


-- 3. Customer-level purchase distribution
--    - Frequency of transactions
--    - Total spend
--    - Average purchase size
SELECT 
    CustomerID,
    COUNT(*) AS transaction_frequency,
    SUM(total_sales) AS total_sales,
    ROUND(AVG(total_sales), 2) AS avg_purchase_size
FROM ecommerce_orders_cleaned
GROUP BY CustomerID
ORDER BY total_sales DESC;


-- 4. Monthly active customers (within timeframe)
SELECT 
    LEFT(InvoiceDate, 7) AS month, 
    COUNT(DISTINCT CustomerID) AS active_customers
FROM ecommerce_orders_cleaned
WHERE InvoiceDate BETWEEN '2011-07-01' AND '2011-12-30'
GROUP BY LEFT(InvoiceDate, 7)
ORDER BY month;


-- 5. Total unique customers in dataset
SELECT 
    COUNT(DISTINCT CustomerID) AS unique_customers
FROM ecommerce_orders_cleaned;
