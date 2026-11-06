-- Deterministic, fictional fixture; all money is INR and excludes tax/shipping.
-- Seed once, immediately after 01_schema.sql. An attempted rerun fails on PKs.
USE retailpulse;

-- A small digits cross join avoids recursive-CTE depth settings and RAND().
CREATE TEMPORARY TABLE seed_numbers (n INT NOT NULL PRIMARY KEY);
INSERT INTO seed_numbers (n)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9
)
SELECT 1 + a.d + 10 * b.d + 100 * c.d + 1000 * d.d
FROM digits AS a CROSS JOIN digits AS b CROSS JOIN digits AS c CROSS JOIN digits AS d
WHERE a.d + 10 * b.d + 100 * c.d + 1000 * d.d < 3600;

START TRANSACTION;

INSERT INTO categories (category_id, name) VALUES
    (1, 'Electronics'), (2, 'Home & Kitchen'), (3, 'Fitness'),
    (4, 'Books & Stationery'), (5, 'Travel'), (6, 'Personal Care');

INSERT INTO products
    (product_id, category_id, sku, name, unit_price, unit_cost, stock_quantity)
VALUES
    (1, 1, 'ELE-001', 'Wireless Headphones', 2499.00, 1350.00, 12),
    (2, 1, 'ELE-002', 'Mechanical Keyboard', 3299.00, 1900.00, 1034),
    (3, 1, 'ELE-003', 'USB-C Hub', 1599.00, 800.00, 1051),
    (4, 1, 'ELE-004', 'Portable Speaker', 1999.00, 1100.00, 1068),
    (5, 2, 'HOM-001', 'Insulated Bottle', 799.00, 350.00, 1085),
    (6, 2, 'HOM-002', 'Desk Lamp', 1299.00, 650.00, 1102),
    (7, 2, 'HOM-003', 'Coffee Press', 1099.00, 500.00, 1119),
    (8, 2, 'HOM-004', 'Storage Organizer', 599.00, 250.00, 1136),
    (9, 3, 'FIT-001', 'Yoga Mat', 999.00, 400.00, 8),
    (10, 3, 'FIT-002', 'Resistance Bands', 699.00, 280.00, 1170),
    (11, 3, 'FIT-003', 'Skipping Rope', 399.00, 150.00, 1187),
    (12, 3, 'FIT-004', 'Training Gloves', 549.00, 220.00, 1204),
    (13, 4, 'BKS-001', 'SQL Practice Notebook', 299.00, 100.00, 1221),
    (14, 4, 'BKS-002', 'Weekly Planner', 349.00, 120.00, 1238),
    (15, 4, 'BKS-003', 'Gel Pen Set', 199.00, 65.00, 1255),
    (16, 4, 'BKS-004', 'Reading Journal', 449.00, 180.00, 1272),
    (17, 5, 'TRV-001', 'Travel Backpack', 1899.00, 950.00, 5),
    (18, 5, 'TRV-002', 'Packing Cubes', 899.00, 380.00, 1306),
    (19, 5, 'TRV-003', 'Neck Pillow', 649.00, 260.00, 1323),
    (20, 5, 'TRV-004', 'Luggage Tag Set', 249.00, 80.00, 1340),
    (21, 6, 'CAR-001', 'Grooming Kit', 1199.00, 550.00, 1357),
    (22, 6, 'CAR-002', 'Microfiber Towel', 399.00, 150.00, 1374),
    (23, 6, 'CAR-003', 'Travel Toiletry Bag', 599.00, 230.00, 1391),
    (24, 6, 'CAR-004', 'Reusable Care Kit', 749.00, 300.00, 1408);

INSERT INTO customers (customer_id, full_name, email, city, signup_date)
SELECT n,
       CONCAT('Demo Customer ', LPAD(n, 3, '0')),
       CONCAT('customer', LPAD(n, 3, '0'), '@example.com'),
       ELT(1 + MOD(n - 1, 6), 'Kolkata', 'Bengaluru', 'Delhi', 'Mumbai', 'Pune', 'Chennai'),
       DATE_ADD('2024-01-01', INTERVAL MOD(n * 13, 365) DAY)
FROM seed_numbers WHERE n <= 600 ORDER BY n;

-- 335 distinct calendar dates: June is deliberately empty. A coprime stride
-- spreads orders throughout the year; customer IDs 581-600 never place orders.
INSERT INTO orders (order_id, customer_id, ordered_at, status, channel)
SELECT n,
       1 + MOD((n - 1) * 17, 580),
       TIMESTAMPADD(MINUTE, MOD(n * 19, 720),
           TIMESTAMPADD(DAY,
               MOD((n - 1) * 37, 335)
                   + IF(MOD((n - 1) * 37, 335) >= 151, 30, 0),
               '2025-01-01 09:00:00')),
       CASE MOD(n + FLOOR((n - 1) / 580) * 3, 20)
           WHEN 0 THEN 'cancelled'
           WHEN 1 THEN 'pending'
           WHEN 2 THEN 'paid'
           WHEN 3 THEN 'shipped'
           ELSE 'completed'
       END,
       ELT(1 + MOD(n + FLOOR(n / 7), 3), 'web', 'mobile', 'marketplace')
FROM seed_numbers ORDER BY n;

-- Every order has 1-3 different products. Integer quantities, DECIMAL prices,
-- and rounded total-line discounts keep payment reconciliation exact.
INSERT INTO order_items
    (order_id, product_id, quantity, unit_price, unit_cost, discount_amount)
SELECT o.order_id, p.product_id,
       1 + MOD(o.order_id + item_lines.line_no, 3), p.unit_price, p.unit_cost,
       CASE WHEN MOD(o.order_id + item_lines.line_no, 10) = 0
            THEN ROUND((1 + MOD(o.order_id + item_lines.line_no, 3)) * p.unit_price * 0.10, 2)
            ELSE 0.00 END
FROM orders AS o
CROSS JOIN (SELECT 1 AS line_no UNION ALL SELECT 2 UNION ALL SELECT 3) AS item_lines
JOIN products AS p
    ON p.product_id = 1 + MOD(o.order_id * 7
        + CASE item_lines.line_no WHEN 1 THEN 0 WHEN 2 THEN 5 ELSE 11 END, 24)
WHERE item_lines.line_no <= 1 + MOD(o.order_id, 3)
ORDER BY o.order_id, p.product_id;

-- Failed attempts coexist with successful captures. Joining raw payments and
-- order_items would overcount; analytics must aggregate each at order grain.
INSERT INTO payments (payment_id, order_id, amount, status, paid_at)
SELECT o.order_id * 10, o.order_id,
       SUM(oi.quantity * oi.unit_price - oi.discount_amount),
       'failed', DATE_ADD(o.ordered_at, INTERVAL 2 MINUTE)
FROM orders AS o JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE MOD(o.order_id, 9) = 0
GROUP BY o.order_id, o.ordered_at;

INSERT INTO payments (payment_id, order_id, amount, status, paid_at)
SELECT o.order_id * 10 + 1, o.order_id,
       SUM(oi.quantity * oi.unit_price - oi.discount_amount),
       'captured', DATE_ADD(o.ordered_at, INTERVAL 15 MINUTE)
FROM orders AS o JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('paid', 'shipped', 'completed')
GROUP BY o.order_id, o.ordered_at;

-- Two partial goodwill refunds on selected captured orders: 10% and 5%.
-- Clamp event times to year-end so all fixture activity is within 2025.
INSERT INTO refunds (refund_id, order_id, amount, refunded_at, reason)
SELECT o.order_id * 10 + r.part, o.order_id,
       ROUND(p.amount * IF(r.part = 1, 0.10, 0.05), 2),
       LEAST(DATE_ADD(o.ordered_at, INTERVAL (r.part * 3) DAY), '2025-12-31 23:59:00'),
       IF(r.part = 1, 'Late delivery credit', 'Customer care adjustment')
FROM orders AS o
JOIN payments AS p ON p.order_id = o.order_id AND p.status = 'captured'
CROSS JOIN (SELECT 1 AS part UNION ALL SELECT 2) AS r
WHERE MOD(o.order_id, 17) = 0
ORDER BY o.order_id, r.part;

-- Opening inventory snapshot AFTER the imported historical orders. Historical
-- purchases are not replayed against this independent current stock balance.
INSERT INTO inventory_movements
    (movement_id, product_id, order_id, quantity_delta, reason, created_at)
SELECT product_id, product_id, NULL, stock_quantity,
       'opening', '2025-12-31 23:59:59'
FROM products ORDER BY product_id;

COMMIT;
DROP TEMPORARY TABLE seed_numbers;
