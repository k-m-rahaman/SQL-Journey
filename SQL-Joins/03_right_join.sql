
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 03_right_join.sql
    Topic: RIGHT JOIN
========================================================

Description:
RIGHT JOIN returns all rows from the right
table and matching rows from the left table.

Unmatched left-side columns contain NULL.

Concepts Covered:
1. Basic RIGHT JOIN
2. RIGHT JOIN with COALESCE()
3. Finding unmatched records
4. RIGHT JOIN with aggregation
5. RIGHT JOIN vs LEFT JOIN

========================================================
*/

USE sql_journey;

-- 1. Basic RIGHT JOIN
-- Display all departments and their employees.
SELECT
    d.department_id,
    d.department_name,
    e.employee_name
FROM join_employees AS e
RIGHT JOIN join_departments AS d
    ON e.department_id = d.department_id
ORDER BY d.department_id, e.employee_id;

-- 2. RIGHT JOIN with COALESCE()
-- Display a meaningful value when no employee exists.
SELECT
    d.department_name,
    COALESCE(
        e.employee_name,
        'No Employees'
    ) AS employee
FROM join_employees AS e
RIGHT JOIN join_departments AS d
    ON e.department_id = d.department_id
ORDER BY d.department_id;

-- 3. Find departments without employees.
SELECT
    d.department_id,
    d.department_name,
    d.location
FROM join_employees AS e
RIGHT JOIN join_departments AS d
    ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;

-- 4. Count employees in every department.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM join_employees AS e
RIGHT JOIN join_departments AS d
    ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY employee_count DESC;

-- 5. Calculate department salary totals.
SELECT
    d.department_name,
    COALESCE(
        SUM(e.salary),
        0
    ) AS total_salary
FROM join_employees AS e
RIGHT JOIN join_departments AS d
    ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_salary DESC;

-- 6. RIGHT JOIN equivalent using LEFT JOIN.
-- Reversing table order produces the same
-- rows as the first RIGHT JOIN example.
SELECT
    d.department_id,
    d.department_name,
    e.employee_name
FROM join_departments AS d
LEFT JOIN join_employees AS e
    ON d.department_id = e.department_id
ORDER BY d.department_id, e.employee_id;

-- 7. Practical example
-- Create a department staffing report.
SELECT
    d.department_name,
    d.location,
    COUNT(e.employee_id) AS total_staff,
    CASE
        WHEN COUNT(e.employee_id) = 0
            THEN 'Vacant Department'
        ELSE 'Staff Available'
    END AS staffing_status
FROM join_employees AS e
RIGHT JOIN join_departments AS d
    ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name,
    d.location
ORDER BY d.department_id;

-- Note:
-- Legal appears in the results even though
-- no employee belongs to that department.
--
-- A RIGHT JOIN can often be rewritten
-- as a LEFT JOIN by reversing table order.
