-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ EXPLORATORY DATA ANALYSIS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- =======================
-- #1 DATABASE EXPLORATION:
-- =======================

-- Explore all OBJECTS in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- Explore all COLUMNS in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;

-- ===================================================
-- Explore TABLE_SCHEMA bronze and it's all TABLE_NAME:
-- ===================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'crm_cust_info';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'crm_prd_ifo';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'crm_sales_details';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'erp_cust_az12';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'erp_loc_a101';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'erp_px_cat_g1v2';

-- ===================================================
-- Explore TABLE_SCHEMA silver and it's all TABLE_NAME:
-- ===================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'crm_cust_info';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'crm_prd_ifo';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'crm_sales_details';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'erp_cust_az12';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'erp_loc_a101';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'erp_px_cat_g1v2';

-- =================================================
-- Explore TABLE_SCHEMA gold and it's all TABLE_NAME: THIS IS THE ONLY ONE WE MUST DO FOR DATA EXPLORATION (IMP).
-- =================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG = 'DataWarehouse';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold' AND TABLE_NAME = 'dim_products';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold' AND TABLE_NAME = 'fact_sales';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold' AND TABLE_NAME = 'dim_customers';

-- ========================== ------------------------------------------------------------------------------------------------------------------------------------------------------
-- #2 DIMENSIONS EXPLORATION: Identify the unique values (or categories) in each dimensions. Recognizing how data might be grouped or segmented, which is useful for later analysis.|
-- ========================== ------------------------------------------------------------------------------------------------------------------------------------------------------

-- TASK: EXPLORE ALL COUNTRIES OUR CUSTOMERS COME FROM
SELECT DISTINCT
country
FROM gold.dim_customers;

-- TASK: EXPLORE ALL CATEGORIES "THE MAJOR DIVISIONS"
SELECT DISTINCT
category,
sub_category,
product_name
FROM gold.dim_products;

-- ==================== ---------------------------------------------------------------------------------------------------
-- #3 DATE EXPLORATION: IDENTIFY THE EARLIEST AND LATEST DATES (BOUNDARIES). UNDERSTAND THE SCOPE OF DATA AND THE TIMESPAN.|
-- ==================== ---------------------------------------------------------------------------------------------------

-- HOW MANY YEARS OF SALES ARE AVAILABLE
SELECT 
MIN(order_date) AS FIRST_ORDER_DATE,
MAX(order_date) AS LAST_ORDER_DATE,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS ORDER_RANGE	-- FOUR YEARS (2010 TO 2014)
FROM gold.fact_sales;

-- FIND THE AGE OF YOUNGEST AND OLDEST CUSTOMER
SELECT 
MIN(birth_date) AS OLDEST_CUSTOMER,
DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS OLDEST_CUSTOMER_AGE, -- 110 (SUSPICIOUS)
MAX(birth_date) AS YOUNGEST_CUSTOMER,
DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS YOUNGEST_CUSTOMER_AGE -- 40
FROM gold.dim_customers;

-- ======================== ------------------------------------------------------------------------------------------------------------------
-- #4 MEASURES EXPLORATION: CALCULATE THE KEY METRIC OF THE BUSINESS (BIG NUMBERS). HIGHEST LEVEL OF AGGREGATION TO | LOWEST LEVEL OF DETAILS.|
-- ======================== ------------------------------------------------------------------------------------------------------------------

-- FIND THE TOTAL SALES
SELECT
SUM(sales_amount) AS TOTAL_SALES		-- 29356250
FROM gold.fact_sales;

-- FIND HOW MANY ITEMS ARE SOLD
SELECT 
SUM(quantity) AS TOTAL_ITEMS			-- 60423
FROM gold.fact_sales;

-- FIND THE AVERAGE SELLING PRICE
SELECT 
AVG(price) AS AVG_PRICE					-- 486
FROM gold.fact_sales;

SELECT 
AVG(COALESCE(price, 0)) AS AVG_PRICE	-- 486
FROM gold.fact_sales;

-- FIND THE TOTAL NUMBER OF ORDERS
SELECT 
COUNT(*) AS TOTAL_ORDERS				-- 60398
FROM gold.fact_sales;

SELECT 
COUNT(order_number) AS TOTAL_ORDERS		-- 60398
FROM gold.fact_sales;

-- FIND THE TOTAL NUMBER OF DISTINCT ORDERS
SELECT 
COUNT(DISTINCT order_number) AS TOTAL_ORDERS_DISTINCT	-- 27659
FROM gold.fact_sales;

-- FIND THE TOTAL NUMBER OF PRODUCTS
SELECT 
COUNT(product_name) AS TOTAL_PRODUCTS,					-- 295
COUNT(DISTINCT product_name) AS TOTAL_PRODUCTS_DISTINCT	-- 295
FROM gold.dim_products;

-- FIND THE TOTAL NUMBER OF CUSTOMERS
SELECT 
COUNT(customer_key) AS TOTAL_CUSTOMERS	-- 18484
FROM gold.dim_customers;

-- FIND THE TOTAL NUMBER OF CUSTOMERS THAT HAS PLACED ORDERS
SELECT 
COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS_ORDERED		-- 18484
FROM gold.fact_sales;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- TASK: GENERATE REPORT THAT SHOWS ALL KEY METRICS OF THE BUSINESS.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT 
'Total Sales' AS MEASURE_NAME,
SUM(sales_amount) AS MEASURE_VALUE	-- 29356250
FROM gold.fact_sales
UNION ALL
SELECT 
'Total Items Sold' AS MEASURE_NAME,
SUM(quantity) AS MEASURE_VALUE	-- 60423
FROM gold.fact_sales
UNION ALL
SELECT 
'Average Selling Price' AS MEASURE_NAME,
AVG(COALESCE(price, 0)) AS MEASURE_VALUE	-- 486
FROM gold.fact_sales
UNION ALL
SELECT 
'Total Orders' AS MEASURE_NAME,
COUNT(order_number) AS MEASURE_VALUE	-- 60398
FROM gold.fact_sales
UNION ALL
SELECT 
'Total Customers' AS MEASURE_NAME,
COUNT(customer_key) AS MEASURE_VALUE	-- 18484
FROM gold.dim_customers
UNION ALL
SELECT 
'Total Customers Ordered' AS MEASURE_NAME,
COUNT(DISTINCT customer_key) AS MEASURE_VALUE	-- 18484
FROM gold.fact_sales;

-- ====================== ---------------------------------------------------------------------------------------------------------
--  #5 MAGNITUDE ANALYSIS: COMPARE THE MEASURE VALUES BY CATEGORIES. IT HELP US UNDERSTAND THE IMPORTANCE OF DIFFERENCE CATEGORIES.|
-- ====================== ---------------------------------------------------------------------------------------------------------

-- FIND TOTAL CUSTOMERS BY COUNTRIES
SELECT 
country,
COUNT(customer_key) AS TOTAL_CUSTOMERS
FROM gold.dim_customers
GROUP BY country
ORDER BY TOTAL_CUSTOMERS DESC;

-- FIND TOTAL CUSTOMERS BY GENDER
SELECT 
gender,
COUNT(customer_key) AS TOTAL_CUSTOMERS
FROM gold.dim_customers
GROUP BY gender
ORDER BY TOTAL_CUSTOMERS DESC;

-- FIND TOTAL PRODUCTS BY CATEGORY
SELECT 
category,
SUM(product_key) AS TOTAL_PRODUCTS
FROM gold.dim_products
GROUP BY category
ORDER BY TOTAL_PRODUCTS DESC;

-- WHAT IS THE AVERAGE COST IN EACH CATEGORY?
 SELECT 
 category,
 AVG(product_cost) AS AVG_COST
 FROM gold.dim_products
 GROUP BY category
 ORDER BY AVG_COST DESC;

 -- WHAT IS THE TOTAL REVENUE GENERATED FOR EACH CATEGORY?
SELECT
P.category,
SUM(S.sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_products AS P
ON S.product_key = P.product_key
GROUP BY P.category
ORDER BY TOTAL_REVENUE DESC;

-- FIND TOTAL REVENUE GENERATED BY EACH CUSTOMER
SELECT 
customer_key,
SUM(sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales
GROUP BY customer_key
ORDER BY TOTAL_REVENUE DESC;
--OR
SELECT 
C.customer_key,
C.first_name,
C.last_name,
SUM(sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_customers AS C
ON S.customer_key = C.customer_key
GROUP BY C.customer_key, C.first_name,C.last_name
ORDER BY TOTAL_REVENUE DESC;

-- WHAT IS THE DISTRIBUTION OF SOLD ITEMS ACROSS COUNTRIES?
SELECT 
C.country,
SUM(S.quantity) AS TOTAL_ITEMS_SOLD
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_customers AS C
ON S.customer_key = C.customer_key
GROUP BY C.country
ORDER BY TOTAL_ITEMS_SOLD DESC;

-- =================== ----------------------------------------------------------------------------------
-- #6 Ranking Analysis: Order the values of DIMENSION by MEASURE. Top N Performers | Bottom N Performers.|
-- =================== ----------------------------------------------------------------------------------

-- WHICH 5 PRODUCTS GENERATE THE HIGHEST REVENUE (Top N Performers)
SELECT TOP 5 WITH TIES
P.product_name,
SUM(S.sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_products AS P
ON S.product_key = P.product_key
GROUP BY P.product_name
ORDER BY TOTAL_REVENUE DESC;
-- OR
SELECT *
FROM(
SELECT 
P.product_name,
SUM(S.sales_amount) AS TOTAL_REVENUE,
RANK() OVER(ORDER BY SUM(S.sales_amount) DESC) AS PRODUCT_RANK
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_products AS P
ON S.product_key = P.product_key
GROUP BY P.product_name
)T 
WHERE PRODUCT_RANK <= 5;

-- WHAT ARE THE 5 WORST-PERFORMING PRODUCTS IN TERMS OF SALES (Bottom N Performers)
SELECT TOP 5 WITH TIES
P.product_name,
SUM(S.sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_products AS P
ON S.product_key = P.product_key
GROUP BY P.product_name
ORDER BY TOTAL_REVENUE ASC;

-- FIND THE TOP 10 CUSTOMERS WHO HAVE GENERATED THE HIGHEST REVENUE.
SELECT TOP 10 WITH TIES
C.customer_key,
C.first_name,
C.last_name,
SUM(S.sales_amount) AS TOTAL_REVENUE
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_customers AS C
ON S.customer_key = C.customer_key 
GROUP BY C.customer_key,
		 C.first_name,
		 C.last_name
ORDER BY TOTAL_REVENUE DESC;

-- FIND THE TOP 3 CUSTOMERS WITH THE FEWEST ORDERS PLACED.
SELECT TOP 3 WITH TIES
C.customer_key,
C.first_name,
C.last_name,
COUNT(DISTINCT S.order_number) AS TOTAL_ORDERS
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_customers AS C
ON S.customer_key = C.customer_key
GROUP BY C.customer_key,
		 C.first_name,
		 C.last_name
ORDER BY TOTAL_ORDERS ASC;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ END +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

