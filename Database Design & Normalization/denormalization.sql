
/*
========================================================
    SQL JOURNEY
    Module 11: Database Design & Normalization
    File: denormalization.sql
    Topic: Database Denormalization
========================================================

Description:
Denormalization intentionally stores repeated
or precomputed data for faster or simpler reads.

Advantages:
1. Simplifies reporting queries
2. Can reduce repeated JOIN operations
3. Supports precomputed analytical results

Disadvantages:
1. Additional storage
2. Duplicate data
3. Risk of outdated information
4. More complex update synchronization

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: NORMALIZED SOURCE TABLES
-- =====================================================

-- 1. Reset demonstration tables.
DROP TABLE IF EXISTS demo_denorm_report;
DROP TABLE IF EXISTS demo_denorm_orders;
DROP TABLE IF EXISTS demo_denorm_customers;

-- 2. Create the customers table.
CREATE TABLE demo_denorm_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL
);

-- 3. Create the orders table.
CREATE TABLE demo_denorm_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES demo_denorm_customers(customer_id),

    CHECK (order_amount >= 0)
);

-- 4. Insert customer records.
INSERT INTO demo_denorm_customers VALUES
    (1, 'Arjun Sharma', 'Kolkata'),
    (2, 'Priya Das', 'Delhi'),
    (3, 'Rahul Sen', 'Mumbai');

-- 5. Insert order records.
INSERT INTO demo_denorm_orders VALUES
    (101, 1, 2500),
    (102, 1, 1800),
    (103, 2, 3200),
    (104, 3, 1500),
    (105, 2, 2700);

-- 6. Normalized report using a JOIN.
SELECT
    o.order_id,
    c.customer_name,
    c.customer_city,
    o.order_amount
FROM demo_denorm_orders AS o
INNER JOIN demo_denorm_customers AS c
    ON o.customer_id = c.customer_id
ORDER BY o.order_id;


-- =====================================================
-- SECTION 2: DENORMALIZED REPORT TABLE
-- =====================================================

-- 7. Create a reporting snapshot.
-- Customer information is copied into
-- a table containing order information.
CREATE TABLE demo_denorm_report AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_name,
    c.customer_city,
    o.order_amount
FROM demo_denorm_orders AS o
INNER JOIN demo_denorm_customers AS c
    ON o.customer_id = c.customer_id;

-- 8. Add a primary key to the report table.
ALTER TABLE demo_denorm_report
ADD PRIMARY KEY (order_id);

-- 9. Display the reporting snapshot.
-- No JOIN is required for this query.
SELECT *
FROM demo_denorm_report
ORDER BY order_id;

-- 10. Find orders from Kolkata.
SELECT
    order_id,
    customer_name,
    order_amount
FROM demo_denorm_report
WHERE customer_city = 'Kolkata';

-- 11. Calculate customer spending.
SELECT
    customer_id,
    customer_name,
    SUM(order_amount) AS total_spending
FROM demo_denorm_report
GROUP BY customer_id, customer_name
ORDER BY total_spending DESC;


-- =====================================================
-- SECTION 3: UPDATE ANOMALY
-- =====================================================

-- 12. Update the source customer address.
UPDATE demo_denorm_customers
SET customer_city = 'Pune'
WHERE customer_id = 1;

-- 13. Compare the original source against
-- the reporting snapshot.
-- The snapshot still shows Kolkata.
SELECT
    r.order_id,
    c.customer_city AS source_city,
    r.customer_city AS report_city
FROM demo_denorm_report AS r
INNER JOIN demo_denorm_customers AS c
    ON r.customer_id = c.customer_id
WHERE r.customer_id = 1;

-- 14. Synchronize copied customer details.
UPDATE demo_denorm_report AS r
INNER JOIN demo_denorm_customers AS c
    ON r.customer_id = c.customer_id
SET
    r.customer_name = c.customer_name,
    r.customer_city = c.customer_city;

-- 15. Verify synchronization.
SELECT
    order_id,
    customer_name,
    customer_city,
    order_amount
FROM demo_denorm_report
ORDER BY order_id;


-- =====================================================
-- SECTION 4: REPORTING ANALYSIS
-- =====================================================

-- 16. Group revenue by city.
SELECT
    customer_city,
    COUNT(*) AS total_orders,
    SUM(order_amount) AS total_revenue
FROM demo_denorm_report
GROUP BY customer_city
ORDER BY total_revenue DESC;

-- 17. Compare storage row counts.
SELECT
    (SELECT COUNT(*)
     FROM demo_denorm_customers) AS customers,

    (SELECT COUNT(*)
     FROM demo_denorm_orders) AS orders,

    (SELECT COUNT(*)
     FROM demo_denorm_report) AS report_rows;

-- 18. Display the table structure.
SHOW CREATE TABLE demo_denorm_report;

-- Important:
-- The report table is a stored snapshot.
--
-- Updates to the source tables are not
-- automatically reflected in the report.
--
-- A real application needs a reliable
-- refresh or synchronization strategy.
--
-- Denormalization does not always improve
-- performance; measure actual workloads.
