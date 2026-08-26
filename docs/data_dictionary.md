# Data Dictionary

## 1. Dataset Overview

The dataset contains daily supply-chain and inventory observations.

The raw dataset contains 91,250 records and 15 original columns.

The dataset contains information about:

- Products/SKUs
- Warehouses
- Suppliers
- Regions
- Daily demand
- Inventory
- Reorder thresholds
- Pricing
- Costs
- Promotions
- Stockouts
- Demand forecasts

---

## 2. Raw Dataset Columns

| Column | Description | Data Type | Category |
|---|---|---|---|
| `Date` | Date of the observation | Date | Temporal |
| `SKU_ID` | Unique identifier for the product/SKU | Object | Dimension |
| `Warehouse_ID` | Identifier of the warehouse | Object | Dimension |
| `Supplier_ID` | Identifier of the supplier | Object | Dimension |
| `Region` | Geographic region associated with the record | Object | Dimension |
| `Units_Sold` | Number of units sold during the observation period | Integer | Demand |
| `Inventory_Level` | Inventory available during the observation period | Integer | Inventory |
| `Supplier_Lead_Time_Days` | Expected supplier lead time in days | Integer | Supplier |
| `Reorder_Point` | Inventory level at which replenishment should be considered | Integer | Inventory |
| `Order_Quantity` | Quantity associated with the order | Integer | Procurement |
| `Unit_Cost` | Cost per unit | Numeric | Financial |
| `Unit_Price` | Selling price per unit | Numeric | Financial |
| `Promotion_Flag` | Indicates whether a promotion was active | Integer/Binary | Promotion |
| `Stockout_Flag` | Indicates whether a stockout occurred | Integer/Binary | Inventory |
| `Demand_Forecast` | Forecasted demand | Numeric | Forecast |

---

## 3. Derived Variables

Additional variables were derived during the Python analysis and/or database processing to support business analysis.

| Variable | Description | Calculation / Purpose |
|---|---|---|
| `Year` | Year extracted from the observation date | Extracted from `Date` |
| `Month` | Numerical month | Extracted from `Date` |
| `Month_Name` | Name of the month | Derived from `Date` |
| `Below_Reorder_Point` | Indicates whether inventory is below the reorder threshold | `Inventory_Level < Reorder_Point` |
| `Inventory_Gap` | Difference between inventory level and reorder point | `Inventory_Level - Reorder_Point` |
| `Inventory_Coverage_Days` | Estimated number of days current inventory can support demand | Demand/inventory-based metric |
| `Coverage_Below_Lead_Time` | Indicates whether inventory coverage is below supplier lead time | Coverage compared with lead time |
| `Inventory_Value` | Monetary value of current inventory | `Inventory_Level × Unit_Cost` |
| `Sales_Value` | Monetary value of units sold | `Units_Sold × Unit_Price` |
| `COGS` | Cost associated with units sold | `Units_Sold × Unit_Cost` |
| `Inventory_to_Demand_Ratio` | Ratio comparing inventory to demand | Inventory/demand-based metric |

---

## 4. Important Business Fields

### Units Sold

Represents observed product demand during a given observation period.

This field is used for:

- Demand analysis
- SKU comparisons
- Warehouse comparisons
- Regional comparisons
- Promotion analysis

---

### Inventory Level

Represents the available inventory associated with a record.

It is used to evaluate:

- Inventory health
- Reorder risk
- Inventory value
- Inventory coverage

---

### Reorder Point

Represents the inventory threshold used to identify records requiring potential replenishment.

The project defines reorder risk using:

`Inventory Level < Reorder Point`

---

### Supplier Lead Time

Represents the expected number of days required for inventory replenishment from the supplier.

It is used together with inventory coverage to identify potential supply risks.

---

### Unit Cost and Unit Price

`Unit_Cost` represents the cost of acquiring one unit.

`Unit_Price` represents the selling price of one unit.

These fields are used to derive:

- Sales Value
- COGS
- Gross Profit
- Gross Margin
- Inventory Value

---

## 5. Data Types in Python

The processed analytical dataset uses appropriate types for:

- Dates
- Categorical identifiers
- Integer quantities
- Numeric financial fields
- Boolean business indicators

The profiling notebook contains the detailed data-type and data-quality analysis.

---

## 6. Data Grain

The analysis treats each row as an operational observation at the available dataset grain.

The dataset contains multiple combinations of:

- Date
- SKU
- Warehouse
- Supplier
- Region

Therefore, aggregation should be performed carefully when calculating business KPIs.

---

## 7. Data Quality Considerations

The project includes checks for:

- Missing values
- Duplicate records
- Invalid dates
- Invalid numeric values
- Unexpected categorical values
- Inventory/reorder relationships
- Data consistency between calculated metrics

These checks are documented and implemented during the Python and SQL analysis stages.