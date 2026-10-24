
/*
========================================================
    SQL JOURNEY
    Module 08: SQL Set Operations
    File: 01_union.sql
    Topic: UNION Operator
========================================================

Description:
UNION combines the results of multiple
SELECT statements into one result set.

Duplicate rows are automatically removed.

Rules:
1. Each SELECT must return the same number of columns.
2. Corresponding columns must have compatible types.
3. Column names come from the first SELECT.
4. UNION removes duplicate result rows.
5. ORDER BY is placed at the end of the query.

Concepts Covered:
1. Basic UNION
2. UNION with overlapping records
3. UNION with multiple columns
4. UNION with different tables
5. UNION with ORDER BY
6. UNION with filtering
7. Practical employee reporting

========================================================
*/

USE sql_journey;

-- 1. Basic UNION
-- Combine employees from departments 101 and 102.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id = 101

UNION

SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id = 102;

-- 2. UNION with overlapping records
-- Department 102 appears in both queries,
-- but duplicate rows are removed.
SELECT
    employee_id,
    employee_name,
    department_id
FROM employees
WHERE department_id IN (101, 102)

UNION

SELECT
    employee_id,
    employee_name,
    department_id
FROM employees
WHERE department_id IN (102, 103)

ORDER BY department_id, employee_id;

-- 3. UNION with salary filtering
-- Combine employees who earn at least 70000
-- with employees who joined during 2024.
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary >= 70000

UNION

SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE joining_date >= '2024-01-01'
  AND joining_date < '2025-01-01'

ORDER BY salary DESC;

-- 4. UNION with different tables
-- Combine employee names and department names
-- into a single list.
SELECT
    employee_name AS display_name
FROM employees

UNION

SELECT
    department_name
FROM departments

ORDER BY display_name;

-- 5. UNION with a common column alias
-- Combine job titles and department names.
SELECT
    job_title AS category_name
FROM employees
WHERE job_title IS NOT NULL

UNION

SELECT
    department_name
FROM departments

ORDER BY category_name;

-- 6. UNION with a derived table
-- Count unique employees selected by
-- either of two department conditions.
SELECT
    COUNT(*) AS unique_employee_count
FROM (
    SELECT employee_id
    FROM employees
    WHERE department_id IN (101, 102)

    UNION

    SELECT employee_id
    FROM employees
    WHERE department_id IN (102, 103)
) AS combined_employees;

-- 7. Practical example
-- Generate a list of employees who are
-- either high earners or recent joiners.
SELECT
    employee_id,
    employee_name,
    job_title
FROM employees
WHERE salary > 75000

UNION

SELECT
    employee_id,
    employee_name,
    job_title
FROM employees
WHERE joining_date >= '2024-01-01'

ORDER BY employee_name;

-- 8. Compare distinct values
-- Combine department IDs from two queries.
SELECT
    department_id
FROM employees
WHERE salary > 60000

UNION

SELECT
    department_id
FROM employees
WHERE joining_date < '2023-01-01'

ORDER BY department_id;

-- Important:
-- UNION compares complete selected rows.
-- If any selected column differs, the
-- two rows are not considered duplicates.
--
-- UNION is equivalent to UNION DISTINCT.
