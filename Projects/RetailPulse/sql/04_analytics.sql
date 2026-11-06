-- RetailPulse | business questions answered with SQL | MySQL 8.0.18+
-- Reporting window: [2025-01-01, 2026-01-01); as-of date: 2026-01-01.
-- Values are in INR. Revenue uses order dates and includes all known refunds
-- on those orders: this is an order-cohort report, not a cash-flow statement.
USE retailpulse;

-- 01. How much profitable business did we generate?
-- Net AOV divides post-refund revenue by qualifying orders (including fully
-- refunded orders); margin divides gross profit by post-refund revenue.
SELECT COUNT(*) AS qualifying_orders,
       COUNT(DISTINCT customer_id) AS purchasing_customers,
       SUM(gross_sales) AS gross_sales_inr,
       SUM(discounts) AS discounts_inr,
       SUM(refund_amount) AS refunds_inr,
       SUM(net_revenue) AS net_revenue_inr,
       SUM(gross_profit) AS gross_profit_inr,
       ROUND(SUM(net_revenue) / NULLIF(COUNT(*), 0), 2) AS net_aov_inr,
       ROUND(100.0 * SUM(gross_profit) / NULLIF(SUM(net_revenue), 0), 2) AS gross_margin_pct
FROM v_order_financials
WHERE status IN ('paid', 'shipped', 'completed')
  AND ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01';

-- 02. Which months grew? Include all 12 months, even a month without orders.
-- A previous month of zero gives NULL growth because percentage growth from
-- zero is undefined; a missing selling month is still a real calendar month.
WITH RECURSIVE calendar AS (
    SELECT CAST('2025-01-01' AS DATE) AS month_start
    UNION ALL
    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM calendar WHERE month_start < '2025-12-01'
), monthly AS (
    SELECT c.month_start, COALESCE(m.order_count, 0) AS order_count,
           COALESCE(m.net_revenue, 0.00) AS net_revenue
    FROM calendar AS c
    LEFT JOIN v_monthly_sales AS m ON m.month_start = c.month_start
), compared AS (
    SELECT *, LAG(net_revenue) OVER (ORDER BY month_start) AS previous_month_revenue
    FROM monthly
)
SELECT month_start, order_count, net_revenue, previous_month_revenue,
       ROUND(100.0 * (net_revenue - previous_month_revenue)
             / NULLIF(previous_month_revenue, 0), 2) AS mom_growth_pct
FROM compared ORDER BY month_start;

-- 03. What are each category's top three sales ranks? Ties are retained.
-- Product sales are after discounts but BEFORE order-level refunds: the model
-- cannot reliably allocate a refund to a particular product.
WITH product_sales AS (
    SELECT c.name AS category, p.product_id, p.name AS product,
           SUM(i.quantity) AS units,
           SUM(i.quantity * i.unit_price - i.discount_amount) AS sales_before_refunds
    FROM order_items AS i
    JOIN orders AS o ON o.order_id = i.order_id
    JOIN products AS p ON p.product_id = i.product_id
    JOIN categories AS c ON c.category_id = p.category_id
    WHERE o.status IN ('paid', 'shipped', 'completed')
      AND o.ordered_at >= '2025-01-01' AND o.ordered_at < '2026-01-01'
    GROUP BY c.category_id, c.name, p.product_id, p.name
), ranked AS (
    SELECT *, DENSE_RANK() OVER (
        PARTITION BY category ORDER BY sales_before_refunds DESC
    ) AS sales_rank
    FROM product_sales
)
SELECT * FROM ranked WHERE sales_rank <= 3
ORDER BY category, sales_rank, product_id;

-- 04. Which customers deserve retention attention? RFM uses 2025 purchasers.
-- Scores 1..5: higher is better. Customer ID breaks ties deterministically;
-- NTILE may split equal metric values, so these are distribution-based groups.
WITH rfm AS (
    SELECT customer_id,
           DATEDIFF('2026-01-01', MAX(ordered_at)) AS recency_days,
           COUNT(*) AS frequency,
           SUM(net_revenue) AS monetary_inr
    FROM v_order_financials
    WHERE status IN ('paid', 'shipped', 'completed')
      AND ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01'
    GROUP BY customer_id
), scored AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY recency_days DESC, customer_id) AS r_score,
           NTILE(5) OVER (ORDER BY frequency, customer_id) AS f_score,
           NTILE(5) OVER (ORDER BY monetary_inr, customer_id) AS m_score
    FROM rfm
)
SELECT *, CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score <= 2 AND f_score >= 4 THEN 'At risk'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent low frequency'
    WHEN f_score >= 4 THEN 'Loyal'
    ELSE 'Developing' END AS segment
FROM scored ORDER BY monetary_inr DESC, customer_id;

-- 05. Do first-purchase cohorts return in later months?
-- Denominator: all customers first purchasing in that cohort month.
-- Numerator: distinct cohort customers purchasing in the activity month.
-- The observation window closes on 2026-01-01. Future cells are omitted;
-- observed months with zero returning customers display 0%, including June.
WITH RECURSIVE calendar AS (
    SELECT CAST('2025-01-01' AS DATE) AS month_start
    UNION ALL
    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM calendar WHERE month_start < '2025-12-01'
), eligible AS (
    SELECT customer_id, ordered_at
    FROM orders
    WHERE status IN ('paid', 'shipped', 'completed')
      AND ordered_at < '2026-01-01'
), cohorts AS (
    SELECT customer_id,
           CAST(DATE_FORMAT(MIN(ordered_at), '%Y-%m-01') AS DATE) AS cohort_month
    FROM eligible GROUP BY customer_id
), cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_customers
    FROM cohorts
    WHERE cohort_month >= '2025-01-01'
    GROUP BY cohort_month
), activity AS (
    SELECT c.cohort_month,
           CAST(DATE_FORMAT(e.ordered_at, '%Y-%m-01') AS DATE) AS activity_month,
           COUNT(DISTINCT e.customer_id) AS active_customers
    FROM eligible AS e
    JOIN cohorts AS c ON c.customer_id = e.customer_id
    GROUP BY c.cohort_month,
             CAST(DATE_FORMAT(e.ordered_at, '%Y-%m-01') AS DATE)
)
SELECT s.cohort_month,
       TIMESTAMPDIFF(MONTH, s.cohort_month, m.month_start) AS month_number,
       m.month_start AS activity_month, s.cohort_customers,
       COALESCE(a.active_customers, 0) AS active_customers,
       ROUND(100.0 * COALESCE(a.active_customers, 0) / s.cohort_customers, 2) AS retention_pct
FROM cohort_sizes AS s
JOIN calendar AS m ON m.month_start >= s.cohort_month
LEFT JOIN activity AS a
  ON a.cohort_month = s.cohort_month AND a.activity_month = m.month_start
ORDER BY s.cohort_month, m.month_start;

-- 06. How quickly did cumulative revenue build throughout the year?
-- Daily grain plus explicit ROWS frame avoids peer-row surprises.
WITH daily AS (
    SELECT DATE(ordered_at) AS sales_date, SUM(net_revenue) AS net_revenue
    FROM v_order_financials
    WHERE status IN ('paid', 'shipped', 'completed')
      AND ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01'
    GROUP BY DATE(ordered_at)
)
SELECT sales_date, net_revenue,
       SUM(net_revenue) OVER (
           ORDER BY sales_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_net_revenue
FROM daily ORDER BY sales_date;

-- 07. Which product pairs are bought together? Each unordered pair appears
-- once per order because order_items has a composite order/product key.
-- Support denominator is ALL qualifying orders, including single-item orders.
WITH eligible_orders AS (
    SELECT order_id FROM orders
    WHERE status IN ('paid', 'shipped', 'completed')
      AND ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01'
), pairs AS (
    SELECT a.product_id AS product_a_id, b.product_id AS product_b_id,
           COUNT(*) AS orders_together
    FROM eligible_orders AS o
    JOIN order_items AS a ON a.order_id = o.order_id
    JOIN order_items AS b
      ON b.order_id = a.order_id AND b.product_id > a.product_id
    GROUP BY a.product_id, b.product_id
)
SELECT a.name AS product_a, b.name AS product_b, p.orders_together,
       ROUND(100.0 * p.orders_together
             / NULLIF((SELECT COUNT(*) FROM eligible_orders), 0), 2) AS support_pct
FROM pairs AS p
JOIN products AS a ON a.product_id = p.product_a_id
JOIN products AS b ON b.product_id = p.product_b_id
ORDER BY p.orders_together DESC, p.product_a_id, p.product_b_id LIMIT 10;

-- 08. How much revenue comes from a customer's first versus later orders?
-- Sequence qualifying orders across all prior history before filtering 2025.
-- Same-timestamp orders use the order ID to define an unambiguous first order.
WITH sequenced AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY customer_id ORDER BY ordered_at, order_id
    ) AS purchase_number
    FROM v_order_financials
    WHERE status IN ('paid', 'shipped', 'completed') AND ordered_at < '2026-01-01'
)
SELECT CASE WHEN purchase_number = 1 THEN 'First order' ELSE 'Repeat order' END AS order_type,
       COUNT(*) AS orders, SUM(net_revenue) AS net_revenue_inr
FROM sequenced WHERE ordered_at >= '2025-01-01'
GROUP BY CASE WHEN purchase_number = 1 THEN 'First order' ELSE 'Repeat order' END;

-- 09. Which repeat customers have not purchased for at least 90 days?
-- Candidate list only; inactivity is not proof that a customer has churned.
WITH history AS (
    SELECT customer_id, COUNT(*) AS orders, MAX(ordered_at) AS last_order_at,
           SUM(net_revenue) AS historical_net_revenue
    FROM v_order_financials
    WHERE status IN ('paid', 'shipped', 'completed') AND ordered_at < '2026-01-01'
    GROUP BY customer_id
)
SELECT c.customer_id, c.full_name, c.city, h.orders, h.last_order_at,
       DATEDIFF('2026-01-01', h.last_order_at) AS recency_days,
       h.historical_net_revenue
FROM history AS h JOIN customers AS c ON c.customer_id = h.customer_id
WHERE h.orders >= 2 AND DATEDIFF('2026-01-01', h.last_order_at) >= 90
ORDER BY h.historical_net_revenue DESC, c.customer_id;

-- 10. Are captured payments reconciled to recognized order sales?
-- Captures match pre-refund net_sales; refunds are a separate cash movement.
-- Nonqualifying orders should have no captures, and no order may be refunded
-- beyond its captures. An empty result is healthy. Exact DECIMAL comparison.
SELECT order_id, status, net_sales, captured_amount, refund_amount,
       captured_amount - CASE WHEN status IN ('paid', 'shipped', 'completed')
                              THEN net_sales ELSE 0.00 END AS capture_difference
FROM v_order_financials
WHERE captured_amount <> CASE WHEN status IN ('paid', 'shipped', 'completed')
                             THEN net_sales ELSE 0.00 END
   OR refund_amount > captured_amount
ORDER BY order_id;

-- 11. Which products need stock review? Trailing demand spans exactly 90
-- calendar days: [2025-10-03, 2026-01-01). Target = 30 days of that demand.
-- This is a simple scenario; stock is the seeded current snapshot, not a
-- reconstruction from sales. Refunds do not imply returned physical stock.
WITH demand AS (
    SELECT i.product_id, SUM(i.quantity) AS units_90d
    FROM order_items AS i JOIN orders AS o ON o.order_id = i.order_id
    WHERE o.status IN ('paid', 'shipped', 'completed')
      AND o.ordered_at >= '2025-10-03' AND o.ordered_at < '2026-01-01'
    GROUP BY i.product_id
)
SELECT p.product_id, p.sku, p.name, p.stock_quantity,
       COALESCE(d.units_90d, 0) AS units_90d,
       ROUND(90.0 * p.stock_quantity / NULLIF(d.units_90d, 0), 1) AS days_of_stock,
       GREATEST(CEIL(COALESCE(d.units_90d, 0) / 90.0 * 30) - p.stock_quantity, 0) AS suggested_reorder_units
FROM products AS p LEFT JOIN demand AS d ON d.product_id = p.product_id
ORDER BY suggested_reorder_units DESC, p.product_id;

-- 12. Which channel has the strongest post-refund economics?
-- Refund rate counts distinct refunded orders, not refund events.
SELECT channel, COUNT(*) AS qualifying_orders,
       SUM(CASE WHEN refund_amount > 0 THEN 1 ELSE 0 END) AS refunded_orders,
       ROUND(100.0 * SUM(CASE WHEN refund_amount > 0 THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0), 2) AS refunded_order_pct,
       SUM(net_revenue) AS net_revenue_inr,
       SUM(gross_profit) AS gross_profit_inr,
       ROUND(100.0 * SUM(gross_profit) / NULLIF(SUM(net_revenue), 0), 2) AS gross_margin_pct
FROM v_order_financials
WHERE status IN ('paid', 'shipped', 'completed')
  AND ordered_at >= '2025-01-01' AND ordered_at < '2026-01-01'
GROUP BY channel ORDER BY net_revenue_inr DESC, channel;

-- 13. Which registered customers never became paying customers?
-- Anti-join with NOT EXISTS; pending and cancelled orders do not convert.
SELECT c.customer_id, c.full_name, c.city, c.signup_date
FROM customers AS c
WHERE c.signup_date < '2026-01-01'
  AND NOT EXISTS (
      SELECT 1 FROM orders AS o
      WHERE o.customer_id = c.customer_id
        AND o.status IN ('paid', 'shipped', 'completed')
        AND o.ordered_at < '2026-01-01'
  )
ORDER BY c.signup_date, c.customer_id;
