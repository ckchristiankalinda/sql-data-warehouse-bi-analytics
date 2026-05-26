/*====================================================================
PRODUCT ANALYSIS

Business Purpose:
- Understand product portfolio distribution
====================================================================*/

SELECT
    category,
    COUNT(product_id) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;


SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;
