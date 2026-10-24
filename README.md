# Sales Data Exploration with SQL
**SQL Server · Sales reporting · Data validation · Monthly comparisons**

A portfolio project that investigates sales, customers, and products using the Gold views of a companion SQL Server warehouse. The emphasis is on explicit metric definitions, trustworthy joins, and reproducible analysis.

[Companion warehouse](https://github.com/sharankumarsrathod12345/sql-data-warehouse-project) · [Metric definitions and validation guide](docs/analysis-guide.md)

## Business questions

- How much sales value and quantity are represented in the dataset?
- How many distinct orders and purchasing customers are recorded?
- Which categories, countries, products, and customers contribute sales?
- Which current products have no recorded sales?
- How do monthly sales and average order value change?

## Run order

Load the companion warehouse and select its database in SSMS. These scripts are read-only; they do not initialize or reload the warehouse.

| Order | Script | Purpose |
| --- | --- | --- |
| 0 | [Validation checks](medallion-warehouse-eda-analytics/scripts/00_validation_checks.sql) | Missing fields, dimension keys, unmatched sales, and join reconciliation |
| 1 | [Database discovery](medallion-warehouse-eda-analytics/scripts/01_database_discovery.sql) | Schema, dimensions, and coverage |
| 2 | [Executive metrics](medallion-warehouse-eda-analytics/scripts/02_executive_metrics.sql) | Defined metrics at sales-row, order, and customer grain |
| 3 | [KPI summary](medallion-warehouse-eda-analytics/scripts/03_kpi_matrix_ledger.sql) | Ordered metric table with units |
| 4 | [Segment comparisons](medallion-warehouse-eda-analytics/scripts/04_performance_cohorts.sql) | Segment totals, rankings, and unsold products |
| 5 | [Monthly sales](medallion-warehouse-eda-analytics/scripts/05_monthly_sales_analysis.sql) | Monthly sales, orders, customers, units, AOV, and prior-month comparison |

Stop to investigate validation exceptions before publishing analytical conclusions. Missing prior months remain NULL; the script does not assume they represent zero sales.

## Analytical choices

- Orders are distinct order numbers; customers are distinct customer keys.
- Product rankings group by key so identical names do not merge products.
- The top-rank query includes ties; fixed-size lists use keys to resolve ties.
- Mean line unit price and realized sales per unit are separate measures.
- Ratios with zero denominators return NULL.
- Current product cost is not treated as historical cost of goods sold.
- The file named `04_performance_cohorts.sql` contains segment comparisons, not retention cohort analysis.

## Verification status

Schema references were compared with the companion Gold view definitions. A portable fixture test covers order grain, price weighting, duplicate product names, unsold products, missing months, join inflation, and empty-population ratios.

Run `python tests/check_logic.py` from the repository root. It translates selected T-SQL syntax to SQLite for logic checks; it does **not** validate native SQL Server execution, SQL Server decimal precision, or actual source results.

Native SQL Server execution and dataset-derived findings remain pending. See [the guide](docs/analysis-guide.md) for the evidence to capture.

## Scope

This is a portfolio analysis of the available warehouse snapshot, not a production deployment or proof of client impact. No business figures or performance benchmarks are asserted without saved results.

**Author:** Sharan Kumar Rathod
