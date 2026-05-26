/*====================================================================
SALES PERFORMANCE ANALYSIS

Business Purpose:
- Identify revenue drivers
- Understand customer value
====================================================================*/

-- Revenue per customer (customer value analysis)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;


-- Sales distribution by country
SELECT
    c.country,
    SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC;
