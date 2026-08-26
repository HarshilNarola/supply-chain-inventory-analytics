-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- 02 - DATA QUALITY VALIDATION
-- PostgreSQL
-- ============================================================
--
-- Purpose:
-- Validate the structure, completeness, consistency, and
-- business logic of the supply_chain_inventory table.
--
-- Metric definitions are aligned with:
-- 01_data_profiling.ipynb
-- 02_business_analysis.ipynb
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
    COUNT(*) FILTER (WHERE inventory_level IS NULL) AS null_inventory_level,
    COUNT(*) FILTER (WHERE demand_forecast IS NULL) AS null_demand_forecast,

    COUNT(*) FILTER (
        WHERE supplier_lead_time_days IS NULL
    ) AS null_lead_time,

    COUNT(*) FILTER (
        WHERE reorder_point IS NULL
    ) AS null_reorder_point,

    COUNT(*) FILTER (
        WHERE order_quantity IS NULL
    ) AS null_order_quantity,

    COUNT(*) FILTER (WHERE unit_cost IS NULL) AS null_unit_cost,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS null_unit_price,

    COUNT(*) FILTER (WHERE promotion_flag IS NULL) AS null_promotion_flag,
    COUNT(*) FILTER (WHERE stockout_flag IS NULL) AS null_stockout_flag,

    COUNT(*) FILTER (WHERE year IS NULL) AS null_year,
    COUNT(*) FILTER (WHERE month IS NULL) AS null_month,
    COUNT(*) FILTER (WHERE month_name IS NULL) AS null_month_name,

    COUNT(*) FILTER (
        WHERE below_reorder_point IS NULL
    ) AS null_below_reorder_point,

    COUNT(*) FILTER (
        WHERE inventory_gap IS NULL
    ) AS null_inventory_gap,

    COUNT(*) FILTER (
        WHERE inventory_coverage_days IS NULL
    ) AS null_inventory_coverage,

    COUNT(*) FILTER (
        WHERE coverage_below_lead_time IS NULL
    ) AS null_coverage_flag,

    COUNT(*) FILTER (
        WHERE inventory_value IS NULL
    ) AS null_inventory_value,

    COUNT(*) FILTER (
        WHERE sales_value IS NULL
    ) AS null_sales_value,

    COUNT(*) FILTER (
        WHERE cogs IS NULL
    ) AS null_cogs,

    COUNT(*) FILTER (
        WHERE inventory_to_demand_ratio IS NULL
    ) AS null_inventory_demand_ratio

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
-- 4. COUNT DUPLICATE BUSINESS-KEY RECORDS
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
-- Promotion_Flag and Stockout_Flag should contain only 0 or 1.
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
-- 9. CHECK DATE-DERIVED COLUMNS
-- ============================================================

SELECT
    COUNT(*) AS incorrect_year

FROM supply_chain_inventory

WHERE year IS DISTINCT FROM EXTRACT(
    YEAR FROM date
)::INTEGER;


SELECT
    COUNT(*) AS incorrect_month

FROM supply_chain_inventory

WHERE month IS DISTINCT FROM EXTRACT(
    MONTH FROM date
)::INTEGER;


SELECT
    COUNT(*) AS incorrect_month_name

FROM supply_chain_inventory

WHERE month_name IS DISTINCT FROM TO_CHAR(
    date,
    'Mon'
);


-- ============================================================
-- 10. CHECK BUSINESS DIMENSION COUNTS
-- ============================================================

SELECT
    COUNT(DISTINCT sku_id) AS total_skus,
    COUNT(DISTINCT warehouse_id) AS total_warehouses,
    COUNT(DISTINCT supplier_id) AS total_suppliers,
    COUNT(DISTINCT region) AS total_regions

FROM supply_chain_inventory;


-- ============================================================
-- 11. CHECK REGION DISTRIBUTION
-- ============================================================

SELECT
    region,
    COUNT(*) AS record_count

FROM supply_chain_inventory

GROUP BY region

ORDER BY record_count DESC;


-- ============================================================
-- 12. CHECK REORDER-RISK LOGIC
--
-- Expected:
-- Below Reorder Point =
-- Inventory Level < Reorder Point
-- ============================================================

SELECT
    COUNT(*) AS incorrect_reorder_flags

FROM supply_chain_inventory

WHERE below_reorder_point IS DISTINCT FROM (
    inventory_level < reorder_point
);


-- ============================================================
-- 13. REORDER-RISK SUMMARY
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
    ) AS reorder_risk_percentage

FROM supply_chain_inventory;


-- ============================================================
-- 14. CHECK INVENTORY GAP
--
-- Expected:
-- Inventory Gap = Reorder Point - Inventory Level
-- ============================================================

SELECT
    COUNT(*) AS incorrect_inventory_gap

FROM supply_chain_inventory

WHERE ABS(
    inventory_gap
    - (reorder_point - inventory_level)
) > 0.01;


-- ============================================================
-- 15. CHECK INVENTORY COVERAGE
--
-- Expected:
-- Inventory Coverage Days =
-- Inventory Level / Demand Forecast
--
-- Zero forecast values are excluded because division by zero
-- is undefined.
-- ============================================================

SELECT
    COUNT(*) AS incorrect_inventory_coverage

FROM supply_chain_inventory

WHERE demand_forecast > 0

AND ABS(
    inventory_coverage_days
    - (
        inventory_level::NUMERIC
        / demand_forecast
    )
) > 0.01;


-- ============================================================
-- 16. CHECK COVERAGE-TO-LEAD-TIME LOGIC
--
-- Expected:
-- Coverage Below Lead Time =
-- Inventory Coverage Days < Supplier Lead Time Days
-- ============================================================

SELECT
    COUNT(*) AS incorrect_coverage_flags

FROM supply_chain_inventory

WHERE demand_forecast > 0

AND coverage_below_lead_time IS DISTINCT FROM (
    inventory_coverage_days < supplier_lead_time_days
);


-- ============================================================
-- 17. CHECK INVENTORY VALUE
--
-- Expected:
-- Inventory Value =
-- Inventory Level × Unit Cost
-- ============================================================

SELECT
    COUNT(*) AS incorrect_inventory_value

FROM supply_chain_inventory

WHERE ABS(
    inventory_value
    - (
        inventory_level::NUMERIC
        * unit_cost
    )
) > 0.01;


-- ============================================================
-- 18. CHECK SALES VALUE
--
-- Expected:
-- Sales Value =
-- Units Sold × Unit Price
-- ============================================================

SELECT
    COUNT(*) AS incorrect_sales_value

FROM supply_chain_inventory

WHERE ABS(
    sales_value
    - (
        units_sold::NUMERIC
        * unit_price
    )
) > 0.01;


-- ============================================================
-- 19. CHECK COGS
--
-- Expected:
-- COGS =
-- Units Sold × Unit Cost
-- ============================================================

SELECT
    COUNT(*) AS incorrect_cogs

FROM supply_chain_inventory

WHERE ABS(
    cogs
    - (
        units_sold::NUMERIC
        * unit_cost
    )
) > 0.01;


-- ============================================================
-- 20. CHECK INVENTORY-TO-DEMAND RATIO
--
-- Expected:
-- Inventory to Demand Ratio =
-- Inventory Level / Units Sold
-- ============================================================

SELECT
    COUNT(*) AS incorrect_inventory_demand_ratio

FROM supply_chain_inventory

WHERE units_sold > 0

AND ABS(
    inventory_to_demand_ratio
    - (
        inventory_level::NUMERIC
        / units_sold
    )
) > 0.01;


-- ============================================================
-- 21. CHECK PRICE VS COST
--
-- This is an informational business check.
-- A price below cost may occur because of promotions or
-- pricing decisions, so this is NOT treated as a data error.
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
-- 22. CHECK STOCKOUT RECORDS
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
-- 23. CHECK INVENTORY COVERAGE RISK
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
    ) AS coverage_risk_percentage

FROM supply_chain_inventory;


-- ============================================================
-- 24. FINAL DATA QUALITY SUMMARY
--
-- This provides a compact overview after running the detailed
-- checks above.
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
        WHERE inventory_level < reorder_point
    ) AS reorder_risk_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE inventory_level < reorder_point
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS reorder_risk_percentage,

    COUNT(*) FILTER (
        WHERE stockout_flag = 1
    ) AS stockout_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE stockout_flag = 1
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS stockout_rate_percentage,

    COUNT(*) FILTER (
        WHERE coverage_below_lead_time = TRUE
    ) AS coverage_risk_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE coverage_below_lead_time = TRUE
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS coverage_risk_percentage

FROM supply_chain_inventory;