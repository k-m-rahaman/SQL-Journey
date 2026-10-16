
/*
========================================================
    SQL JOURNEY
    Module 05: SQL Aggregation
    File: 02_sum.sql
    Topic: SUM() Function
========================================================

Description:
SUM() calculates the total of numeric values
in a column.

It ignores NULL values and is commonly used
for financial and statistical analysis.

Concepts Covered:
1. Basic SUM()
2. SUM() with WHERE
3. SUM() with GROUP BY
4. SUM() with expressions
5. Conditional SUM()
6. SUM() with JOIN

========================================================
*/

USE sql_journey;

-- 1. Basic SUM()
-- Calculate the total salary of all employees.
SELECT
    SUM(salary) AS total_salary
FROM employees;

-- 2. SUM() with WHERE
-- Calculate total salary for department 101.
SELECT
    SUM(salary) AS department_salary
FROM employees
WHERE department_id = 101;

-- 3. SUM() with GROUP BY
-- Calculate total salary for each department.
SELECT
    department_id,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 4. SUM() with arithmetic expressions
-- Calculate the total salary after a 10% increase.
SELECT
    SUM(salary) AS current_total,
    SUM(salary * 1.10) AS increased_total
FROM employees;

-- 5. Calculate total annual salary.
-- The sample salary values are treated
-- as monthly salaries for this example.
SELECT
    SUM(salary * 12) AS total_annual_payroll
FROM employees;

-- 6. Conditional SUM()
-- Calculate total salary for employees
-- earning more than 60000.
SELECT
    SUM(
        CASE
            WHEN salary > 60000 THEN salary
            ELSE 0
        END
    ) AS high_salary_total
FROM employees;

-- 7. SUM() with JOIN
-- Calculate total salary by department name.
SELECT
    d.department_name,
    COALESCE(SUM(e.salary), 0) AS total_salary
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_salary DESC;

-- 8. Practical example
-- Calculate the salary expense and 5% bonus
-- budget for each department.
SELECT
    department_id,
    SUM(salary) AS salary_expense,
    ROUND(SUM(salary * 0.05), 2) AS bonus_budget,
    ROUND(SUM(salary * 1.05), 2) AS total_budget
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- Note:
-- SUM() ignores NULL values.
-- If no non-NULL numeric values exist,
-- SUM() returns NULL.
