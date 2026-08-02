-- =============================================================================================================================
-- #2 TASK: GENERATE REPORT THAT SHOWS  ALL KEY METRICS OF THE BUSINESS.
-- =============================================================================================================================

SELECT 
'Total Sales' AS MEASURE_NAME,
SUM(sales_amount) AS MEASURE_VALUE
FROM gold.fact_sales
UNION ALL
SELECT 
'Total Items Sold' AS MEASURE_NAME,
SUM(quantity) AS MEASURE_VALUE
FROM gold.fact_sales
UNION ALL
SELECT 
'Average Selling Price' AS MEASURE_NAME,
AVG(price) AS MEASURE_VALUE
FROM gold.fact_sales
UNION ALL
SELECT
'Total No.Of Orders' AS MEASURE_NAME,
COUNT(DISTINCT order_number) AS MEASURE_VALUE 
FROM gold.fact_sales
UNION ALL
SELECT 
'Total No. Of Customers' AS MEASURE_NAME,
COUNT(*) AS MEASURE_VALUE
FROM gold.dim_customers
UNION ALL
SELECT 
'Total No. Of Customers Ordered' AS MEASURE_NAME,
COUNT(DISTINCT customer_key) AS MEASURE_VALUE
FROM gold.fact_sales


