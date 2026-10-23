
/*
========================================================
    SQL JOURNEY
    Module 07: SQL Subqueries
    File: 04_nested_subquery.sql
    Topic: Nested Subqueries
========================================================

Description:
Nested subqueries contain multiple levels
of SQL queries.

They help break complicated database
operations into smaller logical steps.

Concepts Covered:
1. Basic nested subqueries
2. Nested IN conditions
3. Nested aggregate functions
4. Multiple levels of queries
5. Department-wise analysis
6. Practical salary reporting

========================================================
*/

USE sql_journey;

-- 1. Basic nested subquery
-- Find employees belonging to the department
-- of the highest-paid employee.
SELECT
    employee_name,
    salary,
    department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE salary = (
        SELECT MAX(salary)
        FROM employees
    )
)
ORDER BY salary DESC;

-- 2. Nested subquery using departments
-- Find employees in departments located
-- in the same city as department 101.
SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location = (
        SELECT location
        FROM departments
        WHERE department_id = 101
    )
);

-- 3. Nested subquery with AVG()
-- Find employees earning more than the
-- average salary of employees working
-- in Kolkata-based departments.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id IN (
        SELECT department_id
        FROM departments
        WHERE location = 'Kolkata'
    )
)
ORDER BY salary DESC;

-- 4. Nested IN and aggregate subqueries
-- Find employees working in departments
-- whose average salary is greater than
-- the overall company average.
SELECT
    employee_name,
    department_id,
    salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) > (
        SELECT AVG(salary)
        FROM employees
    )
)
ORDER BY department_id, salary DESC;

-- 5. Find employees earning above the
-- company average who also belong to
-- departments with above-average salaries.
SELECT
    employee_name,
    department_id,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
AND department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) > (
        SELECT AVG(salary)
        FROM employees
    )
)
ORDER BY salary DESC;

-- 6. Nested subquery using MAX() and AVG()
-- Find departments having the highest
-- average employee salary.
SELECT
    d.department_id,
    d.department_name
FROM departments AS d
WHERE d.department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) = (
        SELECT MAX(department_average)
        FROM (
            SELECT
                AVG(salary) AS department_average
            FROM employees
            GROUP BY department_id
        ) AS salary_summary
    )
);

-- 7. Practical example
-- Find employees working in departments
-- where total payroll is above the average
-- department payroll.
SELECT
    employee_name,
    department_id,
    salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING SUM(salary) > (
        SELECT AVG(department_total)
        FROM (
            SELECT
                SUM(salary) AS department_total
            FROM employees
            GROUP BY department_id
        ) AS department_payroll
    )
)
ORDER BY department_id, salary DESC;

-- 8. Practical example
-- Find employees earning more than the
-- second-highest distinct salary.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (
        SELECT MAX(salary)
        FROM employees
    )
);

-- Note:
-- Nested subqueries can contain multiple
-- levels of query execution.
--
-- A derived table in the FROM clause
-- requires an alias in MySQL.
--
-- Deep nesting can reduce readability.
-- CTEs and JOINs can sometimes provide
-- cleaner alternatives.
