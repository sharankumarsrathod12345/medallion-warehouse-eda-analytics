-- ========================
--  #4 MEASURES EXPLORATION: CALCULATE THE KEY METRIC OF THE BUSINESS (BIG NUMBERS). HIGHEST LEVEL OF AGGREGATION TO | LOWEST LEVEL OF DETAILS.
-- ========================

-- FORMULA: COUNT[MEASURES], SUM[MEASURES], AVG[MEASURES] LIKE SUM(SALES), AVG(PRICE), SUM(QUANTITY)

-- =============================================================================================================================
-- #1 TASK:
-- =============================================================================================================================

-- FIND THE TOTAL SALES
SELECT 
SUM(sales_amount) AS TOTAL_SALES
FROM gold.fact_sales

-- FIND HOW MANY ITEMS ARE SOLD
SELECT 
SUM(quantity) AS ITEMS_SOLD
FROM gold.fact_sales

-- FIND THE AVERAGE SELLING PRICE
SELECT 
AVG(price) AS AVG_SELLING_PRICE
FROM gold.fact_sales

-- FIND THE TOTAL NUMBER OF ORDERS
SELECT 
COUNT(order_number) AS TOTAL_NR_ORDERS --> ONE PERSON HAS GIVEN SO MANY ORDERS THEN IT COUNTS ALL OF THEM.
FROM gold.fact_sales
SELECT 
COUNT(DISTINCT order_number) AS TOTAL_NR_ORDER_DISTINCT --> ONE PERSON HAS GIVEN SO MANY ORDERS BUT IT COUNTS ONLY PERSON AND HIS ONLY ONE FIRST ORDER FROM ALL OF THEM TO AVOID REPETITION OF PERSON ON EVERY ORDER.
FROM gold.fact_sales

-- FIND THE TOTAL NUMBER OF PRODUCTS
SELECT 
COUNT(product_name) AS TOTAL_NR_PRODUCTS
FROM gold.dim_products
SELECT 
COUNT(DISTINCT product_name) AS TOTAL_NR_PRODUCTS
FROM gold.dim_products

-- FIND THE TOTAL NUMBER OF CUSTOMERS
SELECT 
COUNT(*) AS TOTAL_NR_CUSTOMERS
FROM gold.dim_customers

-- FIND THE TOTAL NUMBER OF CUSTOMERS THAT HAS PLACED ORDERS
SELECT 
COUNT(customer_key) AS TOTAL_NR_CUSTOMERS_ORDERED,--> REPETITON
COUNT(DISTINCT customer_key) AS TOTAL_NR_CUSTOMERS_ORDERED --> EXACT: BEST AND RIGHT
FROM gold.fact_sales

