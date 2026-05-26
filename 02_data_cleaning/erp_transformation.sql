/*=========================================================
Load ERP Customer Data from Bronze to Silver Layer
Target Table: silver.erp_cust_az12

Transformation Types:
1. Data Cleansing
   - Remove unwanted 'NAS' prefix from customer IDs.
2. Data Validation
   - Replace invalid future birth dates with NULL.
3. Data Standardization
   - Normalize gender values into a consistent format.
=========================================================*/

INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)

SELECT
    -- Remove 'NAS' prefix from customer ID if present
    CASE 
        WHEN cid LIKE 'NAS%' 
            THEN SUBSTRING(cid,4,LEN(cid))
        ELSE cid
    END AS cid,

    -- Validate birth date:
    -- Future dates are considered invalid and replaced with NULL
    CASE 
        WHEN bdate > GETDATE() 
            THEN NULL
        ELSE bdate
    END AS bdate,

    -- Standardize gender values:
    -- Convert different representations into a unified format
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') 
            THEN 'Female' 

        WHEN UPPER(TRIM(gen)) IN ('M','MALE') 
            THEN 'Male' 

        -- Assign default value for missing or unknown entries
        ELSE 'n/a'
    END AS gen

FROM bronze.erp_cust_az12;
