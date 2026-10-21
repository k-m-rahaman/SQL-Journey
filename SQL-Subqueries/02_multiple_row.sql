
/*
========================================================
    SQL JOURNEY
    Module 07: SQL Subqueries
    File: 02_multiple_row.sql
    Topic: Multiple-Row Subqueries
========================================================

Description:
Multiple-row subqueries return more than one
record and are used with operators such as:

1. IN
2. NOT IN
3. ANY
4. ALL

These operators allow comparisons against
multiple values returned by a subquery.

========================================================
*/

USE sql_journey;

-- 1. Subquery with IN
-- Find employees working in departments
-- located in Kolkata or Mumbai.
SELECT
    employee_name,
    department_id,
    salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location IN ('Kolkata', 'Mumbai')
);

-- 2. Subquery with NOT IN
-- Find employees who do not work in
-- departments located in Kolkata.
SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE location = 'Kolkata'
);

-- 3. Subquery with ANY
-- Find employees earning more than at least
-- one employee in department 101.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 101
)
ORDER BY salary DESC;

-- 4. Subquery with ALL
-- Find employees earning more than every
-- employee in department 102.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 102
)
ORDER BY salary DESC;

-- 5. IN with salary conditions
-- Find employees working in departments
-- containing at least one employee
-- earning 75000 or more.
SELECT
    employee_name,
    department_id,
    salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE salary >= 75000
)
ORDER BY department_id, salary DESC;

-- 6. NOT IN with employee IDs
-- Find employees who did not join in 2024.
SELECT
    employee_name,
    joining_date
FROM employees
WHERE employee_id NOT IN (
    SELECT employee_id
    FROM employees
    WHERE joining_date >= '2024-01-01'
      AND joining_date < '2025-01-01'
)
ORDER BY joining_date;

-- 7. Multiple-row subquery with DISTINCT
-- Find departments having employees
-- whose salaries exceed 70000.
SELECT
    department_id,
    department_name
FROM departments
WHERE department_id IN (
    SELECT DISTINCT department_id
    FROM employees
    WHERE salary > 70000
);

-- 8. Practical example
-- Find employees who earn more than
-- all employees in the Finance department.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 103
)
ORDER BY salary DESC;

-- Note:
-- IN checks membership in a set.
-- ANY compares against at least one value.
-- ALL requires the comparison to hold
-- for every returned value.
--
-- Be careful with NOT IN when the subquery
-- can return NULL values.
-- NOT EXISTS is often safer in that situation.
