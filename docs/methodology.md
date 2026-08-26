# Methodology

## 1. Overview

The Supply Chain & Inventory Analytics project follows an analytical workflow that moves from raw data profiling to business analysis and finally to PostgreSQL-based analytical reporting.

The overall methodology is:

    Raw Dataset
         ↓
    Data Loading
         ↓
    Data Profiling
         ↓
    Data Quality Validation
         ↓
    Feature Engineering
         ↓
    Exploratory Analysis
         ↓
    Business Analysis
         ↓
    PostgreSQL Data Loading
         ↓
    SQL KPI Analysis
         ↓
    Analytical Views
         ↓
    Business Reporting
         ↓
    Power BI (Future Enhancement)

---

## 2. Data Loading

The raw CSV dataset is loaded into Python using Pandas.

The initial analysis examines:

- Number of records
- Number of columns
- Column names
- Data types
- Dataset structure
- Unique categorical dimensions

The raw dataset contains 91,250 records and 15 original columns.

---

## 3. Data Profiling

The profiling stage evaluates the structure and quality of the dataset.

The following checks are performed:

- Dataset dimensions
- Column data types
- Missing values
- Duplicate records
- Unique values
- Date ranges
- Numerical distributions
- Categorical distributions

The purpose of this stage is to understand the structure and characteristics of the dataset before performing detailed business analysis.

---

## 4. Data Quality Validation

Data-quality checks are performed to identify potential problems before analysis.

### Missing Values

Columns are checked for missing observations to determine whether incomplete records may affect the analysis.

### Duplicate Records

The dataset is examined for duplicate records to ensure that repeated observations do not distort the analytical results.

### Date Validation

The date field is examined to understand the available observation period and temporal structure of the dataset.

### Numerical Validation

Numerical fields such as:

- Units Sold
- Inventory Level
- Reorder Point
- Order Quantity
- Unit Cost
- Unit Price
- Demand Forecast

are checked for unexpected or invalid values.

### Business Logic Validation

Relationships between business fields are also examined.

Examples include:

- Inventory Level vs Reorder Point
- Inventory Coverage vs Supplier Lead Time
- Sales Value vs Units Sold and Unit Price
- COGS vs Units Sold and Unit Cost

---

## 5. Feature Engineering

Derived variables are created to support the business analysis.

Important derived metrics include:

### Sales Value

Sales Value = Units Sold × Unit Price

### COGS

COGS = Units Sold × Unit Cost

### Gross Profit

Gross Profit = Sales Value − COGS

### Inventory Value

Inventory Value = Inventory Level × Unit Cost

### Reorder Risk

A record is considered below the reorder threshold when:

Inventory Level < Reorder Point

This condition is represented through the Below_Reorder_Point business indicator during the analytical workflow.

### Inventory Gap

Inventory Gap = Inventory Level − Reorder Point

The inventory gap helps identify how far the current inventory level is from the defined reorder point.

### Inventory Coverage

Inventory coverage estimates the number of days for which the available inventory can support demand based on the observed demand level.

### Coverage Below Lead Time

This indicator compares estimated inventory coverage with supplier lead time to identify situations where inventory coverage may be insufficient relative to replenishment time.

### Inventory-to-Demand Ratio

This metric compares available inventory with observed demand and provides an additional measure of inventory adequacy.

---

## 6. Exploratory Data Analysis

The exploratory analysis examines the main characteristics of demand, inventory, sales, and operational dimensions.

Analysis is performed across:

- Time
- SKU
- Warehouse
- Supplier
- Region
- Promotion status

The objective is to identify:

- Patterns
- Distributions
- Differences between business dimensions
- Potential operational risks
- Relationships between important variables

The Python notebook contains the detailed exploratory analysis and visualizations.

---

## 7. Demand Analysis

Demand is primarily evaluated using the Units_Sold field.

The analysis includes:

- Total units sold
- Average demand
- Demand distribution
- Demand variation
- SKU-level demand
- Warehouse-level demand
- Regional demand
- Promotion vs non-promotion demand

The promotion comparison is treated as an observed association rather than proof of causality.

Higher average demand during promotional observations does not by itself establish that promotions caused the increase.

---

## 8. Inventory Analysis

Inventory performance is evaluated using:

- Inventory Level
- Reorder Point
- Inventory Value
- Inventory Coverage Days
- Supplier Lead Time
- Stockout Flag

The analysis identifies records where:

Inventory Level < Reorder Point

These observations are treated as potential reorder-risk records.

The analysis also compares inventory coverage with supplier lead time to identify situations where inventory may not cover the expected replenishment period.

---

## 9. Supplier Analysis

Supplier performance is evaluated using supplier identifiers and lead-time information.

The analysis examines:

- Supplier lead times
- Average supplier lead time
- Supplier-related inventory conditions
- Inventory coverage relative to supplier lead time

The objective is to identify suppliers or supply conditions that may require additional operational attention.

---

## 10. Warehouse Analysis

Warehouse-level analysis compares operational performance across warehouse identifiers.

Important metrics include:

- Units sold
- Sales
- Inventory
- Reorder risk
- Stockout observations
- Inventory coverage

This analysis helps identify warehouses with relatively higher demand, inventory exposure, or operational risk.

---

## 11. SKU Analysis

SKU-level analysis examines product-level performance using:

- Demand
- Sales
- Inventory
- Reorder risk
- Inventory coverage

The objective is to identify:

- High-demand SKUs
- High-sales SKUs
- SKUs with relatively high inventory exposure
- SKUs with higher reorder risk
- SKUs with potentially low inventory coverage

---

## 12. Regional Analysis

Regional analysis compares supply-chain performance across the available regions.

The analysis examines:

- Sales
- Units sold
- Demand
- Inventory-related measures
- Operational performance

This provides a geographic perspective on supply-chain activity and helps identify differences between regions.

---

## 13. Promotion Analysis

The dataset contains a Promotion_Flag that identifies whether a promotion was active.

Demand is compared between:

- Non-promotion observations
- Promotion observations

The primary metric used for comparison is average units sold.

This analysis is intended to identify whether promotional observations are associated with different demand levels.

The result should be interpreted as an association because the analysis does not establish a causal relationship.

---

## 14. PostgreSQL Analytics

After the Python-based analysis, the dataset is loaded into PostgreSQL.

The main database table is:

supply_chain_inventory

PostgreSQL is then used for:

- Data validation
- KPI calculations
- Aggregation
- Business-rule calculations
- Reusable analytical views
- SQL-based reporting

This provides a persistent analytical layer separate from the Python notebook.

---

## 15. SQL KPI Calculation

The PostgreSQL analytical layer calculates key business metrics such as:

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
- Gross margin percentage
- Total inventory value
- Average inventory level
- Average inventory coverage
- Reorder risk percentage
- Stockout records
- Average supplier lead time

The primary consolidated KPI view is:

vw_business_kpi_summary

---

## 16. Reorder Risk Methodology

Reorder risk is calculated using the underlying inventory and reorder-point fields.

The business rule is:

Inventory Level < Reorder Point

The reorder-risk percentage is calculated as:

Reorder Risk % = Records Below Reorder Point / Total Records × 100

The analysis identifies 4,787 records below the reorder point, corresponding to approximately 5.25% of the dataset.

The SQL implementation uses the underlying inventory_level and reorder_point fields directly so that the business rule remains explicit in the database layer.

---

## 17. Financial KPI Methodology

The project calculates several financial metrics from the underlying sales and cost fields.

### Sales Value

Sales Value = Units Sold × Unit Price

### COGS

COGS = Units Sold × Unit Cost

### Gross Profit

Gross Profit = Sales Value − COGS

### Gross Margin

Gross Margin % = Gross Profit / Sales Value × 100

### Inventory Value

Inventory Value = Inventory Level × Unit Cost

These calculations provide a consistent financial framework for the Python and PostgreSQL analysis.

---

## 18. Analytical Views

The PostgreSQL layer uses reusable analytical views to simplify downstream reporting.

The analytical views summarize the data at different business dimensions, including:

- Overall business KPIs
- Monthly performance
- Regional performance
- Warehouse performance
- SKU performance
- Promotion analysis
- Inventory health

These views allow business questions to be answered without repeatedly writing complex aggregation queries.

---

## 19. Validation Between Python and PostgreSQL

The Python analysis and PostgreSQL analysis are used together to validate important business metrics.

Examples include:

- Record counts
- Total sales
- Total COGS
- Gross profit
- Inventory value
- Reorder risk
- Demand metrics

This cross-validation helps ensure that the database calculations are consistent with the analytical results obtained during Python-based analysis.

---

## 20. Reporting Layer

The current project uses PostgreSQL as the primary analytical reporting layer.

The workflow is:

Python Analysis
        ↓
PostgreSQL
        ↓
SQL KPIs
        ↓
Analytical Views
        ↓
Business Reports

Power BI is planned as a future visualization layer.

When implemented, Power BI can connect to the existing PostgreSQL analytical views without requiring the underlying Python analysis or SQL architecture to be redesigned.

---

## 21. Reproducibility

The project is structured so that the main analytical workflow can be reproduced using:

1. The raw dataset
2. Python notebooks
3. SQL scripts
4. PostgreSQL tables
5. PostgreSQL analytical views
6. Documentation

The separation between Python analysis, database processing, SQL analytics, and reporting allows individual layers to be modified without requiring the entire project to be rebuilt.

---

## 22. Overall Analytical Workflow

The complete methodology can be summarized as:

Raw CSV Dataset
        ↓
Python / Pandas
        ↓
Data Profiling
        ↓
Data Quality Checks
        ↓
Feature Engineering
        ↓
Exploratory Data Analysis
        ↓
Business Analysis
        ↓
PostgreSQL
        ↓
SQL Data Validation
        ↓
KPI Calculations
        ↓
Analytical Views
        ↓
Business Reports
        ↓
Power BI (Future Enhancement)