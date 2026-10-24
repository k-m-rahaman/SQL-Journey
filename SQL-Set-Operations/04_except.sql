
/*
========================================================
    SQL JOURNEY
    Module 08: SQL Set Operations
    File: 04_except.sql
    Topic: EXCEPT Operator
========================================================

Description:
EXCEPT returns rows from the first SELECT
that do not appear in the second SELECT.

Duplicates are removed by default.

Requirements:
MySQL 8.0.31 or later.

Concepts Covered:
1. Basic EXCEPT
2. EXCEPT with salary conditions
3. EXCEPT with department records
4. EXCEPT with multiple columns
5. EXCEPT with COUNT()
6. EXCEPT vs NOT EXISTS
7. Practical employee filtering

========================================================
*/

USE sql_journey;

-- Check the MySQL server version.
SELECT VERSION() AS mysql_version;

-- 1. Basic EXCEPT
-- Find employees earning at least 60000
-- who did NOT join before January 1, 2024.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE salary >= 60000

EXCEPT

SELECT
    employee_id,
    employee_name
FROM employees
WHERE joining_date < '2024-01-01'

ORDER BY employee_id;

-- 2. EXCEPT with date filtering
-- Find employees who joined in 2024
-- but do not earn 60000 or more.
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE joining_date >= '2024-01-01'
  AND joining_date < '2025-01-01'

EXCEPT

SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary >= 60000

ORDER BY employee_id;

-- 3. EXCEPT with departments
-- Find departments that do not have
-- any employee earning above 70000.
SELECT
    department_id,
    department_name
FROM departments

EXCEPT

SELECT
    d.department_id,
    d.department_name
FROM departments AS d
INNER JOIN employees AS e
    ON d.department_id = e.department_id
WHERE e.salary > 70000

ORDER BY department_id;

-- 4. EXCEPT with multiple columns
-- Find employees earning more than 50000,
-- excluding employees from departments
-- 101 and 105.
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary > 50000

EXCEPT

SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE department_id IN (101, 105)

ORDER BY salary DESC;

-- 5. EXCEPT with COUNT()
-- Count employees earning at least 60000
-- who did not join before January 1, 2024.
SELECT
    COUNT(*) AS remaining_employees
FROM (
    SELECT employee_id
    FROM employees
    WHERE salary >= 60000

    EXCEPT

    SELECT employee_id
    FROM employees
    WHERE joining_date < '2024-01-01'
) AS remaining_records;

-- 6. EXCEPT using different query order
-- Demonstrate that changing the order
-- changes the results.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE joining_date >= '2024-01-01'

EXCEPT

SELECT
    employee_id,
    employee_name
FROM employees
WHERE salary >= 60000

ORDER BY employee_id;

-- 7. Alternative using NOT EXISTS
-- Compatible with older MySQL 8.0 versions.
-- Equivalent to Example 1 for this dataset.
SELECT
    e.employee_id,
    e.employee_name
FROM employees AS e
WHERE e.salary >= 60000
  AND NOT EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.employee_id = e.employee_id
        AND e2.joining_date < '2024-01-01'
  )
ORDER BY e.employee_id;

-- 8. Practical example
-- Find departments without employees
-- earning 80000 or more.
SELECT
    department_id,
    department_name
FROM departments

EXCEPT

SELECT
    d.department_id,
    d.department_name
FROM departments AS d
INNER JOIN employees AS e
    ON d.department_id = e.department_id
WHERE e.salary >= 80000

ORDER BY department_id;

-- 9. Practical example
-- Find employees who joined before 2024
-- excluding employees earning above 75000.
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE joining_date < '2024-01-01'

EXCEPT

SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary > 75000

ORDER BY salary DESC;

-- Important:
-- EXCEPT returns rows belonging to the
-- first query but not the second query.
--
-- EXCEPT removes duplicates by default.
--
-- Query order matters:
-- A EXCEPT B is not equivalent to B EXCEPT A.
--
-- NOT EXISTS can provide equivalent
-- filtering when comparing non-NULL primary keys.
--
-- EXCEPT is supported in MySQL 8.0.31+.
