/*====================================================================
DATA EXPLORATION (EDA)

Purpose:
- Understand structure of the database
- Validate data quality
- Explore key business entities (customers, products, sales)

Business Goal:
Gain initial insights before building analytics models
====================================================================*/

-- View all tables in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;


-- Inspect structure of customer dimension table
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';


-- Identify countries where customers are located
-- Business insight: helps understand market distribution
SELECT DISTINCT country
FROM gold.dim_customers;


-- Understand sales time range
-- Business insight: defines business activity period
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS business_duration_years
FROM gold.fact_sales;


-- Customer age analysis
-- Business insight: helps define customer demographics
SELECT
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_customer_age,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_customer_age
FROM gold.dim_customers;
