-- PostgreSQL Superstore Sales and Profitability Analysis
-- 04_discount_analysis.sql
-- Historical analysis includes orders placed on or before 2026-10-22.
-- A 30% threshold is used to describe the observed high-discount group; it is
-- an analytical grouping, not a recommended universal discount cap.
-- Associations in these results do not establish that discounts alone caused
-- the observed profit outcomes.

-- 1. Compare discounts below 30% with discounts of 30% or more.
SELECT
    CASE WHEN discount >= 0.30 THEN 'High discount (30%+)'
         ELSE 'Lower discount (<30%)'
    END AS discount_group,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY 1
ORDER BY 1;

-- 2. Discount group by category.
SELECT
    category,
    CASE WHEN discount >= 0.30 THEN 'High discount (30%+)'
         ELSE 'Lower discount (<30%)'
    END AS discount_group,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY category, discount_group
ORDER BY category, discount_group;

-- 3. Discount group by subcategory.
SELECT
    category,
    sub_category,
    CASE WHEN discount >= 0.30 THEN 'High discount (30%+)'
         ELSE 'Lower discount (<30%)'
    END AS discount_group,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY category, sub_category, discount_group
ORDER BY category, sub_category, discount_group;

-- 4. Product/discount combinations for review.
-- Requiring at least two order lines reduces emphasis on single-line results;
-- use the count and units to judge how much evidence each row represents.
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    discount,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY product_id, product_name, category, sub_category, discount
HAVING COUNT(*) >= 2
ORDER BY profit ASC
LIMIT 50;

-- 5. Sensitivity analysis for the two potential duplicate copies identified
-- during QA. This removes one copy per duplicate pair only for comparison;
-- it does not modify or delete source records.
WITH historical AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                order_id, order_date, ship_date, ship_mode, customer_id,
                customer_name, segment, country_region, city, state_province,
                postal_code, region, product_id, category, sub_category,
                product_name, sales, quantity, discount, profit
            ORDER BY row_id
        ) AS copy_number
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
)
SELECT
    COUNT(*) AS historical_rows,
    COUNT(*) FILTER (WHERE copy_number > 1) AS extra_duplicate_rows,
    ROUND(SUM(sales), 2) AS original_sales,
    ROUND(SUM(profit), 2) AS original_profit,
    ROUND(SUM(sales) FILTER (WHERE copy_number > 1), 2) AS potential_duplicate_sales,
    ROUND(SUM(profit) FILTER (WHERE copy_number > 1), 2) AS potential_duplicate_profit,
    ROUND(SUM(sales) FILTER (WHERE copy_number = 1), 2) AS sales_without_extra_copies,
    ROUND(SUM(profit) FILTER (WHERE copy_number = 1), 2) AS profit_without_extra_copies
FROM historical;
