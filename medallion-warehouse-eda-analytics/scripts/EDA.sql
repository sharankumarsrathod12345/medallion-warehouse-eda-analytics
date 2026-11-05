/* Sharan Rathod | Warehouse exploratory data analysis
   Select the loaded warehouse in SSMS and run 00_validation_checks.sql first.
   The six sections below can also be run separately. */

-- 1. Discover the objects and columns across the warehouse layers.
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze', 'silver', 'gold')
ORDER BY TABLE_SCHEMA, TABLE_NAME;

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA IN ('bronze', 'silver', 'gold')
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;

-- 2. Explore customer countries and the product hierarchy.
SELECT DISTINCT country
FROM gold.dim_customers
ORDER BY country;

SELECT product_key, product_name, category, subcategory
FROM gold.dim_products
ORDER BY category, subcategory, product_key;

-- 3. Inspect sales coverage and customer age at the last observed order date.
-- Year boundaries are not the same as complete years of observations.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT YEAR(order_date)) AS calendar_years_with_orders,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date_rows
FROM gold.fact_sales;

;WITH snapshot AS (
    SELECT MAX(order_date) AS as_of_date FROM gold.fact_sales
), ages AS (
    SELECT d.birthdate, s.as_of_date,
           CASE WHEN d.birthdate <= s.as_of_date THEN
               DATEDIFF(year, d.birthdate, s.as_of_date)
               - CASE WHEN DATEADD(year, DATEDIFF(year, d.birthdate, s.as_of_date), d.birthdate)
                           > s.as_of_date THEN 1 ELSE 0 END
           END AS age_years
    FROM gold.dim_customers AS d CROSS JOIN snapshot AS s
)
SELECT MAX(as_of_date) AS age_as_of, MIN(age_years) AS youngest_age,
       MAX(age_years) AS oldest_age, COUNT_BIG(*) - COUNT_BIG(age_years) AS rows_without_valid_age
FROM ages;

-- 4. Explore measures and produce a KPI summary.
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

WITH sales_summary AS (
    SELECT
        SUM(CAST(sales_amount AS decimal(19, 4))) AS total_sales,
        SUM(CAST(quantity AS decimal(19, 4))) AS units_sold,
        COUNT(DISTINCT order_number) AS distinct_orders,
        COUNT(DISTINCT customer_key) AS purchasing_customers,
        AVG(CAST(price AS decimal(19, 4))) AS mean_line_unit_price
    FROM gold.fact_sales
),
metrics AS (
    SELECT 1 AS sort_order, 'Total sales' AS metric,
           total_sales AS metric_value, 'source currency' AS unit FROM sales_summary
    UNION ALL
    SELECT 2, 'Units sold', units_sold, 'units' FROM sales_summary
    UNION ALL
    SELECT 3, 'Distinct orders', CAST(distinct_orders AS decimal(38, 4)), 'orders' FROM sales_summary
    UNION ALL
    SELECT 4, 'Purchasing customers', CAST(purchasing_customers AS decimal(38, 4)), 'customers' FROM sales_summary
    UNION ALL
    SELECT 5, 'Mean line unit price', mean_line_unit_price, 'source currency / unit' FROM sales_summary
    UNION ALL
    SELECT 6, 'Realized sales per unit', total_sales / NULLIF(units_sold, 0), 'source currency / unit'
    FROM sales_summary
    UNION ALL
    SELECT 7, 'Average order value',
           total_sales / NULLIF(CAST(distinct_orders AS decimal(19, 4)), 0),
           'source currency / order' FROM sales_summary
)
SELECT metric, metric_value, unit
FROM metrics
ORDER BY sort_order;

-- 5. Compare countries, customer groups and product categories.
SELECT country, COUNT_BIG(*) AS customers
FROM gold.dim_customers
GROUP BY country
ORDER BY customers DESC, country;

-- COUNT(*) retains rows in a NULL gender group.
SELECT gender, COUNT_BIG(*) AS customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY customers DESC, gender;

SELECT category, COUNT_BIG(*) AS products,
       AVG(CAST(cost AS decimal(19, 4))) AS mean_current_product_cost
FROM gold.dim_products
GROUP BY category
ORDER BY products DESC, category;

-- LEFT JOIN preserves unmatched sales; a NULL category needs investigation.
SELECT p.category,
       SUM(CAST(s.sales_amount AS decimal(19, 4))) AS total_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC, p.category;

SELECT c.country,
       SUM(CAST(s.quantity AS bigint)) AS units_sold
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY units_sold DESC, c.country;

-- 6. Rank products and customers.
-- Rank identified products with observed sales. Include ties at each cutoff.
;WITH product_totals AS (
    SELECT p.product_key, p.product_name, SUM(CAST(s.sales_amount AS decimal(19,4))) AS sales
    FROM gold.fact_sales AS s
    JOIN gold.dim_products AS p ON p.product_key = s.product_key
    GROUP BY p.product_key, p.product_name
    HAVING COUNT(s.sales_amount) > 0
), ranked AS (
    SELECT *, RANK() OVER (ORDER BY sales DESC) AS highest_sales_rank,
              RANK() OVER (ORDER BY sales ASC) AS lowest_sales_rank
    FROM product_totals
)
SELECT * FROM ranked
WHERE highest_sales_rank <= 5 OR lowest_sales_rank <= 5
ORDER BY highest_sales_rank, product_key;

-- Show all purchasing customers with a recorded order number.
-- Flags identify the top ten by sales and the three lowest order counts, including ties.
;WITH customer_totals AS (
    SELECT c.customer_key, c.first_name, c.last_name,
           SUM(CAST(s.sales_amount AS decimal(19,4))) AS sales,
           COUNT(DISTINCT s.order_number) AS distinct_orders
    FROM gold.fact_sales AS s
    JOIN gold.dim_customers AS c ON c.customer_key = s.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
    HAVING COUNT(s.order_number) > 0
), ranked AS (
    SELECT *, RANK() OVER (ORDER BY sales DESC) AS sales_rank,
              RANK() OVER (ORDER BY distinct_orders) AS order_count_rank
    FROM customer_totals
)
SELECT customer_key, first_name, last_name, sales, distinct_orders,
       CASE WHEN sales IS NOT NULL AND sales_rank <= 10 THEN 1 ELSE 0 END AS top_customer_by_sales,
       CASE WHEN order_count_rank <= 3 THEN 1 ELSE 0 END AS fewest_orders
FROM ranked
ORDER BY sales_rank, customer_key;
