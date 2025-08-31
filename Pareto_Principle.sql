/* --------------------------------------------------
   Pareto Principle (80/20 Rule) Analysis
   -------------------------------------------------- 
   - Goal: Identify the % of customers that generate
           80% of the total revenue
-------------------------------------------------- */

WITH customer_sales AS (
    SELECT 
        CustomerID, 
        SUM(total_sales) AS customer_revenue
    FROM ecommerce_orders_cleaned
    WHERE CustomerID <> -1
    GROUP BY CustomerID
),

ranked AS (
    SELECT 
        CustomerID, 
        customer_revenue,
        ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS cust_rank,
        SUM(customer_revenue) OVER () AS total_revenue,
        COUNT(*) OVER () AS total_customers
    FROM customer_sales
),

cumulative AS (
    SELECT 
        CustomerID, 
        customer_revenue, 
        cust_rank,
        SUM(customer_revenue) OVER (ORDER BY customer_revenue DESC) AS cum_revenue,
        SUM(customer_revenue) OVER (ORDER BY customer_revenue DESC) * 1.0 
            / MAX(total_revenue) OVER () AS cum_revenue_pct,
        cust_rank * 1.0 / MAX(total_customers) OVER () AS cum_customer_pct
    FROM ranked
)

-- Final: What % of customers drive 80% of revenue
SELECT 
    MIN(cum_customer_pct) * 100 AS pct_customers_for_80pct_revenue
FROM cumulative
WHERE cum_revenue_pct >= 0.8;



/* --------------------------------------------------
   Revenue Contribution: Guest vs Registered Customers
   -------------------------------------------------- 
   - Goal: Compare sales from registered customers vs 
           guest checkouts
-------------------------------------------------- */

SELECT 
    CASE 
        WHEN CustomerID = -1 THEN 'Guest' 
        ELSE 'Registered' 
    END AS customer_type,
    ROUND(SUM(total_sales), 0) AS revenue,
    ROUND(
        SUM(total_sales) * 100.0 
        / SUM(SUM(total_sales)) OVER (), 
        0
    ) AS pct_of_total
FROM ecommerce_orders_cleaned
GROUP BY 
    CASE 
        WHEN CustomerID = -1 THEN 'Guest' 
        ELSE 'Registered' 
    END;
