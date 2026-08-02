
-- =============================================================================================================================
-- Exploratory Data Analysis Project
-- =============================================================================================================================

-- How to create database in a sql server: 
-- #1 Option: Create project database by running a script
-- #2 Option: Import flat files to database
-- #3 Option: Restore the project database
-- #4 Option: Create database from scratch (DATAWAREHOUSE PROJECT)

-- =============================================================================================================================

-- The secret: Dimensions and Measures
-- QUESTIONS:
-- #1) is data type = number? ; ans: no ==> dimension
--                            ; ans: yes ==> #2) does it make sense to aggregate? ; ans: no ==> dimension
--                                                                                ; ans: yes ==> measure

-- Examples:

-- 1] Practice
SELECT DISTINCT
category
FROM gold.dim_products
-- #1 Is it numeric? ==> No ==> Dimension

-- 2] Practice 
SELECT DISTINCT
sales_amount
FROM gold.fact_sales
-- #1 Is it numeric? ==> Yes ==> #2 Does it make sense to aggregate? ==> Yes ==> Measure 

-- 3] Practice
SELECT DISTINCT
product_name
FROM gold.dim_products
-- #1 Is it numeric? ==> No ==> Dimension

-- 4] Practice
SELECT DISTINCT
quantity
FROM gold.fact_sales
-- #1 Is it numeric? ==> Yes ==> #2 Does it make sense to aggregate? ==> Yes ==> Measure 

-- 5] Practice
SELECT DISTINCT
birth_date
FROM gold.dim_customers
-- #1 Is it numeric? ==> No ==> Dimension

-- 6] Practice
SELECT DISTINCT
--DATEDIFF(YEAR, birth_date, GETDATE()) AS CUSTOMER_AGE,
AVG(DATEDIFF(YEAR, birth_date, GETDATE())) AS CUSTOMER_AVG_AGE
FROM gold.dim_customers
-- #1 Is it numeric? ==> Yes ==> #2 Does it make sense to aggregate? ==> Yes ==> Measure 

-- 7] Practice
SELECT DISTINCT
customer_id
FROM gold.dim_customers
-- #1 Is it numeric? ==> Yes ==> #2 Does it make sense to aggregate? ==> No ==> Dimension


-- =======================================================================================================================================================--


-- ========================
--  #1 DATABASE EXPLORATION:
-- ========================

-- Explore all OBJECTS in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES

-- Explore all COLUMNS in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS

-- ===================================================
-- Explore TABLE_SCHEMA bronze and it's all TABLE_NAME: JUST FOR PRACTICE 
-- ===================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_cust_info'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_prd_ifo'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_cust_az12'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_loc_a101'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_px_cat_g1v2'

-- ===================================================
-- Explore TABLE_SCHEMA silver and it's all TABLE_NAME: JUST FOR PRACTICE
-- ===================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_cust_info'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_prd_ifo'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_cust_az12'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_loc_a101'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'erp_px_cat_g1v2'

-- ===================================================
-- Explore TABLE_SCHEMA gold and it's all TABLE_NAME: THIS IS THE ONLY ONE WE MUST DO FOR DATA EXPLORATION.
-- ===================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products'
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales'


-- =======================================================================================================================================================--


-- ==========================
--  #2 DIMENSIONS EXPLORATION: Identify the unique values (or categories) in each dimensions. Recognizing how data might be grouped or segmented, which is useful for later analysis.
-- ==========================

-- FORMULA: To find dimensions ==> DISTINCT [ Dimensions ] ==> DISTINCT country, DISTINCT category, DISTINCT product 

-- #1 TASK: Explore all countries our customers come from.
SELECT DISTINCT
country
FROM gold.dim_customers

-- #2 TASK: Explore all categories "The Major Divisions"
SELECT DISTINCT
category,
sub_category,
product_name
FROM gold.dim_products
ORDER BY 1,2,3


-- =======================================================================================================================================================--


-- ====================
--  #3 DATE EXPLORATION: IDENTIFY THE EARLIEST AND LATEST DATES (BOUNDARIES). UNDERSTAND THE SCOPE OF DATA AND THE TIMESPAN.
-- ====================

-- FORMULA: MIN/MAX [ DATE DIMENSION ]; MIN(ORDER_DATE),MAX(ORDER_DATE), MAX(CREATE_DATE), MIN(BIRTH_DATE)

-- FIND THE DATE OF THE FIRST AND LAST ORDER
-- HOW MANY YEARS OF SALES ARE AVAILABLE
SELECT 
MIN(order_date) AS FIRST_ORDER_DATE,
MAX(order_date) AS LAST_ORDER_DATE,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS ORDER_RANGE_YEARS
FROM gold.fact_sales

-- FIND THE YOUNGEST AND THE OLDEST CUSTOMER
-- FIND THE AGE OF YOUNGEST AND OLDEST CUSTOMER
SELECT 
MIN(birth_date) AS OLDEST_CUSTOMER,
DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS OLDEST_CUSTOMER_AGE,
MAX(birth_date) AS YOUNGEST_CUSTOMER,
DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS YOUNGEST_CUSTOMER_AGE
FROM gold.dim_customers


