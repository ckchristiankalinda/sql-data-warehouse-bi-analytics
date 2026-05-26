/*====================================================================
YEAR OVER YEAR ANALYSIS

Business Purpose:
- Compare product performance over time
- Identify growth or decline patterns
====================================================================*/

WITH yearly_sales AS (
    SELECT
        p.product_name,
        YEAR(f.order_date) AS order_year,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    WHERE order_date IS NOT NULL
    GROUP BY p.product_name, YEAR(f.order_date)
)

SELECT
    product_name,
    order_year,
    current_sales,

    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    CASE
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name)
            THEN 'Above Average'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name)
            THEN 'Below Average'
        ELSE 'Average'
    END AS performance_flag,

    LAG(current_sales) OVER (
        PARTITION BY product_name
        ORDER BY order_year
    ) AS previous_year_sales,

    current_sales - LAG(current_sales) OVER (
        PARTITION BY product_name
        ORDER BY order_year
    ) AS yoy_change

FROM yearly_sales
ORDER BY product_name, order_year;
