/* =========================================
   BUSINESS KPIs 
   ========================================= */

/* 1. Total Revenue */
SELECT 
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales;


/* 2. Total Orders */
SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;


/* 3. Total Customers */
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers;


/* 4. Average Order Value (AOV) */
SELECT 
    SUM(sales_amount) * 1.0 / COUNT(DISTINCT order_number) AS avg_order_value
FROM gold.fact_sales;


/* 5. Top 5 Customers by Revenue */
SELECT TOP 5
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_spent
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;


/* 6. Monthly Revenue Trend */
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS monthly_revenue
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
