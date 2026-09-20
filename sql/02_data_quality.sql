-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- 02 - DATA QUALITY VALIDATION
-- PostgreSQL
-- ============================================================
-- Purpose:
-- Validate the raw supply-chain dataset for:
-- structure, completeness, duplicates, valid ranges,
-- flag values, date coverage, and business dimensions.
--
-- IMPORTANT:
-- This file validates ONLY the raw CSV columns.
--
-- Derived / analytical columns are created later in:
-- 03_kpi_analysis.sql
-- ============================================================


-- ============================================================
-- 1. TOTAL RECORD COUNT
-- ============================================================

SELECT
    COUNT(*) AS total_records
FROM supply_chain_inventory;


-- ============================================================
-- 2. CHECK FOR NULL VALUES
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE date IS NULL) AS null_date,

    COUNT(*) FILTER (WHERE sku_id IS NULL) AS null_sku_id,

    COUNT(*) FILTER (WHERE warehouse_id IS NULL) AS null_warehouse_id,

    COUNT(*) FILTER (WHERE supplier_id IS NULL) AS null_supplier_id,

    COUNT(*) FILTER (WHERE region IS NULL) AS null_region,

    COUNT(*) FILTER (WHERE units_sold IS NULL) AS null_units_sold,

    COUNT(*) FILTER (
        WHERE inventory_level IS NULL
    ) AS null_inventory_level,

    COUNT(*) FILTER (
        WHERE supplier_lead_time_days IS NULL
    ) AS null_lead_time,

    COUNT(*) FILTER (
        WHERE reorder_point IS NULL
    ) AS null_reorder_point,

    COUNT(*) FILTER (
        WHERE order_quantity IS NULL
    ) AS null_order_quantity,

    COUNT(*) FILTER (
        WHERE unit_cost IS NULL
    ) AS null_unit_cost,

    COUNT(*) FILTER (
        WHERE unit_price IS NULL
    ) AS null_unit_price,

    COUNT(*) FILTER (
        WHERE promotion_flag IS NULL
    ) AS null_promotion_flag,

    COUNT(*) FILTER (
        WHERE stockout_flag IS NULL
    ) AS null_stockout_flag,

    COUNT(*) FILTER (
        WHERE demand_forecast IS NULL
    ) AS null_demand_forecast

FROM supply_chain_inventory;


-- ============================================================
-- 3. CHECK DUPLICATE BUSINESS KEYS
--
-- Expected business grain:
-- Date + SKU_ID + Warehouse_ID
-- ============================================================

SELECT
    date,
    sku_id,
    warehouse_id,
    COUNT(*) AS duplicate_count

FROM supply_chain_inventory

GROUP BY
    date,
    sku_id,
    warehouse_id

HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC;


-- ============================================================
-- 4. COUNT DUPLICATE BUSINESS-KEY GROUPS
-- ============================================================

SELECT
    COUNT(*) AS duplicate_business_key_groups

FROM (
    SELECT
        date,
        sku_id,
        warehouse_id

    FROM supply_chain_inventory

    GROUP BY
        date,
        sku_id,
        warehouse_id

    HAVING COUNT(*) > 1
) AS duplicate_keys;


-- ============================================================
-- 5. CHECK FOR NEGATIVE VALUES
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE units_sold < 0
    ) AS negative_units_sold,

    COUNT(*) FILTER (
        WHERE inventory_level < 0
    ) AS negative_inventory_level,

    COUNT(*) FILTER (
        WHERE supplier_lead_time_days < 0
    ) AS negative_lead_time,

    COUNT(*) FILTER (
        WHERE reorder_point < 0
    ) AS negative_reorder_point,

    COUNT(*) FILTER (
        WHERE order_quantity < 0
    ) AS negative_order_quantity,

    COUNT(*) FILTER (
        WHERE unit_cost < 0
    ) AS negative_unit_cost,

    COUNT(*) FILTER (
        WHERE unit_price < 0
    ) AS negative_unit_price,

    COUNT(*) FILTER (
        WHERE demand_forecast < 0
    ) AS negative_demand_forecast

FROM supply_chain_inventory;


-- ============================================================
-- 6. CHECK FLAG VALUES
--
-- Promotion_Flag and Stockout_Flag
-- should contain only 0 or 1.
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE promotion_flag NOT IN (0, 1)
    ) AS invalid_promotion_flags,

    COUNT(*) FILTER (
        WHERE stockout_flag NOT IN (0, 1)
    ) AS invalid_stockout_flags

FROM supply_chain_inventory;


-- ============================================================
-- 7. FLAG VALUE DISTRIBUTION
-- ============================================================

SELECT
    promotion_flag,
    COUNT(*) AS record_count

FROM supply_chain_inventory

GROUP BY promotion_flag

ORDER BY promotion_flag;


SELECT
    stockout_flag,
    COUNT(*) AS record_count

FROM supply_chain_inventory

GROUP BY stockout_flag

ORDER BY stockout_flag;


-- ============================================================
-- 8. CHECK DATE RANGE
-- ============================================================

SELECT
    MIN(date) AS minimum_date,
    MAX(date) AS maximum_date,
    COUNT(DISTINCT date) AS unique_dates

FROM supply_chain_inventory;


-- ============================================================
-- 9. CHECK BUSINESS DIMENSION COUNTS
-- ============================================================

SELECT
    COUNT(DISTINCT sku_id) AS total_skus,

    COUNT(DISTINCT warehouse_id) AS total_warehouses,

    COUNT(DISTINCT supplier_id) AS total_suppliers,

    COUNT(DISTINCT region) AS total_regions

FROM supply_chain_inventory;


-- ============================================================
-- 10. CHECK REGION DISTRIBUTION
-- ============================================================

SELECT
    region,
    COUNT(*) AS record_count

FROM supply_chain_inventory

GROUP BY region

ORDER BY record_count DESC;


-- ============================================================
-- 11. CHECK NUMERICAL DATA RANGES
-- ============================================================

SELECT
    MIN(units_sold) AS min_units_sold,
    MAX(units_sold) AS max_units_sold,

    MIN(inventory_level) AS min_inventory_level,
    MAX(inventory_level) AS max_inventory_level,

    MIN(supplier_lead_time_days) AS min_lead_time,
    MAX(supplier_lead_time_days) AS max_lead_time,

    MIN(reorder_point) AS min_reorder_point,
    MAX(reorder_point) AS max_reorder_point,

    MIN(order_quantity) AS min_order_quantity,
    MAX(order_quantity) AS max_order_quantity,

    MIN(unit_cost) AS min_unit_cost,
    MAX(unit_cost) AS max_unit_cost,

    MIN(unit_price) AS min_unit_price,
    MAX(unit_price) AS max_unit_price,

    MIN(demand_forecast) AS min_demand_forecast,
    MAX(demand_forecast) AS max_demand_forecast

FROM supply_chain_inventory;


-- ============================================================
-- 12. CHECK DISTINCT BUSINESS DIMENSION VALUES
-- ============================================================

SELECT
    COUNT(DISTINCT sku_id) AS unique_skus,
    COUNT(DISTINCT warehouse_id) AS unique_warehouses,
    COUNT(DISTINCT supplier_id) AS unique_suppliers,
    COUNT(DISTINCT region) AS unique_regions,
    COUNT(DISTINCT date) AS unique_dates

FROM supply_chain_inventory;


-- ============================================================
-- 13. CHECK PRICE VS COST
--
-- This is an informational business check.
-- A price below cost may occur because of promotions
-- or pricing decisions, so it is NOT treated as
-- a data-quality error.
-- ============================================================

SELECT
    COUNT(*) AS records_where_price_below_cost,

    ROUND(
        COUNT(*) * 100.0
        / NULLIF(
            (SELECT COUNT(*)
             FROM supply_chain_inventory),
            0
        ),
        2
    ) AS percentage_price_below_cost

FROM supply_chain_inventory

WHERE unit_price < unit_cost;


-- ============================================================
-- 14. CHECK STOCKOUT RECORDS
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE stockout_flag = 1
    ) AS stockout_records,

    COUNT(*) AS total_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE stockout_flag = 1
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS stockout_rate_percentage

FROM supply_chain_inventory;


-- ============================================================
-- 15. FINAL RAW DATA QUALITY SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT sku_id) AS total_skus,

    COUNT(DISTINCT warehouse_id) AS total_warehouses,

    COUNT(DISTINCT supplier_id) AS total_suppliers,

    COUNT(DISTINCT region) AS total_regions,

    COUNT(DISTINCT date) AS unique_dates,

    MIN(date) AS data_start_date,

    MAX(date) AS data_end_date,

    COUNT(*) FILTER (
        WHERE units_sold < 0
    ) AS negative_units_sold,

    COUNT(*) FILTER (
        WHERE inventory_level < 0
    ) AS negative_inventory_level,

    COUNT(*) FILTER (
        WHERE promotion_flag NOT IN (0, 1)
    ) AS invalid_promotion_flags,

    COUNT(*) FILTER (
        WHERE stockout_flag NOT IN (0, 1)
    ) AS invalid_stockout_flags,

    COUNT(*) FILTER (
        WHERE stockout_flag = 1
    ) AS stockout_records

FROM supply_chain_inventory;