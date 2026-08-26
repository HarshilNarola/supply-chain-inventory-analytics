# Business Requirements

## 1. Project Overview

The Supply Chain & Inventory Analytics project analyzes operational supply-chain data to understand sales performance, demand patterns, inventory health, reorder risk, supplier lead times, warehouse performance, and regional performance.

The project combines Python-based exploratory and business analysis with PostgreSQL-based data management and SQL analytics.

The objective is to convert raw supply-chain records into meaningful business metrics and actionable insights.

---

## 2. Business Objective

The primary objective is to evaluate supply-chain and inventory performance and identify areas of operational risk and improvement.

The analysis focuses on:

- Sales and profitability
- Demand patterns
- Inventory levels
- Reorder risk
- Stockout behavior
- Inventory coverage
- Supplier lead times
- Warehouse performance
- SKU performance
- Regional performance
- Promotion and demand relationships

---

## 3. Key Business Questions

### 3.1 Sales and Profitability

1. What is the total sales value?
2. What is the total cost of goods sold (COGS)?
3. What is the gross profit?
4. What is the gross margin percentage?
5. How does sales performance vary over time?
6. Which regions generate the highest sales?

---

### 3.2 Inventory Management

1. What is the total inventory value?
2. What is the average inventory level?
3. How frequently does inventory fall below the reorder point?
4. Which warehouses have higher reorder risk?
5. Which SKUs have higher inventory risk?
6. How many records experience potential stockout conditions?
7. How does inventory coverage compare with supplier lead time?

---

### 3.3 Demand Analysis

1. What is the total number of units sold?
2. What is the average daily demand?
3. Which SKUs have the highest demand?
4. Which warehouses handle the highest demand?
5. Which regions generate the highest demand?
6. How does demand vary over time?
7. Is observed demand different during promotional periods?

---

### 3.4 Supplier Analysis

1. What is the average supplier lead time?
2. Which suppliers have relatively higher lead times?
3. How does supplier lead time relate to inventory coverage?
4. Are there areas where longer lead times may increase inventory risk?

---

### 3.5 Warehouse Analysis

1. Which warehouses have the highest sales?
2. Which warehouses handle the highest unit demand?
3. Which warehouses have higher inventory levels?
4. Which warehouses show greater reorder risk?
5. Are there meaningful differences in operational performance between warehouses?

---

### 3.6 SKU Analysis

1. Which SKUs generate the highest sales?
2. Which SKUs have the highest unit demand?
3. Which SKUs have higher inventory levels?
4. Which SKUs have higher reorder risk?
5. Are there SKUs with relatively low inventory coverage?

---

## 4. Key Business Definitions

### Reorder Risk

A record is considered below the reorder threshold when:

`Inventory Level < Reorder Point`

The reorder risk percentage is calculated as:

`Reorder Risk % = Records Below Reorder Point / Total Records × 100`

In the analyzed dataset, 4,787 records were below the reorder point, corresponding to approximately 5.25% of the records.

---

### Sales Value

Sales value is calculated as:

`Sales Value = Units Sold × Unit Price`

---

### COGS

Cost of goods sold is calculated as:

`COGS = Units Sold × Unit Cost`

---

### Gross Profit

Gross profit is calculated as:

`Gross Profit = Sales Value − COGS`

---

### Gross Margin

Gross margin percentage is calculated as:

`Gross Margin % = Gross Profit / Sales Value × 100`

---

### Inventory Value

Inventory value is calculated as:

`Inventory Value = Inventory Level × Unit Cost`

---

### Inventory Coverage

Inventory coverage estimates the number of days for which the available inventory can support demand based on the observed demand level.

---

## 5. Expected Business Outcomes

The analysis is expected to provide:

- A clear overview of sales and profitability.
- Identification of inventory and reorder risks.
- Identification of high-demand SKUs and warehouses.
- Understanding of supplier lead-time characteristics.
- Comparison of regional and warehouse performance.
- Understanding of promotional demand patterns.
- A reusable PostgreSQL analytical layer for further reporting.

---

## 6. Intended Users

The analysis can support users such as:

- Supply-chain managers
- Inventory planners
- Procurement teams
- Operations managers
- Business analysts
- Management and decision-makers

---

## 7. Future Enhancement

A Power BI dashboard can be added as a future presentation layer using the analytical views already created in PostgreSQL.

The planned dashboard can provide:

- Executive KPIs
- Inventory and reorder-risk monitoring
- Demand and sales analysis
- Warehouse and regional comparisons
