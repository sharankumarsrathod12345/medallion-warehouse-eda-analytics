/*
Purpose: return a compact, ordered metric table for reporting.
Definitions match 02_executive_metrics.sql. Units are explicit.
A CTE describes the aggregation; it does not guarantee materialization
or better performance. No performance improvement is claimed.
*/
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
