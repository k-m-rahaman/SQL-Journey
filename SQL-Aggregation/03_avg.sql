
/*
========================================================
    SQL JOURNEY
    Module 05: SQL Aggregation
    File: 03_avg.sql
    Topic: AVG() Function
========================================================

Description:
AVG() calculates the arithmetic mean of
non-NULL numeric values.

Concepts Covered:
1. Basic AVG()
2. AVG() with ROUND()
3. AVG() with WHERE
4. AVG() with GROUP BY
5. AVG() in a subquery
6. Department-wise average analysis

========================================================
*/

USE sql_journey;

-- 1. Basic AVG()
-- Calculate the average employee salary.
SELECT
    AVG(salary) AS average_salary
FROM employees;

-- 2. AVG() with ROUND()
-- Display average salary with two decimal places.
SELECT
    ROUND(AVG(salary), 2) AS average_salary
FROM employees;

-- 3. AVG() with WHERE
-- Calculate average salary for department 101.
SELECT
    ROUND(AVG(salary), 2) AS department_average
FROM employees
WHERE department_id = 101;

-- 4. AVG() with GROUP BY
-- Calculate average salary in every department.
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 5. AVG() with filtering
-- Find average salary for employees who joined
-- on or after January 1, 2023.
SELECT
    ROUND(AVG(salary), 2) AS recent_employee_average
FROM employees
WHERE joining_date >= '2023-01-01';

-- 6. AVG() in a subquery
-- Find employees earning above the company average.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary DESC;

-- 7. Practical example
-- Display employees earning below the average.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary ASC;

-- 8. Compare department averages.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY average_salary DESC;

-- 9. Calculate average annual salary.
SELECT
    ROUND(AVG(salary * 12), 2) AS average_annual_salary
FROM employees;

-- Note:
-- AVG() ignores NULL values.
-- AVG(column) is not always equal to
-- SUM(column) / COUNT(*), because COUNT(*)
-- includes rows containing NULL.
