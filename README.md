# Sales Data Exploration with SQL
**SQL Server · Gold-layer analysis · Business metrics and rankings**

A set of T-SQL exploration scripts for a sales warehouse. The queries inspect available data, calculate summary measures, compare customer and product groups, and rank sales contributors.

[Companion warehouse](https://github.com/sharankumarsrathod12345/sql-data-warehouse-project) · [Browse scripts](medallion-warehouse-eda-analytics/scripts/)

## Questions explored

- What dates and categories are represented?
- What are total sales, quantity, and distinct orders?
- How many customers exist, and how many have placed orders?
- How does sales activity vary by category, customer, and country?
- Which products and customers rank highest or lowest on the selected measure?

## Script guide

| Order | Script | Purpose |
| --- | --- | --- |
| 1 | [Database discovery](medallion-warehouse-eda-analytics/scripts/01_database_discovery.sql) | Schema metadata, categories, date boundaries, and customer birth dates |
| 2 | [Executive metrics](medallion-warehouse-eda-analytics/scripts/02_executive_metrics.sql) | Sales, quantity, prices, orders, products, and customers |
| 3 | [KPI summary](medallion-warehouse-eda-analytics/scripts/03_kpi_matrix_ledger.sql) | Combine named measures into rows using UNION ALL |
| 4 | [Segment comparisons and rankings](medallion-warehouse-eda-analytics/scripts/04_performance_cohorts.sql) | Aggregations, joins, TOP N, and RANK examples |

## Setup and compatibility

Load the companion warehouse, select its database in SSMS, and review the scripts in sequence.

**The current exploration scripts need column-name alignment with the companion warehouse before all queries will run:**

| Exploration reference | Companion Gold column |
| --- | --- |
| `sub_category` | `subcategory` |
| `birth_date` | `birthdate` |
| `product_cost` | `cost` |

The discovery script also contains the metadata lookup typo `crm_prd_ifo`; the source table is `crm_prd_info`.

## Metric interpretation

- `COUNT(DISTINCT order_number)` counts orders, not customers or first purchases.
- `COUNT(DISTINCT customer_key)` in sales counts customers represented in sales.
- `AVG(price)` is a row-level average; it is not a quantity-weighted realized selling price.
- `DATEDIFF(YEAR, birthdate, GETDATE())` counts year boundaries and can overstate age before a birthday.
- `TOP N` without a unique secondary sort may choose tied records inconsistently. The ranking example uses `RANK()`, not `DENSE_RANK()`.
- Rankings starting from sales exclude products with no sales records.

## Deliverable and next steps

The deliverable is an inspectable SQL exploration sequence. Query outputs and measured business findings are not committed, and no performance benchmark is included.

Next steps are to align schema references, correct explanatory comments, define tie handling and metric grain, and publish reconciled results with business interpretations.

**Author:** Sharan Kumar Rathod
