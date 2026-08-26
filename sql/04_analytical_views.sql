-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- 04 - ANALYTICAL VIEWS
-- PostgreSQL
-- ============================================================
--
-- Purpose:
-- Create reusable analytical views for:
--
--   • Executive KPI reporting
--   • Daily trends
--   • Monthly trends
--   • SKU analysis
--   • Warehouse analysis
--   • Supplier analysis
--   • Region analysis
--   • Inventory health
--   • Forecast performance
--   • Promotion analysis
--
-- These views are designed to be reusable by:
--
--   PostgreSQL
--   Power BI
--   Future reporting tools
--
-- Metric definitions are aligned with the finalized
-- Python notebooks and KPI analysis.
-- ============================================================


-- ============================================================
-- 1. EXECUTIVE KPI SUMMARY
-- ============================================================
--
-- IMPORTANT:
-- This view returns ONE ROW.
--
-- It is designed specifically for executive KPI cards
-- and Power BI.
--
-- Examples:
--   Total Sales
--   Total COGS
--   Gross Profit
--   Inventory Value
--   Reorder Risk
--   Stockout Rate
-- ============================================================

CREATE OR REPLACE VIEW vw_business_kpi_summary AS

SELECT

    -- --------------------------------------------------------
    -- Dataset Size
    -- --------------------------------------------------------

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS total_skus,

    COUNT(DISTINCT warehouse_id)
        AS total_warehouses,

    COUNT(DISTINCT supplier_id)
        AS total_suppliers,

    COUNT(DISTINCT region)
        AS total_regions,


    -- --------------------------------------------------------
    -- Demand
    -- --------------------------------------------------------

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,


    -- --------------------------------------------------------
    -- Financial KPIs
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
    -- Inventory KPIs
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
    -- Reorder Risk
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

    SUM(stockout_flag)
        AS stockout_records,

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
-- 2. DAILY PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_daily_performance AS

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

    SUM(stockout_flag)
        AS stockout_records,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY date;


-- ============================================================
-- 3. MONTHLY PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_performance AS

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

    SUM(stockout_flag)
        AS stockout_records,

    ROUND(
        AVG(stockout_flag) * 100,
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory

GROUP BY
    year,
    month,
    month_name;


-- ============================================================
-- 4. SKU PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_sku_performance AS

SELECT

    sku_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT warehouse_id)
        AS number_of_warehouses,

    COUNT(DISTINCT supplier_id)
        AS number_of_suppliers,

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
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

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

GROUP BY sku_id;


-- ============================================================
-- 5. WAREHOUSE PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_warehouse_performance AS

SELECT

    warehouse_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS number_of_skus,

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
    ) AS stockout_rate_percentage,

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

GROUP BY warehouse_id;


-- ============================================================
-- 6. SUPPLIER PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_supplier_performance AS

SELECT

    supplier_id,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS number_of_skus,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_lead_time_days,

    MIN(supplier_lead_time_days)
        AS minimum_lead_time_days,

    MAX(supplier_lead_time_days)
        AS maximum_lead_time_days,

    SUM(order_quantity)
        AS total_order_quantity,

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
    ) AS stockout_rate_percentage,

    ROUND(
        SUM(sales_value),
        2
    ) AS associated_sales

FROM supply_chain_inventory

GROUP BY supplier_id;


-- ============================================================
-- 7. REGION PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_region_performance AS

SELECT

    region,

    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id)
        AS number_of_skus,

    COUNT(DISTINCT warehouse_id)
        AS number_of_warehouses,

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
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

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

GROUP BY region;


-- ============================================================
-- 8. INVENTORY HEALTH
-- ============================================================
--
-- This is a row-level analytical view.
--
-- It provides an easy-to-use inventory status field for
-- reporting and dashboard filtering.
--
-- Priority:
--   1. Reorder Risk
--   2. Low Coverage
--   3. Healthy
-- ============================================================

CREATE OR REPLACE VIEW vw_inventory_health AS

SELECT

    record_id,

    date,

    sku_id,

    warehouse_id,

    supplier_id,

    region,

    units_sold,

    inventory_level,

    reorder_point,

    inventory_gap,

    inventory_coverage_days,

    supplier_lead_time_days,

    demand_forecast,

    below_reorder_point,

    coverage_below_lead_time,

    inventory_value,

    sales_value,

    cogs,

    stockout_flag,

    CASE

        WHEN below_reorder_point = TRUE
            THEN 'Reorder Risk'

        WHEN coverage_below_lead_time = TRUE
            THEN 'Low Coverage'

        ELSE 'Healthy'

    END AS inventory_status

FROM supply_chain_inventory;


-- ============================================================
-- 9. FORECAST PERFORMANCE
-- ============================================================
--
-- Forecast metrics:
--
-- MAE:
-- Average absolute difference between actual demand and
-- forecast demand.
--
-- MAPE:
-- Average percentage error for records where actual demand
-- is greater than zero.
-- ============================================================

CREATE OR REPLACE VIEW vw_forecast_performance AS

SELECT

    sku_id,

    warehouse_id,

    region,

    COUNT(*) AS total_records,

    SUM(units_sold)
        AS total_actual_demand,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_actual_demand,

    ROUND(
        AVG(demand_forecast),
        2
    ) AS average_forecast_demand,

    ROUND(
        AVG(
            ABS(
                units_sold - demand_forecast
            )
        ),
        2
    ) AS mean_absolute_error,

    ROUND(
        AVG(
            CASE
                WHEN units_sold > 0
                THEN
                    ABS(
                        units_sold - demand_forecast
                    )
                    / units_sold
                ELSE NULL
            END
        ) * 100,
        2
    ) AS mape_percentage

FROM supply_chain_inventory

GROUP BY
    sku_id,
    warehouse_id,
    region;


-- ============================================================
-- 10. PROMOTION ANALYSIS
-- ============================================================

CREATE OR REPLACE VIEW vw_promotion_analysis AS

SELECT

    promotion_flag,

    COUNT(*) AS total_records,

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
    ) AS gross_profit,

    ROUND(
        SUM(sales_value - cogs)
        / NULLIF(SUM(sales_value), 0)
        * 100,
        2
    ) AS gross_margin_percentage

FROM supply_chain_inventory

GROUP BY promotion_flag;


-- ============================================================
-- 11. INVENTORY EFFICIENCY BY SKU
-- ============================================================
--
-- Used for identifying potential overstock situations.
--
-- Analytical threshold:
--   Average Coverage > 30 days
--
-- This threshold is an analytical assumption and should not
-- be interpreted as a formal operational policy.
-- ============================================================

CREATE OR REPLACE VIEW vw_inventory_efficiency AS

SELECT

    sku_id,

    ROUND(
        AVG(inventory_level),
        2
    ) AS average_inventory_level,

    ROUND(
        AVG(units_sold),
        2
    ) AS average_daily_demand,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_inventory_coverage_days,

    ROUND(
        AVG(reorder_point),
        2
    ) AS average_reorder_point,

    SUM(units_sold)
        AS total_units_sold,

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

GROUP BY sku_id;


-- ============================================================
-- 12. WAREHOUSE COVERAGE RISK
-- ============================================================

CREATE OR REPLACE VIEW vw_warehouse_coverage_risk AS

SELECT

    warehouse_id,

    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE coverage_below_lead_time = TRUE
    ) AS risky_records,

    ROUND(
        AVG(inventory_coverage_days),
        2
    ) AS average_coverage_days,

    ROUND(
        AVG(supplier_lead_time_days),
        2
    ) AS average_lead_time_days,

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

GROUP BY warehouse_id;


-- ============================================================
-- 13. MONTHLY SALES TREND
-- ============================================================
--
-- A simplified view specifically useful for trend charts.
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_sales_trend AS

SELECT

    year,

    month,

    month_name,

    ROUND(
        SUM(sales_value),
        2
    ) AS total_sales,

    SUM(units_sold)
        AS total_units_sold,

    ROUND(
        SUM(cogs),
        2
    ) AS total_cogs,

    ROUND(
        SUM(sales_value - cogs),
        2
    ) AS gross_profit

FROM supply_chain_inventory

GROUP BY
    year,
    month,
    month_name;


-- ============================================================
-- 14. VIEW VERIFICATION
-- ============================================================
--
-- These queries are intentionally simple so that all views
-- can be checked after the script is executed.
-- ============================================================

SELECT *
FROM vw_business_kpi_summary;


SELECT *
FROM vw_daily_performance
LIMIT 10;


SELECT *
FROM vw_monthly_performance;


SELECT *
FROM vw_sku_performance
LIMIT 10;


SELECT *
FROM vw_warehouse_performance;


SELECT *
FROM vw_supplier_performance;


SELECT *
FROM vw_region_performance;


SELECT *
FROM vw_inventory_health
LIMIT 10;


SELECT *
FROM vw_forecast_performance
LIMIT 10;


SELECT *
FROM vw_promotion_analysis;


SELECT *
FROM vw_inventory_efficiency
LIMIT 10;


SELECT *
FROM vw_warehouse_coverage_risk;


SELECT *
FROM vw_monthly_sales_trend;


-- ============================================================
-- END OF ANALYTICAL VIEWS
-- ============================================================