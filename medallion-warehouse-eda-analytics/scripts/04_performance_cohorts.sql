/*
Purpose: compare segments and rank sales contributors.
Population: all current Gold sales records.
This is segment/ranking analysis, not a time-based retention cohort study.
Run validation first: duplicate dimension keys can multiply joined sales.
*/
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

-- Group by keys, not product names: different products can share a name.
-- Return all products occupying the first five competition ranks.
-- Ties can return more than five rows; RANK can skip rank numbers.
WITH product_sales AS (
    SELECT s.product_key, p.product_name,
           SUM(CAST(s.sales_amount AS decimal(19, 4))) AS total_sales
    FROM gold.fact_sales AS s
    INNER JOIN gold.dim_products AS p ON s.product_key = p.product_key
    GROUP BY s.product_key, p.product_name
),
ranked AS (
    SELECT product_key, product_name, total_sales,
           RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM product_sales
)
SELECT product_key, product_name, total_sales, sales_rank
FROM ranked
WHERE sales_rank <= 5
ORDER BY sales_rank, product_key;

-- Lowest-sales products WITH recorded sales; no-sales products are separate.
-- The product key resolves ties so TOP (5) is deterministic.
SELECT TOP (5) s.product_key, p.product_name,
       SUM(CAST(s.sales_amount AS decimal(19, 4))) AS total_sales
FROM gold.fact_sales AS s
INNER JOIN gold.dim_products AS p ON s.product_key = p.product_key
GROUP BY s.product_key, p.product_name
ORDER BY total_sales, s.product_key;

SELECT p.product_key, p.product_name
FROM gold.dim_products AS p
WHERE NOT EXISTS (
    SELECT 1 FROM gold.fact_sales AS s WHERE s.product_key = p.product_key
)
ORDER BY p.product_key;

-- Top purchasing customers; unmatched sales are reported in validation.
SELECT TOP (10) c.customer_key,
       SUM(CAST(s.sales_amount AS decimal(19, 4))) AS total_sales,
       COUNT(DISTINCT s.order_number) AS distinct_orders
FROM gold.fact_sales AS s
INNER JOIN gold.dim_customers AS c ON s.customer_key = c.customer_key
GROUP BY c.customer_key
ORDER BY total_sales DESC, c.customer_key;
