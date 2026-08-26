# Supply Chain & Inventory Analytics

An end-to-end data analytics project focused on understanding demand, inventory health, reorder risk, sales performance, supplier lead times, warehouse performance, and regional supply-chain behavior using Python, Pandas, PostgreSQL, and SQL.

---

## 1. Project Overview

Supply-chain operations generate large amounts of operational data across products, warehouses, suppliers, demand, inventory, pricing, and procurement.

The objective of this project is to transform raw supply-chain data into meaningful business insights that can support inventory planning, demand analysis, operational monitoring, and decision-making.

The project combines:

- Python-based data profiling and exploratory analysis
- Business-oriented analytics
- Feature engineering
- PostgreSQL data storage
- SQL-based KPI analysis
- Reusable analytical views
- Business reporting

Power BI dashboarding is planned as a future visualization enhancement.

---

## 2. Business Problem

Supply-chain teams need to maintain sufficient inventory to meet demand while avoiding unnecessary inventory exposure.

Poor inventory decisions can result in:

- Stockouts
- Replenishment delays
- Excess inventory
- Increased inventory carrying costs
- Missed sales opportunities
- Supplier-related operational risks

This project analyzes supply-chain data to identify these patterns and provide a structured analytical view of business performance.

---

## 3. Project Objectives

The main objectives are to:

1. Analyze overall sales and profitability.
2. Understand demand patterns across products, warehouses, and regions.
3. Evaluate inventory levels and inventory value.
4. Identify records below the defined reorder point.
5. Analyze inventory coverage relative to supplier lead time.
6. Examine stockout observations.
7. Compare supplier lead times.
8. Compare warehouse performance.
9. Compare SKU-level performance.
10. Analyze regional performance.
11. Examine demand differences between promotional and non-promotional observations.
12. Build a reusable PostgreSQL and SQL analytics layer.

---

## 4. Dataset

The dataset contains daily supply-chain and inventory observations.

### Dataset Scale

- Records: 91,250
- Original columns: 15
- SKUs: 50
- Warehouses: 5
- Suppliers: 10
- Regions: 4

### Main Data Categories

The dataset contains information related to:

- Date
- Products/SKUs
- Warehouses
- Suppliers
- Regions
- Units sold
- Inventory levels
- Supplier lead times
- Reorder points
- Order quantities
- Unit costs
- Unit prices
- Promotions
- Stockouts
- Demand forecasts

Additional analytical variables were derived during the project.

---

## 5. Technology Stack

| Technology | Purpose |
|---|---|
| Python | Data analysis and processing |
| Pandas | Data manipulation |
| NumPy | Numerical operations |
| Matplotlib | Data visualization |
| Jupyter Notebook | Interactive analysis |
| PostgreSQL | Data storage and SQL analytics |
| pgAdmin | PostgreSQL database management |
| SQL | KPI calculations and analytical views |
| Power BI | Future visualization layer |

---

## 6. Project Architecture

The project follows the following analytical workflow:

    Raw CSV Dataset
           ↓
    Python / Pandas
           ↓
    Data Profiling
           ↓
    Data Quality Validation
           ↓
    Feature Engineering
           ↓
    Exploratory Data Analysis
           ↓
    Business Analysis
           ↓
    PostgreSQL
           ↓
    SQL KPI Analysis
           ↓
    Analytical Views
           ↓
    Business Reports
           ↓
    Power BI (Future Enhancement)

---

## 7. Key Business Metrics

The project calculates several important business metrics.

### Sales Value

Sales value is calculated as:

Sales Value = Units Sold × Unit Price

### COGS

Cost of goods sold is calculated as:

COGS = Units Sold × Unit Cost

### Gross Profit

Gross profit is calculated as:

Gross Profit = Sales Value − COGS

### Gross Margin

Gross margin is calculated as:

Gross Margin % = Gross Profit / Sales Value × 100

### Inventory Value

Inventory value is calculated as:

Inventory Value = Inventory Level × Unit Cost

### Reorder Risk

A record is considered below the reorder threshold when:

Inventory Level < Reorder Point

The project identified 4,787 records below the reorder point, corresponding to approximately 5.25% of the dataset.

---

## 8. Analysis Performed

### Demand Analysis

The project analyzes:

- Total units sold
- Average demand
- Demand distribution
- Demand over time
- SKU-level demand
- Warehouse-level demand
- Regional demand
- Promotion vs non-promotion demand

---

### Inventory Analysis

The project evaluates:

- Inventory levels
- Reorder points
- Inventory value
- Inventory coverage
- Inventory-to-demand ratio
- Coverage relative to supplier lead time
- Stockout observations

---

### SKU Analysis

SKU-level analysis evaluates:

- Demand
- Sales
- Inventory
- Reorder risk
- Inventory coverage

This helps identify high-demand and potentially high-risk products.

---

### Warehouse Analysis

Warehouse-level analysis evaluates:

- Units sold
- Sales
- Inventory
- Reorder risk
- Stockout observations
- Inventory coverage

---

### Supplier Analysis

Supplier analysis focuses on:

- Supplier lead time
- Average supplier lead time
- Inventory coverage
- Coverage relative to lead time
- Potential supply-related risks

---

### Regional Analysis

Regional analysis compares:

- Units sold
- Sales
- Inventory
- Operational performance

across the available regions.

---

### Promotion Analysis

Demand is compared between promotional and non-promotional observations.

The analysis treats the resulting difference as an observed association rather than proof of causality.

---

## 9. PostgreSQL Analytics

The processed dataset is stored in PostgreSQL using the table:

    supply_chain_inventory

The PostgreSQL layer is used for:

- Data storage
- Data validation
- KPI calculations
- Aggregation
- Business-rule calculations
- Analytical views
- Reporting

The database used for the project is:

    Supply-Chain-Inventory-Analytics

---

## 10. SQL KPI Analysis

The SQL analytical layer provides a consolidated view of important business KPIs, including:

- Total records
- Total SKUs
- Total warehouses
- Total suppliers
- Total regions
- Total units sold
- Average daily demand
- Total sales
- Total COGS
- Gross profit
- Gross margin
- Total inventory value
- Average inventory level
- Average inventory coverage
- Reorder risk
- Stockout records
- Average supplier lead time

The SQL layer provides a reusable foundation for downstream reporting.

---

## 11. Project Structure

    Supply-Chain-Inventory-Analytics/
    │
    ├── data/
    │   ├── raw/
    │   └── processed/
    │
    ├── notebooks/
    │   ├── 01_data_profiling.ipynb
    │   └── 02_business_analysis.ipynb
    │
    ├── sql/
    │   ├── 01_create_table.sql
    │   ├── 02_data_quality.sql
    │   ├── 03_kpi_analysis.sql
    │   └── 04_analytical_views.sql
    │
    ├── reports/
    │   ├── business_requirements.md
    │   ├── business_insights.md
    │   └── sql_analysis_report.md
    │
    ├── docs/
    │   ├── data_dictionary.md
    │   ├── methodology.md
    │   └── project_architecture.md
    │
    └── README.md

Note: Some files in the structure may be added or refined as the project is finalized.

---

## 12. Documentation

Detailed project documentation is available in:

- `docs/data_dictionary.md` — Dataset fields and derived variables
- `docs/methodology.md` — Analytical methodology and workflow
- `reports/business_requirements.md` — Business objectives and questions
- `reports/sql_analysis_report.md` — PostgreSQL and SQL analytics

---

## 13. Reproducibility

The project can be reproduced using:

1. The raw dataset
2. Python notebooks
3. SQL scripts
4. PostgreSQL
5. Analytical views
6. Project documentation

The Python layer performs data exploration and business analysis, while PostgreSQL provides persistent storage and reusable SQL analytics.

---

## 14. Key Insights

The analysis identified several important observations.

### Inventory Reorder Risk

4,787 records were below the defined reorder point, representing approximately 5.25% of the dataset.

This provides a measurable indicator of potential replenishment risk.

### Demand and Promotions

Promotional observations showed higher average demand than non-promotional observations.

This relationship is treated as an observed association and not as proof that promotions caused the increase in demand.

### Financial Analysis

The project calculates sales, COGS, gross profit, gross margin, and inventory value to provide a financial perspective alongside operational inventory analysis.

### Inventory Coverage

Inventory coverage is compared with supplier lead time to identify situations where available inventory may not adequately cover the expected replenishment period.

---

## 15. Future Improvements

Planned or potential improvements include:

- Splitting the long exploratory notebook into focused notebooks
- Adding a dedicated business-analysis notebook
- Expanding SQL analytical views
- Adding more advanced inventory-risk analysis
- Automating data refresh
- Adding Power BI dashboards
- Adding dashboard screenshots to the project README
- Improving automated reporting
- Adding additional time-series analysis

---

## 16. Future Power BI Layer

Power BI is planned as a presentation and visualization layer.

The planned dashboard can include:

### Executive Overview

- Total Sales
- Total Units Sold
- Gross Profit
- Gross Margin
- Inventory Value
- Reorder Risk

### Inventory Dashboard

- Inventory levels
- Reorder risk
- Inventory coverage
- Stockout observations
- Warehouse comparisons

### Demand & Sales Dashboard

- Demand trends
- SKU performance
- Regional performance
- Promotion analysis

The PostgreSQL analytical views can serve as the data source for these dashboards.

---

## 17. Conclusion

This project demonstrates an end-to-end analytics workflow starting from raw supply-chain data and progressing through Python-based analysis, PostgreSQL data management, SQL-based business analysis, and reporting.

The combination of Python and PostgreSQL provides both exploratory flexibility and a structured, reusable analytical layer.

The project can subsequently be extended with Power BI to provide an interactive dashboarding and business-intelligence layer.