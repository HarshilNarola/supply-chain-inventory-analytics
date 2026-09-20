-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- 03 - KPI ANALYSIS
-- PostgreSQL
-- ============================================================
-- Purpose:
-- 1. Create derived / feature-engineered columns
-- 2. Calculate major business KPIs
-- 3. Analyze inventory, demand, replenishment, finance,
--    stockouts, promotions, warehouses, suppliers, regions,
--    and SKUs.
--
-- Workflow:
--
-- 01_create_table.sql
--        ↓
-- Raw CSV data
--        ↓
-- 02_data_quality.sql
--        ↓
-- 03_kpi_analysis.sql
--        ↓
-- Feature Engineering
--        ↓
-- KPI Analysis
--        ↓
-- 04_analytical_views.sql
-- ============================================================


-- ============================================================
-- 1. FEATURE ENGINEERING
-- ============================================================


-- ------------------------------------------------------------
-- 1.1 DATE-DERIVED COLUMNS
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS year INTEGER;

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS month INTEGER;

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS month_name VARCHAR(20);


UPDATE supply_chain_inventory
SET
    year = EXTRACT(YEAR FROM date)::INTEGER,
    month = EXTRACT(MONTH FROM date)::INTEGER,
    month_name = TO_CHAR(date, 'Mon');


-- ------------------------------------------------------------
-- 1.2 REORDER RISK
--
-- TRUE when inventory is below the reorder point.
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS below_reorder_point BOOLEAN;


UPDATE supply_chain_inventory
SET below_reorder_point =
    inventory_level < reorder_point;


-- ------------------------------------------------------------
-- 1.3 INVENTORY GAP
--
-- Positive value:
-- Inventory is below reorder point.
--
-- Negative value:
-- Inventory is above reorder point.
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS inventory_gap INTEGER;


UPDATE supply_chain_inventory
SET inventory_gap =
    reorder_point - inventory_level;


-- ------------------------------------------------------------
-- 1.4 INVENTORY COVERAGE DAYS
--
-- Formula:
--
-- Inventory Coverage Days =
-- Inventory Level / Demand Forecast
--
-- If demand forecast is zero, return NULL.
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS inventory_coverage_days NUMERIC(12,2);


UPDATE supply_chain_inventory
SET inventory_coverage_days =
    CASE
        WHEN demand_forecast = 0 THEN NULL
        ELSE ROUND(
            inventory_level::NUMERIC
            / demand_forecast,
            2
        )
    END;


-- ------------------------------------------------------------
-- 1.5 COVERAGE BELOW SUPPLIER LEAD TIME
--
-- TRUE when inventory coverage is lower than
-- supplier lead time.
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS coverage_below_lead_time BOOLEAN;


UPDATE supply_chain_inventory
SET coverage_below_lead_time =
    CASE
        WHEN inventory_coverage_days IS NULL THEN NULL
        ELSE inventory_coverage_days
             < supplier_lead_time_days
    END;


-- ------------------------------------------------------------
-- 1.6 INVENTORY VALUE
--
-- Formula:
--
-- Inventory Value =
-- Inventory Level × Unit Cost
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS inventory_value NUMERIC(14,2);


UPDATE supply_chain_inventory
SET inventory_value =
    ROUND(
        inventory_level::NUMERIC * unit_cost,
        2
    );


-- ------------------------------------------------------------
-- 1.7 SALES VALUE
--
-- Formula:
--
-- Sales Value =
-- Units Sold × Unit Price
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS sales_value NUMERIC(14,2);


UPDATE supply_chain_inventory
SET sales_value =
    ROUND(
        units_sold::NUMERIC * unit_price,
        2
    );


-- ------------------------------------------------------------
-- 1.8 COGS
--
-- Formula:
--
-- COGS =
-- Units Sold × Unit Cost
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS cogs NUMERIC(14,2);


UPDATE supply_chain_inventory
SET cogs =
    ROUND(
        units_sold::NUMERIC * unit_cost,
        2
    );


-- ------------------------------------------------------------
-- 1.9 INVENTORY-TO-DEMAND RATIO
--
-- Formula:
--
-- Inventory Level / Units Sold
--
-- If Units Sold = 0, return NULL.
-- ------------------------------------------------------------

ALTER TABLE supply_chain_inventory
ADD COLUMN IF NOT EXISTS inventory_to_demand_ratio NUMERIC(12,2);


UPDATE supply_chain_inventory
SET inventory_to_demand_ratio =
    CASE
        WHEN units_sold = 0 THEN NULL
        ELSE ROUND(
            inventory_level::NUMERIC
            / units_sold,
            2
        )
    END;


-- ============================================================
-- 2. VERIFY FEATURE ENGINEERING
-- ============================================================

SELECT
    date,
    sku_id,
    inventory_level,
    reorder_point,
    demand_forecast,

    below_reorder_point,

    inventory_gap,

    inventory_coverage_days,

    coverage_below_lead_time,

    inventory_value,

    sales_value,

    cogs,

    inventory_to_demand_ratio

FROM supply_chain_inventory

LIMIT 10;


-- ============================================================
-- 3. EXECUTIVE KPI SUMMARY
-- ============================================================

SELECT

    -- Dataset / Business Dimensions

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id) AS total_skus,

    COUNT(DISTINCT warehouse_id) AS total_warehouses,

    COUNT(DISTINCT supplier_id) AS total_suppliers,

    COUNT(DISTINCT region) AS total_regions,


    -- Demand

    SUM(units_sold) AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,


    -- Financial Performance

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(sales_value - cogs)
        / NULLIF(SUM(sales_value), 0)
        * 100,
        2
    ) AS gross_margin_percentage,


    -- Inventory

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,


    -- Replenishment Risk

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,


    -- Stockout

    SUM(stockout_flag) AS stockout_records,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage,


    -- Supplier

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_supplier_lead_time_days

FROM supply_chain_inventory;


-- ============================================================
-- 4. INVENTORY KPIs
-- ============================================================

SELECT

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    MIN(inventory_level)
        AS minimum_inventory_level,

    MAX(inventory_level)
        AS maximum_inventory_level,

    ROUND(
        AVG(reorder_point),
        2
    ) AS average_reorder_point,

    ROUND(
        SUM(inventory_level)::NUMERIC
        / NULLIF(SUM(units_sold), 0),
        2
    ) AS inventory_to_demand_ratio,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days

FROM supply_chain_inventory;


-- ============================================================
-- 5. DEMAND KPIs
-- ============================================================

SELECT

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY units_sold
        ),
        2
    ) AS median_daily_demand,

    MIN(units_sold)
        AS minimum_daily_demand,

    MAX(units_sold)
        AS maximum_daily_demand,

    ROUND(
        STDDEV(units_sold),
        2
    ) AS demand_standard_deviation,

    ROUND(
        AVG(demand_forecast),
        2
    ) AS average_demand_forecast

FROM supply_chain_inventory;


-- ============================================================
-- 6. REORDER RISK ANALYSIS
-- ============================================================

SELECT

    COUNT(*) FILTER (
        WHERE inventory_level < reorder_point
    ) AS records_below_reorder_point,

    COUNT(*) AS total_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE inventory_level < reorder_point
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(inventory_gap),
        2
    ) AS average_inventory_gap

FROM supply_chain_inventory;


-- ============================================================
-- 7. COVERAGE / REPLENISHMENT RISK
--
-- Coverage:
-- Inventory Level / Demand Forecast
--
-- Coverage risk:
-- Inventory Coverage Days < Supplier Lead Time Days
-- ============================================================

SELECT

    COUNT(*) FILTER (
        WHERE coverage_below_lead_time = TRUE
    ) AS coverage_risk_records,

    COUNT(*) AS total_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE coverage_below_lead_time = TRUE
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS coverage_risk_percentage,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_supplier_lead_time_days

FROM supply_chain_inventory;


-- ============================================================
-- 8. PROCUREMENT KPIs
-- ============================================================

SELECT

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_supplier_lead_time_days,

    MIN(supplier_lead_time_days)
        AS minimum_supplier_lead_time_days,

    MAX(supplier_lead_time_days)
        AS maximum_supplier_lead_time_days,

    ROUND(
        AVG(order_quantity),
        2
    ) AS average_order_quantity,

    SUM(order_quantity)
        AS total_order_quantity

FROM supply_chain_inventory;


-- ============================================================
-- 9. FINANCIAL KPIs
-- ============================================================

SELECT

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(sales_value - cogs)
        / NULLIF(SUM(sales_value), 0)
        * 100,
        2
    ) AS gross_margin_percentage,

    ROUND(
        AVG(unit_price - unit_cost),
        2
    ) AS average_profit_per_unit,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value

FROM supply_chain_inventory;


-- ============================================================
-- 10. STOCKOUT KPIs
-- ============================================================

SELECT

    SUM(stockout_flag)
        AS stockout_records,

    COUNT(*)
        AS total_records,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage,

    SUM(units_sold) FILTER (
        WHERE stockout_flag = 1
    ) AS units_sold_during_stockout_records

FROM supply_chain_inventory;


-- ============================================================
-- 11. PROMOTION ANALYSIS
-- ============================================================

SELECT

    promotion_flag,

    COUNT(*) AS records,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        AVG(unit_price),
        2
    ) AS average_unit_price,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit

FROM supply_chain_inventory

GROUP BY promotion_flag

ORDER BY promotion_flag;


-- ============================================================
-- 12. WAREHOUSE PERFORMANCE
-- ============================================================

SELECT

    warehouse_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS total_skus,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY warehouse_id

ORDER BY reorder_risk_percentage DESC;


-- ============================================================
-- 13. REGION PERFORMANCE
-- ============================================================

SELECT

    region,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS total_skus,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(sales_value - cogs)
        / NULLIF(SUM(sales_value), 0)
        * 100,
        2
    ) AS gross_margin_percentage,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY region

ORDER BY total_sales DESC;


-- ============================================================
-- 14. SUPPLIER PERFORMANCE
-- ============================================================

SELECT

    supplier_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS total_skus,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_lead_time_days,

    MIN(supplier_lead_time_days)
        AS minimum_lead_time_days,

    MAX(supplier_lead_time_days)
        AS maximum_lead_time_days,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(reorder_point),
        2
    ) AS average_reorder_point,

    ROUND(
        AVG(inventory_gap),
        2
    ) AS average_inventory_gap,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY supplier_id

ORDER BY reorder_risk_percentage DESC;


-- ============================================================
-- 15. SUPPLIER PRIORITY ANALYSIS
--
-- Potential priority supplier:
--
-- Average Lead Time > Overall Average Lead Time
-- AND
-- Reorder Risk > Overall Average Reorder Risk
--
-- This is an analytical prioritization, not a formal
-- supplier-performance rating.
-- ============================================================

WITH supplier_metrics AS (

    SELECT

        supplier_id,

        AVG(supplier_lead_time_days)
            AS average_lead_time_days,

        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100
            AS reorder_risk_percentage,

        SUM(units_sold)
            AS total_units_sold,

        AVG(inventory_level)
            AS average_inventory_level

    FROM supply_chain_inventory

    GROUP BY supplier_id
),

overall_metrics AS (

    SELECT

        AVG(average_lead_time_days)
            AS overall_average_lead_time,

        AVG(reorder_risk_percentage)
            AS overall_average_reorder_risk

    FROM supplier_metrics
)

SELECT

    s.supplier_id,

    ROUND(
        s.average_lead_time_days,
        2
    ) AS average_lead_time_days,

    ROUND(
        s.reorder_risk_percentage,
        2
    ) AS reorder_risk_percentage,

    s.total_units_sold,

    ROUND(
        s.average_inventory_level,
        2
    ) AS average_inventory_level,

    CASE

        WHEN
            s.average_lead_time_days
            > o.overall_average_lead_time

            AND

            s.reorder_risk_percentage
            > o.overall_average_reorder_risk

        THEN TRUE

        ELSE FALSE

    END AS priority_flag

FROM supplier_metrics s

CROSS JOIN overall_metrics o

ORDER BY
    priority_flag DESC,
    reorder_risk_percentage DESC;


-- ============================================================
-- 16. SKU PERFORMANCE
-- ============================================================

SELECT

    sku_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT warehouse_id)
        AS warehouse_count,

    COUNT(DISTINCT supplier_id)
        AS supplier_count,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        STDDEV(units_sold),
        2
    ) AS demand_standard_deviation,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY sku_id

ORDER BY total_sales DESC;


-- ============================================================
-- 17. TOP 10 SKUs BY REORDER RISK
-- ============================================================

SELECT

    sku_id,

    COUNT(*) AS total_records,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(reorder_point),
        2
    ) AS average_reorder_point,

    ROUND(
        AVG(inventory_gap),
        2
    ) AS average_inventory_gap,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage

FROM supply_chain_inventory

GROUP BY sku_id

ORDER BY reorder_risk_percentage DESC

LIMIT 10;


-- ============================================================
-- 18. INVENTORY COVERAGE BY SKU
-- ============================================================

SELECT

    sku_id,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(demand_forecast),
        2
    ) AS average_demand_forecast,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_supplier_lead_time_days,

    ROUND(
        AVG(
            CASE
                WHEN coverage_below_lead_time = TRUE
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS coverage_risk_percentage

FROM supply_chain_inventory

GROUP BY sku_id

ORDER BY average_inventory_coverage_days DESC;


-- ============================================================
-- 19. POTENTIAL OVERSTOCK SCREENING
--
-- Analytical assumption:
--
-- Inventory Coverage > 30 days
-- = Potential Overstock
--
-- This is NOT a formal business rule.
-- It should be validated against actual inventory policy.
-- ============================================================

SELECT

    sku_id,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(demand_forecast),
        2
    ) AS average_demand_forecast,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    CASE

        WHEN AVG(inventory_coverage_days) > 30
        THEN TRUE

        ELSE FALSE

    END AS potential_overstock

FROM supply_chain_inventory

GROUP BY sku_id

ORDER BY average_inventory_coverage_days DESC;


-- ============================================================
-- 20. HIGH INVENTORY / LOW DEMAND SCREENING
--
-- Identifies SKUs whose inventory coverage is high while
-- demand is relatively low.
--
-- This is an exploratory screening query.
-- ============================================================

WITH sku_metrics AS (

    SELECT

        sku_id,

        AVG(inventory_level)
            AS average_inventory_level,

        AVG(units_sold)
            AS average_daily_demand,

        AVG(inventory_coverage_days)
            AS average_inventory_coverage_days,

        SUM(inventory_value)
            AS total_inventory_value,

        SUM(units_sold)
            AS total_units_sold

    FROM supply_chain_inventory

    GROUP BY sku_id
),

thresholds AS (

    SELECT

        AVG(average_daily_demand)
            AS average_demand_threshold,

        AVG(average_inventory_coverage_days)
            AS average_coverage_threshold

    FROM sku_metrics
)

SELECT

    s.sku_id,

    ROUND(
        s.average_inventory_level,
        2
    ) AS average_inventory_level,

    ROUND(
        s.average_daily_demand,
        2
    ) AS average_daily_demand,

    ROUND(
        s.average_inventory_coverage_days,
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        s.total_inventory_value,
        2
    ) AS total_inventory_value,

    s.total_units_sold

FROM sku_metrics s

CROSS JOIN thresholds t

WHERE

    s.average_daily_demand
    < t.average_demand_threshold

    AND

    s.average_inventory_coverage_days
    > t.average_coverage_threshold

ORDER BY
    s.average_inventory_coverage_days DESC;


-- ============================================================
-- 21. DAILY PERFORMANCE
-- ============================================================

SELECT

    date,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY date

ORDER BY date;


-- ============================================================
-- 22. MONTHLY PERFORMANCE
-- ============================================================

SELECT

    year,

    month,

    month_name,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY
    year,
    month,
    month_name

ORDER BY
    year,
    month;


-- ============================================================
-- 23. MONTHLY SALES TREND
-- ============================================================

SELECT

    year,

    month,

    month_name,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales

FROM supply_chain_inventory

GROUP BY
    year,
    month,
    month_name

ORDER BY
    year,
    month;


-- ============================================================
-- 24. FINAL KPI CHECK
--
-- Compact output for quick verification.
-- ============================================================

SELECT

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS total_skus,

    COUNT(DISTINCT warehouse_id)
        AS total_warehouses,

    COUNT(DISTINCT supplier_id)
        AS total_suppliers,

    COUNT(DISTINCT region)
        AS total_regions,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit,

    ROUND(
        SUM(sales_value - cogs)
        / NULLIF(SUM(sales_value), 0)
        * 100,
        2
    ) AS gross_margin_percentage,

    ROUND(
        SUM(inventory_value),
        2
    ) AS total_inventory_value,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(
            CASE
                WHEN inventory_level < reorder_point
                THEN 1.0
                ELSE 0.0
            END
        ) * 100,
        2
    ) AS reorder_risk_percentage,

    SUM(stockout_flag)
        AS stockout_records,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_supplier_lead_time_days

FROM supply_chain_inventory;