
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 02_left_join.sql
    Topic: LEFT JOIN
========================================================

Description:
LEFT JOIN returns all rows from the left table
and matching rows from the right table.

If no matching row exists, the columns from
the right table contain NULL values.

Concepts Covered:
1. Basic LEFT JOIN
2. LEFT JOIN with COALESCE()
3. Finding unmatched records
4. LEFT JOIN with WHERE
5. LEFT JOIN with GROUP BY
6. Employee and department reporting

========================================================
*/

USE sql_journey;

-- 1. Basic LEFT JOIN
-- Display all employees, including those
-- without an assigned department.
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name
FROM join_employees AS e
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- 2. LEFT JOIN with COALESCE()
-- Replace missing department names with text.
SELECT
    e.employee_name,
    COALESCE(
        d.department_name,
        'Not Assigned'
    ) AS department
FROM join_employees AS e
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id;

-- 3. Find employees without departments.
SELECT
    e.employee_id,
    e.employee_name,
    e.job_title
FROM join_employees AS e
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- 4. LEFT JOIN with WHERE
-- Find employees earning more than 60000.
SELECT
    e.employee_name,
    e.salary,
    d.department_name
FROM join_employees AS e
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id
WHERE e.salary > 60000
ORDER BY e.salary DESC;

-- 5. Count employees in every department.
-- All departments are preserved.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY d.department_id;

-- 6. Find departments without employees.
SELECT
    d.department_id,
    d.department_name
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- 7. Practical example
-- Generate a complete employee report.
SELECT
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.salary,
    COALESCE(
        d.department_name,
        'Unassigned'
    ) AS department,
    COALESCE(
        d.location,
        'Not Available'
    ) AS location
FROM join_employees AS e
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- Note:
-- LEFT JOIN preserves every row from the
-- table appearing before LEFT JOIN.
-- Here, Ishita Paul is included even though
-- she does not have a department.
