/*
Purpose: inspect exceptions before interpreting analytical outputs.
Read-only. Run against the same database/snapshot as the other scripts.
Expected: zero exception counts and no duplicate-key/inconsistent-order rows.
Repeated order/product combinations are diagnostic and can be legitimate.
An empty dataset is NOT a successful validation.
*/
SELECT COUNT_BIG(*) AS sales_rows FROM gold.fact_sales;
SELECT COUNT_BIG(*) AS customer_rows FROM gold.dim_customers;
SELECT COUNT_BIG(*) AS product_rows FROM gold.dim_products;

SELECT customer_key, COUNT_BIG(*) AS occurrences
FROM gold.dim_customers
GROUP BY customer_key
HAVING customer_key IS NULL OR COUNT_BIG(*) > 1;

SELECT product_key, COUNT_BIG(*) AS occurrences
FROM gold.dim_products
GROUP BY product_key
HAVING product_key IS NULL OR COUNT_BIG(*) > 1;

SELECT
    COUNT_BIG(CASE WHEN s.order_number IS NULL THEN 1 END) AS missing_order_numbers,
    COUNT_BIG(CASE WHEN s.order_date IS NULL THEN 1 END) AS missing_order_dates,
    COUNT_BIG(CASE WHEN s.sales_amount IS NULL THEN 1 END) AS missing_sales,
    COUNT_BIG(CASE WHEN s.quantity IS NULL OR s.quantity <= 0 THEN 1 END) AS invalid_quantities,
    COUNT_BIG(CASE WHEN s.price IS NULL OR s.price < 0 THEN 1 END) AS invalid_prices,
    COUNT_BIG(CASE WHEN s.sales_amount < 0 THEN 1 END) AS negative_sales,
    COUNT_BIG(CASE WHEN s.shipping_date < s.order_date THEN 1 END) AS shipping_before_order
FROM gold.fact_sales AS s;

SELECT COUNT_BIG(*) AS unmatched_customer_rows
FROM gold.fact_sales AS s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_customers AS c WHERE c.customer_key = s.customer_key
);

SELECT COUNT_BIG(*) AS unmatched_product_rows
FROM gold.fact_sales AS s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_products AS p WHERE p.product_key = s.product_key
);

-- Checks for inconsistent order attribution; missing keys/dates are checked above.
SELECT order_number
FROM gold.fact_sales
WHERE order_number IS NOT NULL
GROUP BY order_number
HAVING COUNT(DISTINCT customer_key) > 1 OR COUNT(DISTINCT order_date) > 1;

-- Diagnostic only: do not auto-delete repeated order/product combinations.
-- Multiple lines can be legitimate; the source has no explicit line ID here.
SELECT order_number, product_key, COUNT_BIG(*) AS rows_per_order_product
FROM gold.fact_sales
GROUP BY order_number, product_key
HAVING COUNT_BIG(*) > 1;

-- A valid one-to-one dimension lookup preserves sales row count and total.
SELECT 'Before joins' AS stage, COUNT_BIG(*) AS sales_rows,
       SUM(CAST(sales_amount AS decimal(19, 4))) AS total_sales
FROM gold.fact_sales
UNION ALL
SELECT 'After left joins', COUNT_BIG(*),
       SUM(CAST(s.sales_amount AS decimal(19, 4)))
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p ON s.product_key = p.product_key;
