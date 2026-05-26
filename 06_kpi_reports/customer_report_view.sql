/*====================================================================
CUSTOMER REPORT (GOLD LAYER)

Purpose:
- Build a 360° view of customers
- Enable segmentation (VIP, Regular, New)
- Track customer behavior over time

Business Use:
- Customer analytics dashboards
- Marketing segmentation
- Customer retention analysis
====================================================================*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*--------------------------------------------------------------------
1. Base dataset: link customers to sales transactions
--------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE f.order_date IS NOT NULL
),

customer_agg AS (
/*--------------------------------------------------------------------
2. Customer-level aggregation
--------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,

    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months

FROM base_query
GROUP BY
    customer_key,
    customer_number,
    customer_name,
    age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age segmentation (demographics analysis)
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,

    -- Customer segmentation (business value)
    CASE
        WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,

    -- Recency (important KPI for retention)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_months,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_months,

    -- KPIs
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE total_sales / lifespan_months
    END AS avg_monthly_spend

FROM customer_agg;
