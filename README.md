# Medallion Warehouse EDA Analytics: Gold Layer Optimization

## 📌 Project Overview
This project contains a comprehensive Exploratory Data Analysis (EDA) sequence executed on a multi-tier **Medallion Star Schema Data Warehouse (`Bronze` -> `Silver` -> `Gold`)**. The primary focus is validating structural constraints, tracking business measures, and evaluating performance trends inside the presentation layer (`Gold`).

## 🏢 Business Architecture Layer Spec
The analysis profiles transactions across three highly linked components:
*   **`gold.fact_sales`**: Central transaction kernel keeping track of revenues, quantities, order numbers, and itemized configurations.
*   **`gold.dim_customers`**: Master demographic hub keeping track of geographic footprints, age brackets, and customer lifecycles.
*   **`gold.dim_products`**: Product details schema containing categorical groupings and unit tracking data.

## 🚀 Key Business Insights Extracted
1.  **Unified KPI Dashboard**: Designed and deployed a unified reporting query combining multiple key metrics (Sales volume, customer conversion reach, unique counts) into a single row matrix using optimized stack logic (`UNION ALL`).
2.  **Structural Demographics**: Mapped geographic revenue profiles across global low-cardinality indicators (`country`, `gender`) alongside high-cardinality profiles (`customer_key`).
3.  **Performance Cohorts**: Extracted structural outliers including top 5 products by revenue generated, bottom 5 assets by sales underperformance, and top 10 high-value customer accounts.

## 🛠️ Code Base Architecture
The codebase is structured logically to mirror an end-to-end analytical discovery workflow:
*   `scripts/01_database_discovery.sql`: System metadata evaluation, categorical profiling, and operational date boundaries.
*   `scripts/02_executive_metrics.sql`: Baseline metric calculations tracking absolute revenue, quantity, and distinct activity volumes.
*   `scripts/03_kpi_matrix_ledger.sql`: A unified, high-performance executive reporting matrix engineered using optimized vertical aggregation stacking (`UNION ALL`).
*   `scripts/04_performance_cohorts.sql`: Deep-dive trend analysis profiling segment magnitudes and advanced performance window rankings.

## ⚙️ Technical Skills Highlighted
*   **Advanced Aggregations**: Tie-safe dense window rank implementations (`DENSE_RANK() OVER (...)`).
*   **Query Performance Optimization**: Replaced slow sub-select loops with explicit relational operators (`INNER JOIN`, `LEFT JOIN`).
*   **Safe Data Conversions**: Defensive code design utilizing structural fallbacks (`COALESCE`, `CONCAT`) and fixed historical project points to handle dates.
