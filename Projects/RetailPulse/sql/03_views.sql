-- RetailPulse | reusable reporting layer | MySQL 8.0.18+
USE retailpulse;

-- Financial contract:
-- * discount_amount is the discount for the whole item line, not per unit.
-- * A sale is recognized for paid, shipped and completed orders only.
-- * Refunds are attributed back to the original order's date and channel.
-- * No refund allocation to products or return-to-stock assumption is made.
-- * Gross profit = recognized net sales - refunds - original item cost.
-- * Each child table is aggregated BEFORE joining: one output row per order,
--   even when an order has several items, payment attempts and refunds.
CREATE OR REPLACE VIEW v_order_financials AS
WITH item_totals AS (
    SELECT order_id,
           SUM(quantity * unit_price) AS gross_sales,
           SUM(discount_amount) AS discounts,
           SUM(quantity * unit_price - discount_amount) AS net_sales,
           SUM(quantity * unit_cost) AS cost_of_goods
    FROM order_items
    GROUP BY order_id
), payment_totals AS (
    SELECT order_id,
           SUM(CASE WHEN status = 'captured' THEN amount ELSE 0 END) AS captured_amount
    FROM payments
    GROUP BY order_id
), refund_totals AS (
    SELECT order_id, SUM(amount) AS refund_amount
    FROM refunds
    GROUP BY order_id
)
SELECT o.order_id, o.customer_id, o.ordered_at, o.status, o.channel,
       COALESCE(i.gross_sales, 0.00) AS gross_sales,
       COALESCE(i.discounts, 0.00) AS discounts,
       COALESCE(i.net_sales, 0.00) AS net_sales,
       COALESCE(i.cost_of_goods, 0.00) AS cost_of_goods,
       COALESCE(p.captured_amount, 0.00) AS captured_amount,
       COALESCE(r.refund_amount, 0.00) AS refund_amount,
       CASE WHEN o.status IN ('paid', 'shipped', 'completed')
            THEN COALESCE(i.net_sales, 0.00) - COALESCE(r.refund_amount, 0.00)
            ELSE 0.00 END AS net_revenue,
       CASE WHEN o.status IN ('paid', 'shipped', 'completed')
            THEN COALESCE(i.net_sales, 0.00) - COALESCE(r.refund_amount, 0.00)
                 - COALESCE(i.cost_of_goods, 0.00)
            ELSE 0.00 END AS gross_profit
FROM orders AS o
LEFT JOIN item_totals AS i ON i.order_id = o.order_id
LEFT JOIN payment_totals AS p ON p.order_id = o.order_id
LEFT JOIN refund_totals AS r ON r.order_id = o.order_id;

-- Include registered customers who have never made a qualifying purchase.
-- All-time metrics; use a dated order query when answering an as-of question.
CREATE OR REPLACE VIEW v_customer_metrics AS
SELECT c.customer_id, c.full_name, c.email, c.city, c.signup_date,
       COUNT(f.order_id) AS order_count,
       MIN(f.ordered_at) AS first_order_at,
       MAX(f.ordered_at) AS last_order_at,
       COALESCE(SUM(f.net_revenue), 0.00) AS total_net_revenue,
       COALESCE(SUM(f.gross_profit), 0.00) AS total_gross_profit
FROM customers AS c
LEFT JOIN v_order_financials AS f
  ON f.customer_id = c.customer_id
 AND f.status IN ('paid', 'shipped', 'completed')
GROUP BY c.customer_id, c.full_name, c.email, c.city, c.signup_date;

-- Only observed selling months are returned. Join a calendar spine to display
-- months with no sales (see analysis 02); do not let absent months fool LAG().
CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT CAST(DATE_FORMAT(ordered_at, '%Y-%m-01') AS DATE) AS month_start,
       COUNT(*) AS order_count,
       COUNT(DISTINCT customer_id) AS purchasing_customers,
       SUM(gross_sales) AS gross_sales,
       SUM(discounts) AS discounts,
       SUM(net_sales) AS net_sales,
       SUM(refund_amount) AS refunds,
       SUM(net_revenue) AS net_revenue,
       SUM(gross_profit) AS gross_profit
FROM v_order_financials
WHERE status IN ('paid', 'shipped', 'completed')
GROUP BY CAST(DATE_FORMAT(ordered_at, '%Y-%m-01') AS DATE);
