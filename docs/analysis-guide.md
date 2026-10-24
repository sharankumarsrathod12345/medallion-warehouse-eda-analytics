# Metric definitions and validation workflow

## Population and grain

Scripts use all rows in the current Gold views unless explicitly stated. The monthly script excludes missing order dates; validation reports those exclusions. A sales row is an order/product record, not necessarily a unique order. The source model does not expose an explicit order-line identifier, so repeated order/product combinations need investigation rather than automatic deletion.

Record the database, run date, repository revision, and minimum/maximum order date with every exported result. Confirm the dataset currency before formatting money.

## Metric dictionary

| Metric | Definition | Interpretation |
| --- | --- | --- |
| Total sales | SUM(sales_amount) | Source sales amount; not net profit |
| Units sold | SUM(quantity) | Requires valid quantity values |
| Distinct orders | COUNT(DISTINCT order_number) | Missing order numbers are excluded and must be investigated |
| Purchasing customers | COUNT(DISTINCT customer_key) in sales | Excludes NULL keys; not all registered customers |
| Mean line unit price | AVG(price), cast to decimal | Every non-null row receives equal weight |
| Realized sales per unit | Total sales / units sold | Aggregate realized amount per unit |
| Average order value | Total sales / distinct orders | Requires complete, consistent order identifiers |
| Monthly sales change | 100 × (current − previous) / previous | NULL when the immediately preceding month is absent or zero |

SUM and AVG ignore NULL inputs. Validate missing values first; do not interpret partial totals as complete totals. No rows or zero denominators do not imply a meaningful zero ratio.

## Validation sequence

1. Run script 00. Confirm that all three populations are nonempty.
2. Investigate duplicate/null dimension keys, missing order fields, unmatched sales, and invalid numeric values.
3. Review negative sales in source context; legitimate returns require a documented policy.
4. Check orders attributed to multiple customers or dates.
5. Inspect repeated order/product pairs without assuming they are duplicates.
6. Confirm that row counts and sales totals before and after dimension joins match.
7. Run scripts 01–05 against the same unchanged dataset.
8. Reconcile script 02 against script 03. Reconcile monthly totals against dated sales, not blindly against all sales when dates are missing.
9. Confirm that first/last months represent complete coverage before describing a monthly decline or growth.

Script 00 reports exceptions; it is not an automatic release gate. Retain result sets and the rationale for any accepted exception.

## Ranking and model limitations

Product names are descriptive labels, not identifiers. RANK <= 5 can include more than five products when ties occur and can skip rank numbers. Fixed-size TOP lists resolve ties by key. The lowest-sales list includes only products with recorded sales; the no-sales list is separate.

Gold dimensions are current-state views. Current cost does not establish historical profitability. Row-number keys may change when the underlying source changes; exported results should identify their warehouse snapshot.

## Produce a defensible case study

Export script 00 checks, script 02 metrics, script 04 segment/ranking results, and script 05 monthly results. Do not include personal customer details in public evidence.

For each finding, document:

- Observation with period, population, and a verified value.
- Reconciliation or supporting query.
- A plausible business implication, clearly separated from a proven cause.
- A proposed action and the additional evidence needed to justify it.

Example structure only: “During [period], [segment] represented [verified share] of sales. Investigate [specific driver] before [decision].”

## Test status

The portable SQLite fixture checks analytical logic after a small syntax translation. It uses invented test records, not business data. SQL Server decimal semantics, native compilation, workbook calculations, and actual warehouse output are outside that test.

Native SQL Server validation: **pending**. Business findings: **pending exported results**.
