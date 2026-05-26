/*====================================================================
CRM CUSTOMER CLEANING 

Purpose:
- Clean customer data from raw Bronze layer
- Remove duplicates
- Standardize customer attributes

Business Goal:
Prepare a reliable customer dataset for analysis and reporting
(customer segmentation, demographics, KPI dashboards)
====================================================================*/

-- Remove existing data to avoid duplicates on reload
TRUNCATE TABLE silver.crm_cust_info;

-- Load cleaned customer data
INSERT INTO silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_gndr,
    cst_marital_status,
    cst_create_date
)

SELECT
    cst_id,
    cst_key,

    -- Clean text fields (remove extra spaces)
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    -- Standardize gender values for consistent reporting
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,

    -- Standardize marital status
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    cst_create_date

FROM (
    -- Remove duplicates: keep latest record per customer
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t

WHERE rn = 1;
