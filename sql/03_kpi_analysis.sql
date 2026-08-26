-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- 03 - KPI ANALYSIS
-- PostgreSQL
-- ============================================================
--
-- Purpose:
-- Calculate the major business KPIs used throughout the project.
--
-- KPI definitions are aligned with:
-- 01_data_profiling.ipynb
-- 02_business_analysis.ipynb
-- 02_data_quality.sql
--
-- Main analysis areas:
--   1. Executive KPIs
--   2. Inventory KPIs
--   3. Demand KPIs
--   4. Replenishment KPIs
--   5. Financial KPIs
--   6. Stockout KPIs
--   7. Promotion Analysis
--   8. Warehouse Analysis
--   9. Supplier Analysis
--  10. Region Analysis
--  11. SKU Analysis
--  12. Inventory Coverage
--  13. Potential Overstock
-- ============================================================


-- ============================================================
-- 1. EXECUTIVE KPI SUMMARY
-- ============================================================
--
-- This is the main high-level KPI query.
--
-- These metrics are intended to be used later in Power BI
-- or other reporting tools.
-- ============================================================

SELECT

    -- --------------------------------------------------------
    -- Dataset / Business Dimensions
    -- --------------------------------------------------------

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id) AS total_skus,

    COUNT(DISTINCT warehouse_id) AS total_warehouses,

    COUNT(DISTINCT supplier_id) AS total_suppliers,

    COUNT(DISTINCT region) AS total_regions,


    -- --------------------------------------------------------
    -- Demand
    -- --------------------------------------------------------

    SUM(units_sold) AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,


    -- --------------------------------------------------------
    -- Financial Performance
    -- --------------------------------------------------------

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


    -- --------------------------------------------------------
    -- Inventory
    -- --------------------------------------------------------

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


    -- --------------------------------------------------------
    -- Replenishment Risk
    -- --------------------------------------------------------

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


    -- --------------------------------------------------------
    -- Stockout
    -- --------------------------------------------------------

    SUM(stockout_flag) AS stockout_records,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage,


    -- --------------------------------------------------------
    -- Supplier
    -- --------------------------------------------------------

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_supplier_lead_time_days

FROM supply_chain_inventory;


-- ============================================================
-- 2. INVENTORY KPIs
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

    ROUND(
        MIN(inventory_level),
        2
    ) AS minimum_inventory_level,

    ROUND(
        MAX(inventory_level),
        2
    ) AS maximum_inventory_level,

    ROUND(
        AVG(reorder_point),
        2
    ) AS average_reorder_point,

    ROUND(
        SUM(inventory_level)
        / NULLIF(SUM(units_sold), 0),
        2
    ) AS inventory_to_demand_ratio,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days

FROM supply_chain_inventory;


-- ============================================================
-- 3. DEMAND KPIs
-- ============================================================

SELECT

    SUM(units_sold) AS total_units_sold,

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

    MIN(units_sold) AS minimum_daily_demand,

    MAX(units_sold) AS maximum_daily_demand,

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
-- 4. REORDER RISK ANALYSIS
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
-- 5. COVERAGE / REPLENISHMENT RISK
-- ============================================================
--
-- Coverage is based on:
--
-- Inventory Level / Demand Forecast
--
-- Coverage risk occurs when:
--
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
-- 6. PROCUREMENT KPIs
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
-- 7. FINANCIAL KPIs
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
-- 8. STOCKOUT KPIs
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
-- 9. PROMOTION ANALYSIS
-- ============================================================

SELECT

    promotion_flag,

    COUNT(*) AS records,

    SUM(units_sold) AS total_units_sold,

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
-- 10. WAREHOUSE PERFORMANCE
-- ============================================================

SELECT

    warehouse_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id) AS total_skus,

    SUM(units_sold) AS total_units_sold,

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
-- 11. REGION PERFORMANCE
-- ============================================================

SELECT

    region,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id) AS total_skus,

    SUM(units_sold) AS total_units_sold,

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
-- 12. SUPPLIER PERFORMANCE
-- ============================================================

SELECT

    supplier_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id) AS total_skus,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_lead_time_days,

    MIN(supplier_lead_time_days)
        AS minimum_lead_time_days,

    MAX(supplier_lead_time_days)
        AS maximum_lead_time_days,

    SUM(units_sold) AS total_units_sold,

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
-- 13. SUPPLIER PRIORITY ANALYSIS
-- ============================================================
--
-- A supplier is considered a potential priority when:
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
-- 14. SKU PERFORMANCE
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
-- 15. TOP 10 SKUs BY REORDER RISK
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
-- 16. INVENTORY COVERAGE BY SKU
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
-- 17. POTENTIAL OVERSTOCK SCREENING
-- ============================================================
--
-- Analytical assumption:
--
-- Inventory coverage > 30 days
--
-- is flagged as potential overstock.
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
-- 18. HIGH INVENTORY / LOW DEMAND SCREENING
-- ============================================================
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
    s.average_daily_demand < t.average_demand_threshold

    AND

    s.average_inventory_coverage_days
        > t.average_coverage_threshold

ORDER BY
    s.average_inventory_coverage_days DESC;


-- ============================================================
-- 19. DAILY PERFORMANCE
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
-- 20. MONTHLY PERFORMANCE
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
-- 21. MONTHLY SALES TREND
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
-- 22. FINAL KPI CHECK
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