/*
Purpose: compare sales and order activity with the immediately preceding month.
Population: sales with valid order dates; missing-date rows are reported by 00.
Observed months only. A missing previous month yields NULL, not invented zero.
Boundary months may be incomplete; source coverage must be confirmed.
*/
WITH monthly AS (
    SELECT DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
           SUM(CAST(sales_amount AS decimal(19, 4))) AS total_sales,
           COUNT(DISTINCT order_number) AS distinct_orders,
           COUNT(DISTINCT customer_key) AS purchasing_customers,
           SUM(CAST(quantity AS bigint)) AS units_sold
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT m.month_start, m.total_sales, m.distinct_orders,
       m.purchasing_customers, m.units_sold,
       m.total_sales / NULLIF(CAST(m.distinct_orders AS decimal(19, 4)), 0) AS average_order_value,
       p.total_sales AS previous_month_sales,
       CAST(100.0 * (m.total_sales - p.total_sales)
           / NULLIF(p.total_sales, 0) AS decimal(19, 2)) AS sales_mom_pct
FROM monthly AS m
LEFT JOIN monthly AS p ON p.month_start = DATEADD(MONTH, -1, m.month_start)
ORDER BY m.month_start;
