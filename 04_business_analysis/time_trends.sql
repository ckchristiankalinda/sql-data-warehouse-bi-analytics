/*====================================================================
TIME ANALYSIS

Business Purpose:
- Understand sales evolution over time
- Detect trends and seasonality
====================================================================*/

SELECT
    DATETRUNC(YEAR, order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY order_year;
