# Business Insights

## 1. Overview

This report summarizes the major business findings obtained from the Supply Chain & Inventory Analytics project.

The analysis combines Python-based exploratory and business analysis with PostgreSQL-based SQL analytics.

The primary areas of analysis are:

- Sales and profitability
- Demand
- Inventory health
- Reorder risk
- Stockout behavior
- Supplier lead time
- SKU performance
- Warehouse performance
- Regional performance
- Promotion-related demand

---

## 2. Overall Business Performance

The analysis provides a consolidated view of supply-chain performance using sales, cost, inventory, and demand metrics.

The major financial KPIs include:

- Total Sales
- Total COGS
- Gross Profit
- Gross Margin
- Total Inventory Value

These metrics provide a financial perspective alongside the operational inventory analysis.

The SQL layer provides reusable KPI calculations for these measures.

---

## 3. Sales and Profitability

Sales value is calculated from units sold and unit price:

Sales Value = Units Sold × Unit Price

COGS is calculated using:

COGS = Units Sold × Unit Cost

Gross profit is calculated as:

Gross Profit = Sales Value − COGS

The analysis uses these measures to evaluate the relationship between demand, revenue generation, and product costs.

Sales performance can be further compared across:

- SKUs
- Warehouses
- Regions
- Time periods

This allows areas with stronger sales contribution to be identified.

---

## 4. Demand Insights

Demand is primarily represented by the Units_Sold variable.

The analysis evaluates demand across:

- Time
- SKU
- Warehouse
- Region
- Promotion status

This makes it possible to identify high-demand products and operational locations handling greater volumes of demand.

Demand analysis is particularly important because inventory decisions should ultimately reflect expected product movement.

---

## 5. Inventory Insights

Inventory performance is evaluated using:

- Inventory Level
- Inventory Value
- Reorder Point
- Inventory Coverage Days
- Inventory-to-Demand Ratio
- Supplier Lead Time

Inventory value provides a financial measure of the capital represented by available stock.

Inventory coverage provides an operational measure of how long available inventory may support observed demand.

Together, these metrics provide a more complete picture than inventory quantity alone.

---

## 6. Reorder Risk

One of the main findings from the analysis is the presence of records where inventory is below the defined reorder point.

The project defines reorder risk as:

Inventory Level < Reorder Point

The analysis identified:

- Records below reorder point: 4,787
- Total records: 91,250
- Reorder risk: approximately 5.25%

This indicates that a measurable portion of the observed supply-chain records may require replenishment attention.

The reorder-risk metric should be interpreted as an operational risk indicator rather than confirmation that an actual stockout will occur.

---

## 7. Inventory Coverage and Supplier Lead Time

Inventory coverage is compared with supplier lead time to identify situations where available inventory may not adequately cover the expected replenishment period.

The project uses:

Coverage_Below_Lead_Time

to identify such observations.

A low inventory coverage relative to supplier lead time can represent increased operational risk because replenishment may arrive after the available inventory has been depleted.

This metric is therefore useful for prioritizing inventory monitoring.

---

## 8. Stockout Insights

The dataset contains a Stockout_Flag that identifies observations associated with stockout conditions.

Stockout records are aggregated in the PostgreSQL analysis to provide an operational availability indicator.

Stockouts are particularly important because they can indicate that inventory planning or replenishment was insufficient to meet observed demand.

Further analysis can focus on:

- Which SKUs experience stockouts
- Which warehouses experience stockouts
- Which regions experience stockouts
- Whether stockouts are associated with low inventory coverage

---

## 9. SKU-Level Insights

SKU-level analysis compares products using:

- Units Sold
- Sales Value
- Inventory Level
- Inventory Value
- Reorder Risk
- Inventory Coverage

This allows SKUs to be categorized according to their operational importance.

For example:

- High-demand SKUs may require closer replenishment monitoring.
- High-sales SKUs may have greater financial importance.
- Low-coverage SKUs may require additional inventory attention.
- SKUs frequently below the reorder point may represent recurring replenishment risk.

---

## 10. Warehouse-Level Insights

Warehouse performance is evaluated using:

- Units Sold
- Sales
- Inventory
- Inventory Value
- Reorder Risk
- Stockout Observations
- Inventory Coverage

Comparing these metrics across warehouses helps identify differences in operational performance.

A warehouse with high demand and high reorder risk may require different planning attention from a warehouse with lower demand and higher inventory coverage.

---

## 11. Regional Insights

Regional analysis evaluates:

- Sales
- Units Sold
- Inventory
- Inventory-related indicators

This provides a geographic perspective on supply-chain performance.

Regional comparisons can help identify areas with:

- Higher demand
- Higher sales contribution
- Higher inventory exposure
- Greater operational risk

---

## 12. Supplier Insights

Supplier performance is primarily evaluated through supplier lead time.

The analysis examines:

- Average supplier lead time
- Supplier-level lead-time differences
- Inventory coverage relative to supplier lead time
- Potential supply-related risk

Suppliers associated with longer lead times may require greater inventory planning attention because replenishment requires more time.

However, lead time alone should not be interpreted as poor supplier performance without considering demand and inventory conditions.

---

## 13. Promotion and Demand

The dataset contains a Promotion_Flag that indicates whether a promotion was active.

Demand is compared between:

- Promotion observations
- Non-promotion observations

The analysis indicates that demand differs between promotional and non-promotional observations.

This suggests an association between promotional activity and observed demand levels.

However, the result should not be interpreted as causal evidence because the analysis does not control for other factors that could influence demand.

---

## 14. Key Operational Takeaways

The major operational insights from the project are:

### 1. Reorder monitoring is important

A measurable portion of records falls below the defined reorder point.

### 2. Inventory quantity alone is not sufficient

Inventory should be evaluated together with demand, inventory coverage, and supplier lead time.

### 3. Demand varies across business dimensions

SKU, warehouse, region, and promotion status can be used to identify differences in observed demand.

### 4. Supplier lead time affects replenishment planning

Longer lead times increase the importance of maintaining adequate inventory coverage.

### 5. Financial and operational metrics should be analyzed together

Sales, COGS, gross profit, inventory value, demand, and inventory risk provide complementary perspectives on supply-chain performance.

---

## 15. Business Recommendations

Based on the analysis, the following actions can be considered.

### Prioritize Reorder-Risk Records

Records below the reorder point should receive additional monitoring, particularly when inventory coverage is also below supplier lead time.

### Monitor High-Demand SKUs

High-demand products should receive closer inventory monitoring because demand fluctuations can increase stockout risk.

### Consider Supplier Lead Time During Replenishment Planning

Reorder decisions should account for supplier lead time rather than relying only on current inventory levels.

### Monitor Warehouse-Level Differences

Warehouses with higher demand or higher reorder risk may require differentiated inventory planning.

### Evaluate Promotional Demand Carefully

Promotional periods should be considered when interpreting demand patterns and planning inventory.

---

## 16. Limitations

The findings should be interpreted within the limitations of the available dataset and methodology.

Important limitations include:

- The analysis is observational.
- Promotional demand differences do not establish causality.
- Reorder risk indicates that inventory is below the defined threshold but does not guarantee a stockout.
- Supplier lead time alone does not measure overall supplier quality.
- Historical demand patterns do not guarantee future demand.
- The analysis does not currently include external factors such as holidays, weather, market conditions, or supplier disruptions.

---

## 17. Future Analysis

Future improvements can include:

- Time-series demand forecasting
- More advanced inventory optimization
- Safety-stock calculations
- Economic order quantity analysis
- Supplier performance scoring
- Automated reorder recommendations
- Advanced stockout prediction
- Power BI dashboards
- Automated reporting

---

## 18. Conclusion

The Supply Chain & Inventory Analytics project demonstrates how operational supply-chain data can be transformed into business-oriented insights using Python and PostgreSQL.

The analysis provides visibility into:

- Financial performance
- Demand
- Inventory
- Reorder risk
- Stockouts
- Supplier lead times
- SKU performance
- Warehouse performance
- Regional performance

The PostgreSQL analytical layer makes these insights reusable for future reporting and dashboard development.

The current project therefore provides a foundation that can be extended with advanced analytics, forecasting, optimization, and Power BI reporting.