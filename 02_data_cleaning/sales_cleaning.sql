/*====================================================================
CRM SALES CLEANING 

Purpose:
- Clean sales transactions
- Fix invalid dates
- Recalculate inconsistent sales values

Business Goal:
Ensure accurate revenue reporting and financial KPIs
====================================================================*/

INSERT INTO silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_quantity,
    sls_sales,
    sls_price
)

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    -- Validate order date
    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
    END AS sls_order_dt,

    -- Validate shipping date
    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
    END AS sls_ship_dt,

    -- Validate due date
    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
    END AS sls_due_dt,

    sls_quantity,

    -- Fix incorrect sales values
    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    -- Derive missing price
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details;
