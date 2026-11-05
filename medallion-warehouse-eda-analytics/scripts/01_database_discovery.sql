/*
Purpose: inspect the reporting schema, available categories, and date coverage.
Run in the database containing gold.fact_sales, gold.dim_customers,
and gold.dim_products. This script is read-only.
*/
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT DISTINCT country
FROM gold.dim_customers
ORDER BY country;

SELECT product_key, product_name, category, sub_category
FROM gold.dim_products
ORDER BY category, sub_category, product_key;

-- Year boundaries are not the same as complete years of observations.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT YEAR(order_date)) AS calendar_years_with_orders,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date_rows
FROM gold.fact_sales;

-- Use a reproducible dataset boundary instead of today's date.
-- Birth-date bounds are reported directly: DATEDIFF(YEAR) alone is not exact age.
SELECT
    MIN(birth_date) AS earliest_birthdate,
    MAX(birth_date) AS latest_birthdate,
    SUM(CASE WHEN birth_date IS NULL THEN 1 ELSE 0 END) AS missing_birthdates
FROM gold.dim_customers;
