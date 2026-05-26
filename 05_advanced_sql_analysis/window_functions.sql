/*====================================================================
ADVANCED TIME ANALYTICS

Business Purpose:
- Track cumulative performance
- Identify growth trends
====================================================================*/

SELECT
    order_date,
    total_sales,

    -- cumulative revenue growth
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total,

    -- trend smoothing
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg

FROM (
    SELECT
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) t;
