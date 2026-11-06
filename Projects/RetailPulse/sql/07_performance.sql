-- RetailPulse | inspect actual query plans | MySQL 8.0.18+
USE retailpulse;

-- EXPLAIN ANALYZE executes these read-only SELECT statements and reports
-- actual rows, loops and elapsed time. Timings depend on hardware and cache.
-- A scan can be cheaper than an index on this small seed; inspect the plan
-- rather than claiming an unmeasured speedup. Existing indexes are in schema.

-- 01. Customer timeline: use a selective customer predicate and a half-open
-- date range. Check for the schema's customer/date/order index lookup.
EXPLAIN ANALYZE
SELECT order_id, ordered_at, status, channel
FROM orders
WHERE customer_id = 42
  AND ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01'
ORDER BY ordered_at, order_id;

-- 02. Date range across customers: the date-leading index supports this
-- predicate. Applying YEAR(ordered_at) would generally prevent this range
-- access pattern; keep the indexed column outside a function in WHERE.
EXPLAIN ANALYZE
SELECT order_id, customer_id, ordered_at
FROM orders
WHERE ordered_at >= '2025-11-01' AND ordered_at < '2025-12-01'
  AND status IN ('paid', 'shipped', 'completed');

-- 03. Composite primary key (order_id, product_id) supports per-order detail.
EXPLAIN ANALYZE
SELECT p.sku, p.name, i.quantity,
       i.quantity * i.unit_price - i.discount_amount AS line_net_sales
FROM order_items AS i
JOIN products AS p ON p.product_id = i.product_id
WHERE i.order_id = 42;

-- 04. The financial view intentionally preaggregates independent fact tables.
-- Look for aggregate/materialize nodes. Correct aggregation grain matters
-- more than avoiding every temporary table. Scale-test with realistic data
-- before considering persisted daily summaries or reporting replicas.
EXPLAIN ANALYZE
SELECT channel, SUM(net_revenue) AS net_revenue
FROM v_order_financials
WHERE ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01'
  AND status IN ('paid', 'shipped', 'completed')
GROUP BY channel;
