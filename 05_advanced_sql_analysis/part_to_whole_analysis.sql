/*====================================================================
CATEGORY CONTRIBUTION

Business Purpose:
- Identify most important business categories
====================================================================*/

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    GROUP BY p.category
)

SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() AS total_market_sales,
    ROUND(total_sales * 100.0 / SUM(total_sales) OVER(), 2) AS contribution_pct
FROM category_sales
ORDER BY total_sales DESC;
