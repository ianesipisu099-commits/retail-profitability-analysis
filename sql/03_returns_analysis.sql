-- PostgreSQL Superstore Sales and Profitability Analysis
-- 03_returns_analysis.sql
-- Return status is joined at order level. The returns table identifies orders
-- listed as returned; absence from that table does not prove no return occurred.

-- 1. Overall historical order-level return rate.
WITH historical_orders AS (
    SELECT DISTINCT order_id
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
),
return_ids AS (
    SELECT DISTINCT order_id
    FROM public.returns
    WHERE returned = 'Yes'
)
SELECT
    COUNT(*) AS historical_orders,
    COUNT(*) FILTER (WHERE r.order_id IS NOT NULL) AS returned_orders,
    COUNT(*) FILTER (WHERE r.order_id IS NULL) AS orders_not_listed_as_returned,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE r.order_id IS NOT NULL)
        / NULLIF(COUNT(*), 0), 2
    ) AS return_rate_pct
FROM historical_orders h
LEFT JOIN return_ids r USING (order_id);

-- 2. Sales and profitability by return status.
WITH historical_lines AS (
    SELECT *
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
),
return_ids AS (
    SELECT DISTINCT order_id
    FROM public.returns
    WHERE returned = 'Yes'
)
SELECT
    CASE WHEN r.order_id IS NOT NULL
         THEN 'Returned'
         ELSE 'Not listed as returned'
    END AS return_status,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    COUNT(*) AS order_lines,
    ROUND(SUM(o.sales), 2) AS sales,
    ROUND(SUM(o.profit), 2) AS profit,
    ROUND(100.0 * SUM(o.profit) / NULLIF(SUM(o.sales), 0), 2) AS profit_margin_pct,
    ROUND(SUM(o.sales) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS sales_per_order
FROM historical_lines o
LEFT JOIN return_ids r ON r.order_id = o.order_id
GROUP BY 1
ORDER BY 1;

-- 3. Order-level return rate by customer segment.
WITH historical_orders AS (
    SELECT DISTINCT order_id, segment
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
),
return_ids AS (
    SELECT DISTINCT order_id
    FROM public.returns
    WHERE returned = 'Yes'
)
SELECT
    h.segment,
    COUNT(*) AS distinct_orders,
    COUNT(*) FILTER (WHERE r.order_id IS NOT NULL) AS returned_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE r.order_id IS NOT NULL)
        / NULLIF(COUNT(*), 0), 2
    ) AS return_rate_pct
FROM historical_orders h
LEFT JOIN return_ids r USING (order_id)
GROUP BY h.segment
ORDER BY return_rate_pct DESC;

-- 4. Category-level order incidence rate.
-- An order can contain more than one category, so category denominators overlap.
WITH order_category AS (
    SELECT DISTINCT order_id, category
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
),
return_ids AS (
    SELECT DISTINCT order_id
    FROM public.returns
    WHERE returned = 'Yes'
)
SELECT
    oc.category,
    COUNT(*) AS orders_containing_category,
    COUNT(*) FILTER (WHERE r.order_id IS NOT NULL) AS returned_orders_containing_category,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE r.order_id IS NOT NULL)
        / NULLIF(COUNT(*), 0), 2
    ) AS return_rate_pct
FROM order_category oc
LEFT JOIN return_ids r USING (order_id)
GROUP BY oc.category
ORDER BY return_rate_pct DESC;

-- 5. Subcategory-level order incidence rate.
-- An order can contain multiple subcategories; denominators therefore overlap.
WITH order_subcategory AS (
    SELECT DISTINCT order_id, category, sub_category
    FROM public.orders
    WHERE order_date <= DATE '2026-10-22'
),
return_ids AS (
    SELECT DISTINCT order_id
    FROM public.returns
    WHERE returned = 'Yes'
)
SELECT
    os.category,
    os.sub_category,
    COUNT(*) AS orders_containing_subcategory,
    COUNT(*) FILTER (WHERE r.order_id IS NOT NULL) AS returned_orders_containing_subcategory,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE r.order_id IS NOT NULL)
        / NULLIF(COUNT(*), 0), 2
    ) AS return_rate_pct
FROM order_subcategory os
LEFT JOIN return_ids r USING (order_id)
GROUP BY os.category, os.sub_category
ORDER BY return_rate_pct DESC, orders_containing_subcategory DESC;
