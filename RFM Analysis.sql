/* --------------------------------------------------
   1. Understanding RFM Analysis
   --------------------------------------------------
   - Recency: How recently a customer purchased
   - Frequency: Number of purchases by a customer
   - Monetary: Total amount spent by a customer
-------------------------------------------------- */

-- Step 1: Calculate Recency, Frequency, Monetary
WITH recency AS (
    SELECT 
        CustomerID,
        DATEDIFF(CURRENT_DATE(), MAX(InvoiceDate)) AS recency
    FROM ecommerce_orders_cleaned
    WHERE InvoiceDate IS NOT NULL 
      AND CustomerID <> -1
    GROUP BY CustomerID
),

frequency AS (
    SELECT 
        CustomerID,
        COUNT(*) AS frequency
    FROM ecommerce_orders_cleaned
    WHERE InvoiceDate IS NOT NULL 
      AND CustomerID <> -1
    GROUP BY CustomerID
),

monetary AS (
    SELECT 
        CustomerID,
        SUM(total_sales) AS monetary
    FROM ecommerce_orders_cleaned
    WHERE InvoiceDate IS NOT NULL 
      AND CustomerID <> -1
    GROUP BY CustomerID
)

SELECT 
    R.CustomerID, 
    R.recency, 
    F.frequency, 
    ROUND(M.monetary, 2) AS monetary
FROM recency R
JOIN frequency F ON R.CustomerID = F.CustomerID
JOIN monetary M ON R.CustomerID = M.CustomerID
ORDER BY R.recency ASC, F.frequency DESC, M.monetary DESC;



/* --------------------------------------------------
   2. Adding RFM Scores
   -------------------------------------------------- */

WITH recency AS (
    SELECT 
        CustomerID,
        DATEDIFF(CURRENT_DATE(), MAX(InvoiceDate)) AS recency
    FROM ecommerce_orders_cleaned
    WHERE InvoiceDate IS NOT NULL 
      AND CustomerID <> -1
    GROUP BY CustomerID
),

frequency AS (
    SELECT 
        CustomerID,
        COUNT(*) AS frequency
    FROM ecommerce_orders_cleaned
    WHERE InvoiceDate IS NOT NULL 
      AND CustomerID <> -1
    GROUP BY CustomerID
),

monetary AS (
    SELECT 
        CustomerID,
        SUM(total_sales) AS monetary
    FROM ecommerce_orders_cleaned
    WHERE InvoiceDate IS NOT NULL 
      AND CustomerID <> -1
    GROUP BY CustomerID
),

RFM AS (
    SELECT 
        R.CustomerID AS customer_id, 
        NTILE(5) OVER (ORDER BY R.recency ASC)      AS recency_score,
        NTILE(5) OVER (ORDER BY F.frequency DESC)   AS frequency_score,
        NTILE(5) OVER (ORDER BY M.monetary DESC)    AS monetary_score
    FROM recency R
    JOIN frequency F ON R.CustomerID = F.CustomerID
    JOIN monetary M  ON R.CustomerID = M.CustomerID
)

SELECT 
    customer_id,
    recency_score, 
    frequency_score, 
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS RFM_score
FROM RFM
ORDER BY RFM_score DESC;



/* --------------------------------------------------
   3. Identify Declining Segments
   -------------------------------------------------- */

WITH decline_segments AS (
    SELECT 
        CustomerID, 
        CASE 
            WHEN total_sales >= 2000               THEN 'high_value'
            WHEN total_sales BETWEEN 800 AND 1999  THEN 'medium_value'
            WHEN total_sales BETWEEN 400 AND 799   THEN 'low_value' 
            ELSE 'dormant' 
        END AS sales_segment
    FROM ecommerce_orders_cleaned
)

SELECT 
    sales_segment, 
    COUNT(CustomerID) AS customer_count
FROM decline_segments
GROUP BY sales_segment
ORDER BY CASE sales_segment
            WHEN 'high_value'   THEN 1
            WHEN 'medium_value' THEN 2
            WHEN 'low_value'    THEN 3
            WHEN 'dormant'      THEN 4
            ELSE 5
         END;
