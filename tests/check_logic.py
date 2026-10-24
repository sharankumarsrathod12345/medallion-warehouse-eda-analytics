"""Portable logic fixtures; not a native SQL Server integration test."""
import sqlite3, re
from pathlib import Path
from datetime import date
root=Path(__file__).resolve().parents[1]/'medallion-warehouse-eda-analytics/scripts'
c=sqlite3.connect(':memory:')
c.execute("ATTACH DATABASE ':memory:' AS gold")
c.executescript('''
CREATE TABLE gold.dim_customers(customer_key INT, country TEXT, gender TEXT);
CREATE TABLE gold.dim_products(product_key INT, product_name TEXT, category TEXT, cost REAL);
CREATE TABLE gold.fact_sales(order_number TEXT,customer_key INT,product_key INT,order_date TEXT,shipping_date TEXT,sales_amount REAL,quantity INT,price REAL);
INSERT INTO gold.dim_customers VALUES(1,'India','M'),(2,'USA',NULL);
INSERT INTO gold.dim_products VALUES(1,'Same name','A',5),(2,'Same name','A',10),(3,'Unsold','B',20);
INSERT INTO gold.fact_sales VALUES
('A',1,1,'2024-01-01','2024-01-03',10,1,10),
('A',1,2,'2024-01-01','2024-01-03',90,3,30),
('B',1,1,'2024-02-01','2024-02-03',20,2,10),
('C',2,2,'2024-04-01','2024-04-03',80,4,20);
''')
c.create_function('YEAR',1,lambda d:int(d[:4]) if d else None)
c.create_function('MONTH',1,lambda d:int(d[5:7]) if d else None)
c.create_function('DATEFROMPARTS',3,lambda y,m,d:date(y,m,d).isoformat())
def dateadd(unit,n,d):
    y,m,day=map(int,d.split('-')); total=y*12+m-1+n
    return date(total//12,total%12+1,day).isoformat()
c.create_function('DATEADD',3,dateadd)
def run(name):
    s=(root/name).read_text()
    s=re.sub(r'/\*.*?\*/','',s,flags=re.S)
    s=re.sub(r'--[^\n]*','',s)
    s=re.sub(r'COUNT_BIG\(', 'COUNT(',s,flags=re.I)
    s=re.sub(r'decimal\(\d+,\s*\d+\)', 'REAL',s,flags=re.I)
    s=s.replace('DATEADD(MONTH,',"DATEADD('MONTH',")
    results=[]
    for q in s.split(';'):
        q=q.strip()
        if not q:continue
        top=re.search(r'SELECT TOP \((\d+)\)',q,re.I)
        if top:
            q=re.sub(r'SELECT TOP \(\d+\)','SELECT',q,flags=re.I)+' LIMIT '+top[1]
        results.append(c.execute(q).fetchall())
    return results
metrics=run('02_executive_metrics.sql')[0][0]
assert metrics[:5]==(4,200.0,10,3,2),metrics
assert abs(metrics[5]-17.5)<1e-8 and abs(metrics[6]-20)<1e-8
assert abs(metrics[7]-200/3)<1e-8
ledger={r[0]:r[1] for r in run('03_kpi_matrix_ledger.sql')[0]}
assert ledger['Distinct orders']==3 and ledger['Realized sales per unit']==20
segments=run('04_performance_cohorts.sql')
assert len(segments[5])==2,segments[5]
assert segments[7]==[(3,'Unsold')],segments[7]
monthly=run('05_monthly_sales_analysis.sql')[0]
assert monthly[1][-1]==-80 and monthly[2][-2] is None,monthly
checks=run('00_validation_checks.sql')
assert checks[3]==[] and checks[4]==[] and all(v==0 for v in checks[5][0])
assert checks[-1][0][1:]==checks[-1][1][1:]
c.execute("INSERT INTO gold.dim_products VALUES(1,'Duplicate','A',5)")
checks=run('00_validation_checks.sql')
assert checks[4]==[(1,2)] and checks[-1][1][1]>checks[-1][0][1]
c.execute('DELETE FROM gold.fact_sales')
empty=run('02_executive_metrics.sql')[0][0]
assert empty[3:5]==(0,0) and empty[6] is None and empty[7] is None
print('PASS: order grain, price weighting, KPI consistency, duplicate names, unsold products, missing month, join inflation, empty-population ratios.')
print('SQLite-translated logic fixtures only; not native T-SQL or production-data validation.')
