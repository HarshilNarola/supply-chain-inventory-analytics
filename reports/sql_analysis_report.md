# SQL Analysis Report

## 1. Overview

PostgreSQL is used as the database and SQL analytics layer for the Supply Chain & Inventory Analytics project.

The purpose of the SQL layer is to:

- Store the supply-chain dataset
- Validate the imported data
- Calculate business KPIs
- Perform business-oriented aggregations
- Create reusable analytical views
- Provide a structured reporting layer

The SQL layer complements the Python analysis by providing persistent and reusable database-level analytics.

---

## 2. Database

The PostgreSQL database used for the project is:

Supply-Chain-Inventory-Analytics

The primary analytical table is:

supply_chain_inventory

The table contains the processed supply-chain dataset used for SQL analysis.

The imported dataset contains 91,250 records.

---

## 3. Main Table Structure

The main table contains the following fields:

- date
- sku_id
- warehouse_id
- supplier_id
- region
- units_sold
- inventory_level
- supplier_lead_time_days
- reorder_point
- order_quantity
- unit_cost
- unit_price
- promotion_flag
- stockout_flag
- demand_forecast
- year
- month
- month_name
- below_reorder_point
- inventory_gap
- inventory_coverage_days
- coverage_below_lead_time
- inventory_value
- sales_value
- cogs
- inventory_to_demand_ratio

These fields contain both the original dataset attributes and derived analytical variables.

---

## 4. SQL Analysis Objectives

The SQL analysis focuses on the following business areas:

### Sales and Profitability

- Total sales
- Total COGS
- Gross profit
- Gross margin

### Demand

- Total units sold
- Average daily demand
- SKU-level demand
- Warehouse-level demand
- Regional demand

### Inventory

- Total inventory value
- Average inventory level
- Inventory coverage
- Reorder risk
- Stockout observations

### Supplier

- Average supplier lead time
- Supplier-level performance
- Relationship between lead time and inventory coverage

### Operations

- Warehouse performance
- Regional performance
- SKU performance
- Promotion-related demand differences

---

## 5. Business KPI Summary

A consolidated SQL query was created to calculate the main business KPIs from the supply_chain_inventory table.

The KPI analysis includes:

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
- Average inventory coverage days
- Reorder risk percentage
- Stockout records
- Average supplier lead time

These metrics provide a high-level summary of overall supply-chain performance.

---

## 6. Financial Analysis

### Sales Value

Sales value is calculated from units sold and unit price.

Sales Value = Units Sold × Unit Price

The corresponding database field is:

sales_value

---

### COGS

Cost of goods sold is calculated using units sold and unit cost.

COGS = Units Sold × Unit Cost

The corresponding database field is:

cogs

---

### Gross Profit

Gross profit is calculated as:

Gross Profit = Sales Value − COGS

The SQL analysis calculates gross profit using the aggregated sales and COGS values.

---

### Gross Margin

Gross margin percentage is calculated as:

Gross Margin % = Gross Profit / Total Sales × 100

A NULLIF safeguard is used in the SQL calculation to prevent division-by-zero errors.

---

## 7. Inventory Analysis

Inventory performance is evaluated using:

- inventory_level
- reorder_point
- inventory_value
- inventory_coverage_days
- supplier_lead_time_days
- stockout_flag

The SQL analysis evaluates inventory conditions at both overall and aggregated business levels.

---

## 8. Reorder Risk

The project's primary reorder-risk rule is:

Inventory Level < Reorder Point

This condition is represented by:

below_reorder_point

The reorder-risk percentage is calculated as:

Reorder Risk % = Records Below Reorder Point / Total Records × 100

The analysis identified:

- Records below reorder point: 4,787
- Reorder risk: approximately 5.25%

This metric is used to identify observations where inventory may require replenishment attention.

---

## 9. Inventory Coverage Analysis

Inventory coverage is used to estimate how long available inventory can support observed demand.

The project also contains:

coverage_below_lead_time

This indicator compares inventory coverage with supplier lead time.

The purpose is to identify situations where available inventory coverage may be lower than the expected replenishment period.

Such observations may represent increased supply-chain risk.

---

## 10. Stockout Analysis

The stockout_flag field is used to identify observations associated with stockout conditions.

SQL aggregation is used to calculate the number of stockout observations.

This metric can be used to evaluate product-availability problems and identify areas requiring further investigation.

---

## 11. Demand Analysis

Demand is primarily measured using:

units_sold

The SQL analysis calculates:

- Total units sold
- Average daily demand
- Demand by SKU
- Demand by warehouse
- Demand by region
- Demand during promotional and non-promotional observations

These aggregations allow demand patterns to be compared across different operational dimensions.

---

## 12. SKU-Level Analysis

SKU-level SQL analysis can be used to compare:

- Total units sold
- Sales
- Inventory
- Inventory value
- Reorder risk
- Inventory coverage

This allows high-demand, high-sales, or potentially high-risk SKUs to be identified.

---

## 13. Warehouse-Level Analysis

Warehouse-level aggregation is used to evaluate:

- Units sold
- Sales
- Inventory
- Inventory value
- Reorder risk
- Stockout observations
- Inventory coverage

This provides a comparison of operational performance across warehouses.

---

## 14. Regional Analysis

Regional SQL analysis compares:

- Units sold
- Sales
- Inventory
- Inventory value
- Operational indicators

This helps identify differences in supply-chain activity across regions.

---

## 15. Supplier Analysis

Supplier-level analysis focuses primarily on:

supplier_id

and:

supplier_lead_time_days

The analysis can be used to compare:

- Average supplier lead time
- Inventory coverage
- Coverage relative to lead time
- Inventory-related risk

This helps identify supplier conditions that may require further operational investigation.

---

## 16. Promotion Analysis

The promotion_flag field identifies whether a promotion was active.

SQL aggregation can be used to compare demand between:

- Promotion observations
- Non-promotion observations

The primary comparison is average units sold.

The result should be interpreted as an association rather than proof that promotions caused changes in demand.

---

## 17. Analytical Views

PostgreSQL analytical views are used to create reusable datasets for reporting.

The views can provide summarized information for areas such as:

- Overall business KPIs
- Monthly performance
- Regional performance
- Warehouse performance
- SKU performance
- Promotion analysis
- Inventory health

Using views reduces the need to repeatedly write the same aggregation queries.

---

## 18. Python and PostgreSQL Relationship

Python and PostgreSQL serve different purposes in the project.

### Python

Python is used primarily for:

- Data loading
- Data profiling
- Data-quality analysis
- Feature engineering
- Exploratory analysis
- Statistical analysis
- Visualization
- Business analysis

### PostgreSQL

PostgreSQL is used primarily for:

- Persistent data storage
- SQL-based validation
- Aggregation
- KPI calculation
- Analytical views
- Business reporting

The two layers complement each other rather than replacing one another.

---

## 19. SQL Validation

The PostgreSQL dataset was validated after importing the CSV data.

The final table contains:

91,250 records

Important business metrics were also checked using SQL aggregations.

The reorder-risk calculation was specifically validated using the underlying:

inventory_level

and:

reorder_point

fields.

This ensures that the business rule is calculated directly from the source data.

---

## 20. Reporting Architecture

The current analytical architecture is:

Raw CSV Dataset
        ↓
Python / Pandas
        ↓
Processed Dataset
        ↓
PostgreSQL
        ↓
SQL Analysis
        ↓
Analytical Views
        ↓
Business Reports

Power BI is planned as a future visualization layer.

When implemented, Power BI can consume the PostgreSQL analytical views rather than requiring the entire analysis to be recreated.

---

## 21. Role of SQL in the Project

The SQL layer transforms PostgreSQL from simple data storage into a reusable analytical system.

It provides:

- Centralized business calculations
- Reusable KPI queries
- Consistent business rules
- Aggregated reporting datasets
- Separation between raw data and reporting logic
- A foundation for future dashboarding

This makes the project more representative of a real-world analytics workflow.

---

## 22. Future Enhancements

Potential future improvements include:

- Additional analytical views
- More detailed supplier performance analysis
- Advanced inventory-risk analysis
- Automated data-refresh workflows
- Database indexes for frequently queried fields
- Additional time-series analysis
- Power BI dashboards
- Automated reporting

---

## 23. Conclusion

The PostgreSQL layer provides the project's structured SQL analytics and reporting foundation.

Python is used for detailed exploration and business analysis, while PostgreSQL provides persistent storage, SQL-based KPI calculations, aggregations, and reusable analytical views.

Together, these components create an end-to-end analytics workflow:

Raw Data → Python Analysis → PostgreSQL → SQL Analytics → Business Reporting → Future Dashboarding