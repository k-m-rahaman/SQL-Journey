
/*
========================================================
    SQL JOURNEY
    Module 09: Advanced SQL
    File: 02_indexes.sql
    Topic: SQL Indexes
========================================================

Description:
Indexes help MySQL locate data efficiently.

They can improve query performance when
working with large datasets.

Concepts Covered:
1. CREATE INDEX
2. Single-column indexes
3. Composite indexes
4. UNIQUE indexes
5. SHOW INDEX
6. EXPLAIN
7. ANALYZE TABLE
8. DROP INDEX

========================================================
*/

USE sql_journey;

-- 1. Reset the demonstration table.
DROP TABLE IF EXISTS demo_index_employees;

-- 2. Create a dedicated employee table.
CREATE TABLE demo_index_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10, 2),
    joining_date DATE
) ENGINE = InnoDB;

-- 3. Copy sample employee data.
-- Generate unique example email addresses.
INSERT INTO demo_index_employees (
    employee_id,
    employee_name,
    email,
    department_id,
    salary,
    joining_date
)
SELECT
    employee_id,
    employee_name,
    CONCAT(
        'employee',
        employee_id,
        '@example.com'
    ),
    department_id,
    salary,
    joining_date
FROM employees;

-- 4. View the sample records.
SELECT *
FROM demo_index_employees
ORDER BY employee_id;

-- 5. Analyze a query before adding an index.
EXPLAIN
SELECT *
FROM demo_index_employees
WHERE department_id = 101;

-- 6. Create a single-column index.
CREATE INDEX idx_demo_department
ON demo_index_employees (department_id);

-- 7. Create an index on joining_date.
CREATE INDEX idx_demo_joining_date
ON demo_index_employees (joining_date);

-- 8. Create a composite index.
-- Useful for filtering by department
-- and then examining salaries.
CREATE INDEX idx_demo_department_salary
ON demo_index_employees (
    department_id,
    salary
);

-- 9. Create a UNIQUE index.
-- Prevent duplicate email addresses.
CREATE UNIQUE INDEX idx_demo_unique_email
ON demo_index_employees (email);

-- 10. Display all table indexes.
SHOW INDEX FROM demo_index_employees;

-- 11. Analyze the department lookup again.
EXPLAIN
SELECT *
FROM demo_index_employees
WHERE department_id = 101;

-- 12. Examine the composite index.
EXPLAIN
SELECT
    employee_name,
    department_id,
    salary
FROM demo_index_employees
WHERE department_id = 101
  AND salary >= 60000;

-- 13. Retrieve employees by joining date.
SELECT
    employee_name,
    joining_date
FROM demo_index_employees
WHERE joining_date >= '2024-01-01'
ORDER BY joining_date;

-- 14. Lookup an employee using the email.
EXPLAIN
SELECT
    employee_id,
    employee_name
FROM demo_index_employees
WHERE email = 'employee1@example.com';

-- 15. Refresh optimizer statistics.
ANALYZE TABLE demo_index_employees;

-- 16. Demonstrate removing an index.
-- This removes only the joining-date index.
DROP INDEX idx_demo_joining_date
ON demo_index_employees;

-- 17. Display remaining indexes.
SHOW INDEX FROM demo_index_employees;

-- 18. Compare indexed and unindexed queries.
EXPLAIN
SELECT *
FROM demo_index_employees
WHERE employee_name = 'Arjun Sharma';

EXPLAIN
SELECT *
FROM demo_index_employees
WHERE email = 'employee1@example.com';

-- Important:
-- Indexes improve many data retrieval operations,
-- but they do not guarantee faster queries.
--
-- The optimizer may prefer a full table scan
-- for small datasets like this demonstration.
--
-- Composite index column order matters.
--
-- Too many indexes increase storage and
-- can slow INSERT, UPDATE, and DELETE.
