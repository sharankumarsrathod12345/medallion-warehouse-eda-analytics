# Retail sales exploration in SQL Server

Bikes generated **96.46% of recorded sales value**, while accessories accounted for **59.77% of units sold**. A category can dominate the sales report while another accounts for most pieces sold. For a retail manager reviewing the assortment, the choice of measure changes which category deserves attention.

This portfolio case study explores a historical retail practice dataset. The figures below were calculated from the three Gold view exports produced by my SQL Server warehouse.

[Read my original SQL](EDA.sql) · [View the portfolio case study](https://sharankumarsrathod12345.github.io/projects/sales-eda/) · [Explore the companion warehouse](https://github.com/sharankumarsrathod12345/sql-data-warehouse-project)

## Findings for a retail manager

| Business question | Evidence from the exports | How to use it |
| --- | --- | --- |
| Where is sales value concentrated? | Bikes contributed 28,316,272 of 29,356,250 in recorded sales. The source does not specify a currency. | Start a sales-value review with bikes, then break the category down by product to identify which items explain its share. |
| Which category accounts for the most units? | Accessories contributed 36,112 of 60,423 units. | Review accessories alongside bikes when discussing assortment. Check stock levels, lead times and margins before changing purchasing plans. |
| How much of the catalog recorded sales? | 130 of 295 product keys appeared in sales. The remaining 165 had no recorded sales in this snapshot. | Check launch dates and availability before interpreting an absent sale as weak demand. |

## Export reconciliation

The 60,398 sales rows represent **27,659 distinct orders**. Every sales row matched exactly one customer and one product, and joining the dimensions preserved the row count and the sales total.

Recorded order dates run from **29 December 2010 to 28 January 2014**. Nineteen rows have no order date and account for 4,992 in sales. A report grouped by known order dates should therefore reconcile to **29,351,258**. The first and last calendar years cover partial periods.

## Reading the original script

Open [EDA.sql](EDA.sql) in SSMS, select the database containing `gold.fact_sales`, `gold.dim_customers` and `gold.dim_products`, and run the six sections individually. They cover schema discovery, dimensions, dates, measures, category comparisons, and customer and product rankings.

A few details matter when interpreting the original queries:

- Use the separate `COUNT(DISTINCT order_number)` query for order volume. The KPI summary labels a count of populated sales rows “Total Orders.”
- For catalog counts by category, count distinct product keys. The original category query sums the numeric keys. Product rankings also group by name, so items sharing a name would be combined.
- For price analysis, distinguish the average of recorded line prices from total sales divided by units. One version in the script replaces missing prices with zero.
- Customer ages use the execution date and count calendar-year boundaries. The Bronze and Silver product metadata lookups use `crm_prd_ifo`; the warehouse object is `crm_prd_info`.

The public script is my original submission. The findings above were independently checked against the CSV exports. Execution of the complete script in SQL Server has yet to be independently verified.

**Sharan Kumar Rathod** · [Discuss a reporting project on Upwork](https://www.upwork.com/freelancers/~01db224cb89f18ba29)
