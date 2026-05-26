/* =========================================
   SAMPLE OUTPUTS (FOR PORTFOLIO DEMO)
   ========================================= */

/* Sample: Customer Table */
SELECT TOP 10 *
FROM gold.dim_customers;


/* Sample: Product Table */
SELECT TOP 10 *
FROM gold.dim_products;


/* Sample: Sales Fact Table */
SELECT TOP 10 *
FROM gold.fact_sales;


/* Sample: Revenue by Product */
SELECT 
    product_key,
    SUM(sales_amount) AS revenue
FROM gold.fact_sales
GROUP BY product_key
ORDER BY revenue DESC;


