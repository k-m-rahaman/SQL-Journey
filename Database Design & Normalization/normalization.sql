
/*
========================================================
    SQL JOURNEY
    Module 11: Database Design & Normalization
    File: normalization.sql
    Topic: Database Normalization
========================================================

Description:
Normalization organizes relational data
to minimize unnecessary duplication and
improve data consistency.

Concepts Covered:
1. Data redundancy
2. Insertion anomalies
3. Update anomalies
4. Deletion anomalies
5. Functional dependencies
6. Primary and foreign keys
7. Normalized relational design
8. Reconstructing data using JOINs

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: DENORMALIZED ORDER DATA
-- =====================================================

-- 1. Reset demonstration tables.
DROP TABLE IF EXISTS demo_norm_order_items;
DROP TABLE IF EXISTS demo_norm_orders;
DROP TABLE IF EXISTS demo_norm_products;
DROP TABLE IF EXISTS demo_norm_customers;
DROP TABLE IF EXISTS demo_norm_flat_orders;

-- 2. Create a flat table with repeated information.
CREATE TABLE demo_norm_flat_orders (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10, 2),

    PRIMARY KEY (order_id, product_id)
);

-- 3. Insert sample records.
INSERT INTO demo_norm_flat_orders VALUES
    (1001, 201, 1, 'Arjun Sharma', 'Kolkata',
     'Laptop', 1, 55000),

    (1001, 202, 1, 'Arjun Sharma', 'Kolkata',
     'Mouse', 2, 800),

    (1002, 203, 2, 'Priya Das', 'Delhi',
     'Keyboard', 1, 1500),

    (1003, 201, 1, 'Arjun Sharma', 'Kolkata',
     'Laptop', 1, 55000),

    (1003, 203, 1, 'Arjun Sharma', 'Kolkata',
     'Keyboard', 1, 1500);

-- 4. Display the flat table.
SELECT *
FROM demo_norm_flat_orders
ORDER BY order_id, product_id;

-- 5. Observe repeated customer information.
SELECT
    customer_id,
    customer_name,
    COUNT(*) AS repeated_rows
FROM demo_norm_flat_orders
GROUP BY customer_id, customer_name
ORDER BY repeated_rows DESC;

-- Problem:
-- Customer details repeat across order items.
-- Product names also repeat across orders.
--
-- Updating a customer's city may require
-- changes to multiple rows.
--
-- Deleting their last order could also
-- delete the only stored customer details.


-- =====================================================
-- SECTION 2: NORMALIZED DATABASE DESIGN
-- =====================================================

-- 6. Create a separate customers table.
CREATE TABLE demo_norm_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100)
);

-- 7. Create a separate products table.
CREATE TABLE demo_norm_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL
);

-- 8. Create an orders table.
CREATE TABLE demo_norm_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES demo_norm_customers(customer_id)
);

-- 9. Create order-item relationships.
CREATE TABLE demo_norm_order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,

    PRIMARY KEY (order_id, product_id),

    FOREIGN KEY (order_id)
        REFERENCES demo_norm_orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES demo_norm_products(product_id),

    CHECK (quantity > 0),
    CHECK (unit_price >= 0)
);

-- 10. Insert distinct customers.
INSERT INTO demo_norm_customers
SELECT DISTINCT
    customer_id,
    customer_name,
    customer_city
FROM demo_norm_flat_orders;

-- 11. Insert distinct products.
INSERT INTO demo_norm_products
SELECT DISTINCT
    product_id,
    product_name
FROM demo_norm_flat_orders;

-- 12. Insert orders.
INSERT INTO demo_norm_orders
SELECT DISTINCT
    order_id,
    customer_id
FROM demo_norm_flat_orders;

-- 13. Insert order items.
INSERT INTO demo_norm_order_items
SELECT
    order_id,
    product_id,
    quantity,
    unit_price
FROM demo_norm_flat_orders;


-- =====================================================
-- SECTION 3: WORKING WITH NORMALIZED DATA
-- =====================================================

-- 14. Reconstruct the complete order report.
SELECT
    o.order_id,
    c.customer_name,
    c.customer_city,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM demo_norm_orders AS o
INNER JOIN demo_norm_customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN demo_norm_order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN demo_norm_products AS p
    ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_id;

-- 15. Calculate total order amounts.
SELECT
    o.order_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price)
        AS order_total
FROM demo_norm_orders AS o
INNER JOIN demo_norm_customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN demo_norm_order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    c.customer_id,
    c.customer_name
ORDER BY o.order_id;

-- 16. Calculate customer spending.
SELECT
    c.customer_name,
    SUM(oi.quantity * oi.unit_price)
        AS total_spending
FROM demo_norm_customers AS c
INNER JOIN demo_norm_orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN demo_norm_order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;

-- 17. Observe the normalized structure.
SHOW TABLES LIKE 'demo_norm_%';

-- Important:
-- Customer information is stored once.
-- Product information is stored once.
-- Order items reference related records.
--
-- The unit_price in order_items represents
-- the historical price at the time of sale.
--
-- Normalization improves consistency,
-- but the best design also depends on
-- business rules and functional dependencies.
