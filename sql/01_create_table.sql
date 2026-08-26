-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS
-- 01 - CREATE TABLE
-- PostgreSQL
-- ============================================================
-- Purpose:
-- Create the main table used by the project.
--
-- The table structure matches the final CSV dataset used by
-- the Python notebooks and PostgreSQL analysis.
-- ============================================================


-- ============================================================
-- 1. DROP EXISTING TABLE
-- ============================================================

DROP TABLE IF EXISTS supply_chain_inventory;


-- ============================================================
-- 2. CREATE MAIN TABLE
-- ============================================================

CREATE TABLE supply_chain_inventory (

    -- --------------------------------------------------------
    -- Record Identifier
    -- --------------------------------------------------------

    record_id BIGSERIAL PRIMARY KEY,


    -- --------------------------------------------------------
    -- Date
    -- --------------------------------------------------------

    date DATE NOT NULL,


    -- --------------------------------------------------------
    -- Business Dimensions
    -- --------------------------------------------------------

    sku_id VARCHAR(50) NOT NULL,

    warehouse_id VARCHAR(50) NOT NULL,

    supplier_id VARCHAR(50) NOT NULL,

    region VARCHAR(100),


    -- --------------------------------------------------------
    -- Demand & Inventory
    -- --------------------------------------------------------

    units_sold INTEGER,

    inventory_level INTEGER,


    -- --------------------------------------------------------
    -- Replenishment
    -- --------------------------------------------------------

    supplier_lead_time_days INTEGER,

    reorder_point INTEGER,

    order_quantity INTEGER,


    -- --------------------------------------------------------
    -- Financial Inputs
    -- --------------------------------------------------------

    unit_cost NUMERIC(12,2),

    unit_price NUMERIC(12,2),


    -- --------------------------------------------------------
    -- Operational Flags
    -- --------------------------------------------------------

    promotion_flag INTEGER,

    stockout_flag INTEGER,


    -- --------------------------------------------------------
    -- Demand Forecast
    -- --------------------------------------------------------

    demand_forecast NUMERIC(12,2),


    -- --------------------------------------------------------
    -- Date-Derived Fields
    -- --------------------------------------------------------

    year INTEGER,

    month INTEGER,

    month_name VARCHAR(20),


    -- --------------------------------------------------------
    -- Inventory Risk Metrics
    -- --------------------------------------------------------

    below_reorder_point BOOLEAN,

    inventory_gap INTEGER,

    inventory_coverage_days NUMERIC(12,2),

    coverage_below_lead_time BOOLEAN,


    -- --------------------------------------------------------
    -- Financial Metrics
    -- --------------------------------------------------------

    inventory_value NUMERIC(14,2),

    sales_value NUMERIC(14,2),

    cogs NUMERIC(14,2),


    -- --------------------------------------------------------
    -- Inventory / Demand Metric
    -- --------------------------------------------------------

    inventory_to_demand_ratio NUMERIC(12,2)

);


-- ============================================================
-- 3. BASIC TABLE VERIFICATION
-- ============================================================

SELECT *
FROM supply_chain_inventory
LIMIT 10;


-- ============================================================
-- 4. CHECK TABLE STRUCTURE
-- ============================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'supply_chain_inventory'
ORDER BY ordinal_position;


-- ============================================================
-- 5. EXPECTED COLUMN COUNT
-- ============================================================

SELECT
    COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'supply_chain_inventory';