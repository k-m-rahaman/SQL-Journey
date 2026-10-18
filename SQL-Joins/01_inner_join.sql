
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 01_inner_join.sql
    Topic: INNER JOIN
========================================================

Description:
INNER JOIN returns rows with matching values
in both tables.

Unmatched records are excluded.

Concepts Covered:
1. Basic INNER JOIN
2. INNER JOIN with aliases
3. INNER JOIN with WHERE
4. INNER JOIN with ORDER BY
5. INNER JOIN with aggregation
6. Multiple INNER JOINs

========================================================
*/

USE sql_journey;

-- 1. Basic INNER JOIN
-- Display employees with their department names.
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id;

-- 2. INNER JOIN with multiple columns.
-- Retrieve employee information and location.
SELECT
    e.employee_name,
    e.job_title,
    e.salary,
    d.department_name,
    d.location
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id;

-- 3. INNER JOIN with WHERE
-- Find employees in the Engineering department.
SELECT
    e.employee_name,
    e.job_title,
    d.department_name
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id
WHERE d.department_name = 'Engineering';

-- 4. INNER JOIN with ORDER BY
-- Display employees ordered by salary.
SELECT
    e.employee_name,
    e.salary,
    d.department_name
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id
ORDER BY e.salary DESC;

-- 5. INNER JOIN with GROUP BY
-- Count employees in each represented department.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_employees DESC;

-- 6. Practical example
-- Display department-wise average salary.
SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY average_salary DESC;

-- 7. Multiple INNER JOINs
-- Join employees with departments and managers.
-- This example returns employees with a manager
-- and an assigned department.
SELECT
    e.employee_name,
    e.job_title,
    d.department_name,
    m.employee_name AS manager_name
FROM join_employees AS e
INNER JOIN join_departments AS d
    ON e.department_id = d.department_id
INNER JOIN join_employees AS m
    ON e.manager_id = m.employee_id;

-- Note:
-- Ishita Paul is excluded because her
-- department_id is NULL.
-- The Legal department has no matching employees.
