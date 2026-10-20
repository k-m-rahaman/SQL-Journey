
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 04_full_join.sql
    Topic: FULL OUTER JOIN
========================================================

Description:
FULL OUTER JOIN includes all records from
both tables.

Results contain:
1. Matching records from both tables
2. Unmatched records from the left table
3. Unmatched records from the right table

Important:
MySQL does not directly support FULL OUTER JOIN.

We simulate it using:
LEFT JOIN + UNION ALL + unmatched RIGHT JOIN rows.

========================================================
*/

USE sql_journey;

-- 1. Simulate FULL OUTER JOIN.
-- Retrieve every department and employee.
SELECT
    d.department_id,
    d.department_name,
    e.employee_id,
    e.employee_name
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id

UNION ALL

SELECT
    d.department_id,
    d.department_name,
    e.employee_id,
    e.employee_name
FROM join_departments AS d
RIGHT JOIN join_employees AS e
    ON d.department_id = e.department_id
WHERE d.department_id IS NULL;

-- 2. FULL OUTER JOIN using two LEFT JOINs.
-- Useful when you want to avoid RIGHT JOIN.
SELECT
    d.department_name,
    e.employee_name,
    e.job_title
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id

UNION ALL

SELECT
    d.department_name,
    e.employee_name,
    e.job_title
FROM join_employees AS e
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- 3. FULL OUTER JOIN with readable NULL values.
SELECT
    COALESCE(
        d.department_name,
        'No Department'
    ) AS department,
    COALESCE(
        e.employee_name,
        'No Employee'
    ) AS employee
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id

UNION ALL

SELECT
    COALESCE(
        d.department_name,
        'No Department'
    ) AS department,
    COALESCE(
        e.employee_name,
        'No Employee'
    ) AS employee
FROM join_departments AS d
RIGHT JOIN join_employees AS e
    ON d.department_id = e.department_id
WHERE d.department_id IS NULL;

-- 4. Practical example
-- Create a report showing unmatched records.
SELECT
    d.department_name,
    e.employee_name,
    CASE
        WHEN e.employee_id IS NULL
            THEN 'Department Without Employee'
        WHEN d.department_id IS NULL
            THEN 'Employee Without Department'
        ELSE 'Matched'
    END AS match_status
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id

UNION ALL

SELECT
    d.department_name,
    e.employee_name,
    CASE
        WHEN d.department_id IS NULL
            THEN 'Employee Without Department'
        ELSE 'Matched'
    END AS match_status
FROM join_departments AS d
RIGHT JOIN join_employees AS e
    ON d.department_id = e.department_id
WHERE d.department_id IS NULL;

-- Note:
-- UNION ALL preserves all result rows.
-- The WHERE clause in the second query
-- prevents matched records from being repeated.
--
-- The first query includes all departments.
-- The second adds employees missing a department.
