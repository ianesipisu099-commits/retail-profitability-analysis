-- PostgreSQL Superstore Sales and Profitability Analysis
-- 02_sales_profitability.sql
-- Historical analysis includes orders placed on or before 2026-10-22.
-- Margin = SUM(profit) / SUM(sales); it is not the average of row-level margins.

-- 1. Overall historical performance.
SELECT
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM public.orders
WHERE order_date <= DATE '2026-10-22';

-- 2. Performance by region.
SELECT
    region,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY region
ORDER BY sales DESC;

-- 3. Performance by category.
SELECT
    category,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY category
ORDER BY sales DESC;

-- 4. Performance by subcategory.
SELECT
    category,
    sub_category,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY category, sub_category
ORDER BY profit ASC;

-- 5. Performance by customer segment.
SELECT
    segment,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS sales_per_order
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY segment
ORDER BY sales DESC;

-- 6. Monthly sales and profit trend.
SELECT
    DATE_TRUNC('month', order_date)::date AS order_month,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;

-- 7. Highest-sales products (top 20).
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    COUNT(*) AS order_lines,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY product_id, product_name, category, sub_category
ORDER BY sales DESC
LIMIT 20;

-- 8. Lowest-profit products (at least 3 order lines; top 20 loss-makers).
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    COUNT(*) AS order_lines,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM public.orders
WHERE order_date <= DATE '2026-10-22'
GROUP BY product_id, product_name, category, sub_category
HAVING COUNT(*) >= 3
ORDER BY profit ASC
LIMIT 20;
