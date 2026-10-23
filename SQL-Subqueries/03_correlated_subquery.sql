
/*
========================================================
    SQL JOURNEY
    Module 07: SQL Subqueries
    File: 03_correlated_subquery.sql
    Topic: Correlated Subqueries
========================================================

Description:
A correlated subquery references values from
the outer query.

Unlike an independent subquery, its result
depends on the current outer row.

Concepts Covered:
1. Correlated subquery with AVG()
2. Correlated subquery with MAX()
3. Correlated subquery with COUNT()
4. EXISTS
5. NOT EXISTS
6. Department-wise salary comparisons

========================================================
*/

USE sql_journey;

-- 1. Basic correlated subquery
-- Find employees earning more than their
-- own department's average salary.
SELECT
    e.employee_name,
    e.department_id,
    e.salary
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.department_id;

-- 2. Find highest-paid employees in each department.
SELECT
    e.employee_name,
    e.department_id,
    e.salary
FROM employees AS e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.department_id;

-- 3. Find lowest-paid employees in each department.
SELECT
    e.employee_name,
    e.department_id,
    e.salary
FROM employees AS e
WHERE e.salary = (
    SELECT MIN(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.department_id;

-- 4. Correlated subquery with COUNT()
-- Count employees within each department.
SELECT
    d.department_name,
    (
        SELECT COUNT(*)
        FROM employees AS e
        WHERE e.department_id = d.department_id
    ) AS total_employees
FROM departments AS d
ORDER BY d.department_id;

-- 5. EXISTS
-- Find departments having at least one
-- employee earning more than 70000.
SELECT
    d.department_id,
    d.department_name
FROM departments AS d
WHERE EXISTS (
    SELECT 1
    FROM employees AS e
    WHERE e.department_id = d.department_id
      AND e.salary > 70000
);

-- 6. NOT EXISTS
-- Find departments without any employee
-- earning more than 80000.
SELECT
    d.department_name
FROM departments AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees AS e
    WHERE e.department_id = d.department_id
      AND e.salary > 80000
);

-- 7. Practical example
-- Find employees earning less than their
-- department's average salary.
SELECT
    e.employee_name,
    e.salary,
    e.department_id
FROM employees AS e
WHERE e.salary < (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.department_id;

-- 8. Practical example
-- Display employee salaries alongside
-- their department's average salary.
SELECT
    e.employee_name,
    e.salary,
    e.department_id,
    ROUND(
        (
            SELECT AVG(e2.salary)
            FROM employees AS e2
            WHERE e2.department_id = e.department_id
        ),
        2
    ) AS department_average
FROM employees AS e
ORDER BY e.department_id, e.salary DESC;

-- 9. Find employees who have no colleagues
-- earning a higher salary in their department.
-- Tied highest earners are all included.
SELECT
    e.employee_name,
    e.department_id,
    e.salary
FROM employees AS e
WHERE NOT EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > e.salary
)
ORDER BY e.department_id;

-- Note:
-- The inner query references columns
-- from the outer query.
--
-- EXISTS checks whether at least one
-- matching row exists.
--
-- NOT EXISTS checks whether no matching
-- row exists.
