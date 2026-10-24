
/*
========================================================
    SQL JOURNEY
    Module 08: SQL Set Operations
    File: 03_intersect.sql
    Topic: INTERSECT Operator
========================================================

Description:
INTERSECT returns rows that are present
in both SELECT query results.

Duplicate rows are removed by default.

Requirements:
MySQL 8.0.31 or later.

Concepts Covered:
1. Basic INTERSECT
2. INTERSECT with multiple columns
3. INTERSECT with department filtering
4. INTERSECT with JOIN
5. INTERSECT with COUNT()
6. INTERSECT alternatives using EXISTS
7. Practical employee analysis

========================================================
*/

USE sql_journey;

-- Check the MySQL server version.
SELECT VERSION() AS mysql_version;

-- 1. Basic INTERSECT
-- Find employees who:
-- A. Earn at least 60000.
-- B. Joined before January 1, 2024.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE salary >= 60000

INTERSECT

SELECT
    employee_id,
    employee_name
FROM employees
WHERE joining_date < '2024-01-01'

ORDER BY employee_id;

-- 2. INTERSECT with multiple columns
-- Find employees who belong to departments
-- 101 or 105 AND earn at least 60000.
SELECT
    employee_id,
    employee_name,
    department_id
FROM employees
WHERE department_id IN (101, 105)

INTERSECT

SELECT
    employee_id,
    employee_name,
    department_id
FROM employees
WHERE salary >= 60000

ORDER BY department_id, employee_id;

-- 3. INTERSECT with employee names
-- Find employees who work in department 101
-- and also earn more than 60000.
SELECT
    employee_name
FROM employees
WHERE department_id = 101

INTERSECT

SELECT
    employee_name
FROM employees
WHERE salary > 60000;

-- 4. INTERSECT with department records
-- Find Kolkata or Hyderabad departments
-- that have employees earning above 70000.
SELECT
    department_id,
    department_name
FROM departments
WHERE location IN ('Kolkata', 'Hyderabad')

INTERSECT

SELECT
    d.department_id,
    d.department_name
FROM departments AS d
INNER JOIN employees AS e
    ON d.department_id = e.department_id
WHERE e.salary > 70000;

-- 5. INTERSECT with COUNT()
-- Count employees who satisfy both
-- salary and joining-date conditions.
SELECT
    COUNT(*) AS matching_employees
FROM (
    SELECT employee_id
    FROM employees
    WHERE salary >= 60000

    INTERSECT

    SELECT employee_id
    FROM employees
    WHERE joining_date < '2024-01-01'
) AS common_employees;

-- 6. Alternative using EXISTS
-- Works on MySQL versions before 8.0.31.
-- Equivalent to Example 1 for this dataset.
SELECT
    e.employee_id,
    e.employee_name
FROM employees AS e
WHERE e.salary >= 60000
  AND EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.employee_id = e.employee_id
        AND e2.joining_date < '2024-01-01'
  )
ORDER BY e.employee_id;

-- 7. Alternative using INNER JOIN
-- Also works on older MySQL versions.
SELECT DISTINCT
    e1.employee_id,
    e1.employee_name
FROM employees AS e1
INNER JOIN employees AS e2
    ON e1.employee_id = e2.employee_id
WHERE e1.salary >= 60000
  AND e2.joining_date < '2024-01-01'
ORDER BY e1.employee_id;

-- 8. Practical example
-- Find employees earning more than 65000
-- who also joined before January 1, 2023.
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary > 65000

INTERSECT

SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE joining_date < '2023-01-01'

ORDER BY salary DESC;

-- Important:
-- INTERSECT returns common result rows.
--
-- By default, INTERSECT removes duplicates.
--
-- INTERSECT compares all selected columns,
-- not just one column.
--
-- INTERSECT is available in MySQL 8.0.31+.
-- Use EXISTS or JOIN for older installations.
