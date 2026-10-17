
/*
========================================================
    SQL JOURNEY
    Module 05: SQL Aggregation
    File: 04_min_max.sql
    Topic: MIN() and MAX() Functions
========================================================

Description:
MIN() finds the smallest value.
MAX() finds the largest value.

These functions work with:
1. Numbers
2. Dates
3. Strings

Concepts Covered:
- Basic MIN() and MAX()
- Grouped minimum and maximum
- Date analysis
- Subqueries
- Salary comparisons

========================================================
*/

USE sql_journey;

-- 1. MIN()
-- Find the lowest employee salary.
SELECT
    MIN(salary) AS lowest_salary
FROM employees;

-- 2. MAX()
-- Find the highest employee salary.
SELECT
    MAX(salary) AS highest_salary
FROM employees;

-- 3. MIN() and MAX() together.
SELECT
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM employees;

-- 4. Find the salary difference.
SELECT
    MAX(salary) - MIN(salary) AS salary_range
FROM employees;

-- 5. Grouped MIN() and MAX()
-- Find salary extremes in each department.
SELECT
    department_id,
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 6. MIN() with dates
-- Find the earliest joining date.
SELECT
    MIN(joining_date) AS earliest_joining
FROM employees;

-- 7. MAX() with dates
-- Find the most recent joining date.
SELECT
    MAX(joining_date) AS latest_joining
FROM employees;

-- 8. Find the highest-paid employee.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

-- 9. Find the lowest-paid employee.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);

-- 10. MIN() and MAX() with JOIN
-- Show salary ranges for each department.
SELECT
    d.department_name,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary,
    MAX(e.salary) - MIN(e.salary) AS salary_gap
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY salary_gap DESC;

-- 11. Practical example
-- Find the second-highest distinct salary.
SELECT
    MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);

-- Note:
-- MIN() and MAX() ignore NULL values.
-- Multiple employees can share the same
-- minimum or maximum salary.
