/*===============================================================================
📊 GOLD LAYER - BUSINESS REPORTING TABLES (CUSTOMER & PRODUCT)

This script builds the final analytical layer of the Data Warehouse.

It contains two core reporting tables:

1️⃣ gold.report_customer
   - Customer-level KPIs
   - Segmentation: VIP / Regular / New
   - Behavioral metrics: recency, lifespan
   - Performance metrics: total sales, orders, products, quantity

2️⃣ gold.report_product
   - Product-level KPIs
   - Performance segmentation: High / Mid / Low performers
   - Revenue, quantity, customer reach
   - Pricing efficiency metrics

===============================================================================
⚙️ ARCHITECTURE PRINCIPLES
- Built on top of fact_sales (transaction layer)
- Enriched using dimension tables (dim_customers, dim_products)
- Pre-aggregated metrics for fast BI reporting
- Part of Medallion Architecture (Gold Layer)

===============================================================================
🚀 BUSINESS VALUE
- Enables fast dashboarding (Power BI / Tableau)
- Removes heavy computations at query time
- Ensures consistent KPI definitions
- Supports customer & product performance analysis

===============================================================================*/


/*========================================================
🔵 CUSTOMER REPORTING TABLE
========================================================*/

IF OBJECT_ID('gold.report_customer', 'U') IS NOT NULL
    DROP TABLE gold.report_customer;
GO

CREATE TABLE gold.report_customer (
    customer_key INT,
    customer_number NVARCHAR(50),
    customer_name NVARCHAR(200),
    age INT,
    age_group NVARCHAR(50),
    customer_segment NVARCHAR(50),
    last_order_date DATE,
    recency INT,
    total_orders INT,
    total_sales DECIMAL(18,2),
    total_quantity INT,
    total_products INT,
    lifespan INT,
    avg_order_value DECIMAL(18,2),
    avg_monthly_spend DECIMAL(18,2)
);
GO

INSERT INTO gold.report_customer
(
    customer_key,
    customer_number,
    customer_name,
    age,
    age_group,
    customer_segment,
    last_order_date,
    recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    avg_order_value,
    avg_monthly_spend
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,

    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales * 1.0 / total_orders
    END AS avg_order_value,

    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales * 1.0 / lifespan
    END AS avg_monthly_spend

FROM
(
    SELECT
        f.customer_key,
        MAX(c.customer_number) AS customer_number,
        MAX(CONCAT(c.first_name,' ',c.last_name)) AS customer_name,
        MAX(DATEDIFF(YEAR, c.birthdate, GETDATE())) AS age,

        COUNT(DISTINCT order_number) AS total_orders,
        SUM(CAST(f.sales_amount AS DECIMAL(18,2))) AS total_sales,
        SUM(f.quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(f.order_date) AS last_order_date,

        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan

    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
    GROUP BY f.customer_key
) AS customer_aggregation;

SELECT * FROM gold.report_customer;


/*========================================================
🟢 PRODUCT REPORTING TABLE
========================================================*/

IF OBJECT_ID('gold.report_product', 'U') IS NOT NULL
    DROP TABLE gold.report_product;
GO

CREATE TABLE gold.report_product (
    product_key INT,
    product_name NVARCHAR(255),
    category NVARCHAR(100),
    subcategory NVARCHAR(100),
    cost DECIMAL(18,2),

    last_sale_date DATE,
    recency_in_months INT,

    product_segment NVARCHAR(50),

    lifespan INT,
    total_orders INT,
    total_sales DECIMAL(18,2),
    total_quantity INT,
    total_customers INT,

    avg_selling_price DECIMAL(18,2),
    avg_order_revenue DECIMAL(18,2),
    avg_monthly_revenue DECIMAL(18,2)
);
GO

INSERT INTO gold.report_product
(
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    recency_in_months,
    product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    avg_order_revenue,
    avg_monthly_revenue
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,

    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales * 1.0 / total_orders
    END AS avg_order_revenue,

    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales * 1.0 / lifespan
    END AS avg_monthly_revenue

FROM
(
    SELECT
        p.product_key,
        MAX(p.product_name) AS product_name,
        MAX(p.category) AS category,
        MAX(p.subcategory) AS subcategory,
        MAX(p.cost) AS cost,

        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan,
        MAX(f.order_date) AS last_sale_date,

        COUNT(DISTINCT f.order_number) AS total_orders,
        COUNT(DISTINCT f.customer_key) AS total_customers,

        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity,

        ROUND(
            AVG(CAST(f.sales_amount AS FLOAT) / NULLIF(f.quantity, 0)),
            1
        ) AS avg_selling_price

    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY p.product_key
) AS product_aggregations;

SELECT * FROM gold.report_product;

/*===============================================================================
🎯 FINAL NOTES

✔ All business KPIs are precomputed for performance
✔ Data is fully denormalized for analytics use
✔ Ready for BI tools (Power BI, Tableau)
✔ Follows Medallion Architecture best practices

===============================================================================*/
