
/*
========================================================
    SQL JOURNEY
    Module 08: SQL Set Operations
    File: 02_union_all.sql
    Topic: UNION ALL Operator
========================================================

Description:
UNION ALL combines the results of multiple
SELECT statements without removing duplicates.

Unlike UNION, duplicate rows are preserved.

Concepts Covered:
1. Basic UNION ALL
2. UNION vs UNION ALL
3. Duplicate record analysis
4. UNION ALL with COUNT()
5. UNION ALL with source labels
6. Multiple UNION ALL operations
7. Practical employee classification

========================================================
*/

USE sql_journey;

-- 1. Basic UNION ALL
-- Combine employees from two departments.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id = 101

UNION ALL

SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id = 102;

-- 2. UNION ALL with overlapping records
-- Department 102 appears in both queries.
-- Its employees will appear twice.
SELECT
    employee_id,
    employee_name,
    department_id
FROM employees
WHERE department_id IN (101, 102)

UNION ALL

SELECT
    employee_id,
    employee_name,
    department_id
FROM employees
WHERE department_id IN (102, 103)

ORDER BY department_id, employee_id;

-- 3. Compare UNION and UNION ALL
-- UNION removes duplicate results.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id IN (101, 102)

UNION

SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id IN (102, 103);

-- UNION ALL preserves duplicate results.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id IN (101, 102)

UNION ALL

SELECT
    employee_id,
    employee_name
FROM employees
WHERE department_id IN (102, 103);

-- 4. Count all rows including duplicates.
SELECT
    COUNT(*) AS total_rows
FROM (
    SELECT employee_id
    FROM employees
    WHERE department_id IN (101, 102)

    UNION ALL

    SELECT employee_id
    FROM employees
    WHERE department_id IN (102, 103)
) AS combined_results;

-- 5. Find duplicate employees in combined results.
SELECT
    employee_id,
    COUNT(*) AS occurrence_count
FROM (
    SELECT employee_id
    FROM employees
    WHERE department_id IN (101, 102)

    UNION ALL

    SELECT employee_id
    FROM employees
    WHERE department_id IN (102, 103)
) AS combined_results
GROUP BY employee_id
HAVING COUNT(*) > 1
ORDER BY employee_id;

-- 6. UNION ALL with source labels
-- Identify which condition selected each employee.
SELECT
    employee_id,
    employee_name,
    'High Salary' AS selection_reason
FROM employees
WHERE salary >= 70000

UNION ALL

SELECT
    employee_id,
    employee_name,
    'Joined in 2024' AS selection_reason
FROM employees
WHERE joining_date >= '2024-01-01'
  AND joining_date < '2025-01-01'

ORDER BY employee_id, selection_reason;

-- 7. Combine three result sets.
SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id = 101

UNION ALL

SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id = 102

UNION ALL

SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id = 103

ORDER BY department_id, employee_name;

-- 8. Practical example
-- Create a report of employee categories.
-- An employee may belong to multiple categories.
SELECT
    employee_id,
    employee_name,
    'Senior Earner' AS employee_category
FROM employees
WHERE salary >= 75000

UNION ALL

SELECT
    employee_id,
    employee_name,
    'Early Joiner' AS employee_category
FROM employees
WHERE joining_date < '2023-01-01'

ORDER BY employee_id, employee_category;

-- 9. Count employees in each generated category.
SELECT
    employee_category,
    COUNT(*) AS employee_count
FROM (
    SELECT
        employee_id,
        'Senior Earner' AS employee_category
    FROM employees
    WHERE salary >= 75000

    UNION ALL

    SELECT
        employee_id,
        'Early Joiner' AS employee_category
    FROM employees
    WHERE joining_date < '2023-01-01'
) AS categorized_employees
GROUP BY employee_category
ORDER BY employee_category;

-- Important:
-- UNION ALL does not remove duplicate rows.
--
-- It is generally more efficient than UNION
-- when duplicate elimination is unnecessary.
--
-- Use UNION ALL for logs, transaction
-- records, and combined event reports
-- where repeated rows may be meaningful.
