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

/*=========================================================
Load ERP Location Data from Bronze to Silver Layer
Target Table: silver.erp_loc_a101

Transformation Types:
1. Data Cleansing
   - Remove special characters from customer IDs.
2. Data Standardization
   - Convert country abbreviations into full country names.
3. Missing Data Handling
   - Replace null or empty country values with 'n/a'.
=========================================================*/

INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
)

SELECT 

-- Remove hyphens from customer ID
REPLACE(cid,'-',''),

-- Standardize country names
CASE 
    WHEN TRIM(cntry)= 'DE' 
        THEN 'Germany'

    WHEN TRIM(cntry) IN ('US','USA') 
        THEN 'United States'

    -- Handle missing values
    WHEN TRIM(cntry)='' 
         OR cntry IS NULL 
        THEN 'n/a'

    ELSE TRIM(cntry)

END AS cntry

FROM bronze.erp_loc_a101;

/*=========================================================
Load Product Category Data from Bronze to Silver Layer
Target Table: silver.erp_px_cat_g1v2

Transformation Types:
1. Direct Data Loading
   - No transformation applied.
2. Data Transfer
   - Data moved as-is from Bronze to Silver.
=========================================================*/

INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)

SELECT 
    id,
    cat,
    subcat,
    maintenance

FROM bronze.erp_px_cat_g1v2;
