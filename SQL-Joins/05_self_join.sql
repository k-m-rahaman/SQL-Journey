
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 05_self_join.sql
    Topic: SELF JOIN
========================================================

Description:
SELF JOIN joins a table to itself.

The same table is referenced using different
aliases to represent different roles.

Common Applications:
1. Employee-manager relationships
2. Organizational hierarchy
3. Finding employees with the same manager
4. Finding colleagues in the same department

========================================================
*/

USE sql_journey;

-- 1. Basic SELF JOIN
-- Retrieve employees with their manager names.
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM join_employees AS e
INNER JOIN join_employees AS m
    ON e.manager_id = m.employee_id;

-- 2. SELF JOIN using LEFT JOIN
-- Include employees who have no manager.
SELECT
    e.employee_name AS employee,
    COALESCE(
        m.employee_name,
        'No Manager'
    ) AS manager
FROM join_employees AS e
LEFT JOIN join_employees AS m
    ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

-- 3. Retrieve employees reporting to Priya Das.
SELECT
    e.employee_name,
    e.job_title,
    m.employee_name AS manager
FROM join_employees AS e
INNER JOIN join_employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_name = 'Priya Das';

-- 4. Find employees without a manager.
SELECT
    e.employee_id,
    e.employee_name,
    e.job_title
FROM join_employees AS e
LEFT JOIN join_employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_id IS NULL;

-- 5. Count direct reports for each manager.
SELECT
    m.employee_name AS manager,
    COUNT(e.employee_id) AS direct_reports
FROM join_employees AS m
INNER JOIN join_employees AS e
    ON e.manager_id = m.employee_id
GROUP BY
    m.employee_id,
    m.employee_name
ORDER BY direct_reports DESC;

-- 6. Find pairs of employees in the same department.
-- The condition e1.employee_id < e2.employee_id
-- avoids self-pairs and duplicate reversed pairs.
SELECT
    e1.employee_name AS employee_one,
    e2.employee_name AS employee_two,
    e1.department_id
FROM join_employees AS e1
INNER JOIN join_employees AS e2
    ON e1.department_id = e2.department_id
   AND e1.employee_id < e2.employee_id
ORDER BY e1.department_id;

-- 7. Practical example
-- Display employees, managers, and departments.
SELECT
    e.employee_name AS employee,
    e.job_title,
    COALESCE(
        m.employee_name,
        'Top-Level / Unassigned'
    ) AS manager,
    COALESCE(
        d.department_name,
        'Not Assigned'
    ) AS department
FROM join_employees AS e
LEFT JOIN join_employees AS m
    ON e.manager_id = m.employee_id
LEFT JOIN join_departments AS d
    ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- Note:
-- A SELF JOIN is not a separate SQL keyword.
-- It uses a normal JOIN with the same table
-- appearing more than once under different aliases.
