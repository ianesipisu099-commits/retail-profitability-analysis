-- PostgreSQL Superstore Sales and Profitability Analysis
-- 01_data_quality.sql
-- Main historical cutoff: 2026-10-22 (inclusive).
-- Source table: public.orders
-- Returns table: public.returns
--
-- Important: the two potential duplicate rows identified during review are
-- retained in the source data. They have different row_id values, so do not
-- remove them without checking the original source.

-- 1. Overall row, ID, and order counts.
SELECT
    COUNT(*) AS total_rows,
    COUNT(row_id) AS non_null_row_ids,
    COUNT(DISTINCT row_id) AS distinct_row_ids,
    COUNT(*) - COUNT(DISTINCT row_id) AS duplicate_row_ids,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM public.orders;

-- 2. Full-dataset and historical/future date coverage.
SELECT
    CASE
        WHEN order_date <= DATE '2026-10-22' THEN 'Historical (through 2026-10-22)'
        ELSE 'Future-dated (after 2026-10-22)'
    END AS period,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM public.orders
GROUP BY 1
ORDER BY 1;

-- 3. Missing values and basic invalid-value checks.
-- The query checks all source rows; use the historical filter if desired.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE sales IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE profit IS NULL) AS missing_profit,
    COUNT(*) FILTER (WHERE discount IS NULL) AS missing_discount,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE sales < 0) AS negative_sales_rows,
    COUNT(*) FILTER (WHERE discount < 0 OR discount > 1) AS invalid_discount_rows,
    COUNT(*) FILTER (WHERE quantity <= 0) AS nonpositive_quantity_rows
FROM public.orders;

-- 4. Shipping-date consistency.
-- A ship date after the analysis cutoff is not itself an error; shipping can
-- occur after an order is placed. The historical filter is based on order_date.
SELECT
    COUNT(*) FILTER (WHERE ship_date IS NULL) AS missing_ship_dates,
    COUNT(*) FILTER (WHERE ship_date < order_date) AS ship_before_order,
    COUNT(*) FILTER (
        WHERE order_date <= DATE '2026-10-22'
          AND ship_date > DATE '2026-10-22'
    ) AS historical_orders_shipped_after_cutoff,
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date,
    MIN(ship_date) AS earliest_ship_date,
    MAX(ship_date) AS latest_ship_date
FROM public.orders;

-- 5. Potential duplicate records, excluding row_id from the comparison.
-- Different row_id values can still represent identical records in all other
-- columns. Treat these as potential duplicates, not confirmed errors.
WITH compared_rows AS (
    SELECT
        *,
        COUNT(*) OVER (
            PARTITION BY
                order_id, order_date, ship_date, ship_mode, customer_id,
                customer_name, segment, country_region, city, state_province,
                postal_code, region, product_id, category, sub_category,
                product_name, sales, quantity, discount, profit
        ) AS matching_record_count
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
)
SELECT
    COUNT(*) AS historical_rows,
    COUNT(*) FILTER (WHERE matching_record_count > 1) AS rows_in_duplicate_groups,
    SUM(matching_record_count - 1) FILTER (WHERE matching_record_count > 1)
        AS extra_copies_in_duplicate_groups
FROM compared_rows;

-- 6. Inspect potential duplicate records.
WITH compared_rows AS (
    SELECT
        *,
        COUNT(*) OVER (
            PARTITION BY
                order_id, order_date, ship_date, ship_mode, customer_id,
                customer_name, segment, country_region, city, state_province,
                postal_code, region, product_id, category, sub_category,
                product_name, sales, quantity, discount, profit
        ) AS matching_record_count
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
)
SELECT *
FROM compared_rows
WHERE matching_record_count > 1
ORDER BY order_id, row_id;

-- 7. Returns-table validation.
SELECT
    COUNT(*) AS return_rows,
    COUNT(DISTINCT order_id) AS distinct_return_order_ids,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_return_order_ids,
    COUNT(*) FILTER (WHERE returned IS NULL) AS missing_return_status,
    COUNT(*) FILTER (WHERE returned IS DISTINCT FROM 'Yes') AS non_yes_statuses
FROM public.returns;

-- 8. Check whether every return order ID matches an order in the sales table.
SELECT
    COUNT(DISTINCT r.order_id) AS distinct_return_order_ids,
    COUNT(DISTINCT r.order_id) FILTER (WHERE o.order_id IS NOT NULL)
        AS return_ids_found_in_orders,
    COUNT(DISTINCT r.order_id) FILTER (WHERE o.order_id IS NULL)
        AS return_ids_not_found_in_orders
FROM public.returns r
LEFT JOIN (SELECT DISTINCT order_id FROM public.orders) o
    ON o.order_id = r.order_id;
