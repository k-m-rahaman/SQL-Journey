
/*
========================================================
    SQL JOURNEY
    Module 07: SQL Subqueries
    File: 01_single_row.sql
    Topic: Single-Row Subqueries
========================================================

Description:
A single-row subquery returns one row.

Scalar subqueries return a single value and
can be used with comparison operators.

Concepts Covered:
1. Subquery with AVG()
2. Subquery with MAX()
3. Subquery with MIN()
4. Subquery with =
5. Subquery with >
6. Subquery with dates
7. Practical salary comparisons

========================================================
*/

USE sql_journey;

-- 1. Basic single-row subquery
-- Find employees earning above the company average.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- 2. Subquery with MAX()
-- Find the highest-paid employee.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

-- 3. Subquery with MIN()
-- Find the lowest-paid employee.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);

-- 4. Subquery with a comparison operator
-- Find employees earning more than
-- the average salary of department 101.
SELECT
    employee_name,
    salary,
    department_id
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = 101
)
ORDER BY salary DESC;

-- 5. Subquery using employee information
-- Find employees working in the same
-- department as employee ID 9.
SELECT
    employee_name,
    job_title,
    department_id
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE employee_id = 9
);

-- 6. Subquery with dates
-- Find employees who joined before the earliest
-- employee in department 101.
SELECT
    employee_name,
    joining_date
FROM employees
WHERE joining_date < (
    SELECT MIN(joining_date)
    FROM employees
    WHERE department_id = 101
)
ORDER BY joining_date;

-- 7. Subquery with arithmetic calculations
-- Find employees earning at least 20%
-- more than the company average salary.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary >= (
    SELECT AVG(salary) * 1.20
    FROM employees
);

-- 8. Practical example
-- Display employee salaries and compare
-- them against the company average.
SELECT
    employee_name,
    salary,
    ROUND(
        (SELECT AVG(salary) FROM employees),
        2
    ) AS company_average,
    ROUND(
        salary - (SELECT AVG(salary) FROM employees),
        2
    ) AS salary_difference
FROM employees
ORDER BY salary DESC;

-- Note:
-- A scalar subquery must return at most one row.
-- More than one row produces an error.
-- If the subquery returns zero rows,
-- its scalar result is NULL.
