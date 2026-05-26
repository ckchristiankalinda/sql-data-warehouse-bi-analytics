/*====================================================================
CUSTOMER ANALYSIS

Business Purpose:
- Understand customer distribution
- Identify customer demographics
====================================================================*/

SELECT
    country,
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;


SELECT
    gender,
    COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;
