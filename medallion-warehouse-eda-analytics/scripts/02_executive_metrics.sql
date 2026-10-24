/*
Purpose: define baseline sales metrics at their correct grain.
Population: all rows in the current Gold views; no date filters.
Run 00_validation_checks.sql first and investigate exceptions.
Missing amounts are not silently replaced with zero.
*/
SELECT
    COUNT_BIG(*) AS sales_rows,
    SUM(CAST(sales_amount AS decimal(19, 4))) AS total_sales,
    SUM(CAST(quantity AS bigint)) AS units_sold,
    COUNT(DISTINCT order_number) AS distinct_orders,
    COUNT(DISTINCT customer_key) AS purchasing_customers,
    AVG(CAST(price AS decimal(19, 4))) AS mean_line_unit_price,
    SUM(CAST(sales_amount AS decimal(19, 4)))
        / NULLIF(SUM(CAST(quantity AS decimal(19, 4))), 0) AS realized_sales_per_unit,
    SUM(CAST(sales_amount AS decimal(19, 4)))
        / NULLIF(CAST(COUNT(DISTINCT order_number) AS decimal(19, 4)), 0) AS average_order_value
FROM gold.fact_sales;

-- Dimension populations differ from customers/products represented in sales.
SELECT COUNT_BIG(*) AS customer_dimension_rows,
       COUNT(DISTINCT customer_key) AS distinct_customer_keys
FROM gold.dim_customers;

SELECT COUNT_BIG(*) AS product_dimension_rows,
       COUNT(DISTINCT product_key) AS distinct_product_keys
FROM gold.dim_products;

-- A customer can place several distinct orders.
-- COUNT(order_number) counts non-null sales rows, not distinct orders.
-- AVG(price) weights each row equally; sales / quantity weights sold units.
-- NULLIF returns NULL for an undefined ratio instead of a divide-by-zero error.
