
/*
========================================================
    SQL JOURNEY
    Module 10: CTEs and Window Functions
    File: 05_lag_lead.sql
    Topic: LAG() and LEAD()
========================================================

Description:
LAG() accesses values from preceding rows.
LEAD() accesses values from following rows.

These functions are useful for analyzing
sequential data without self-joins.

Concepts Covered:
1. Basic LAG()
2. Basic LEAD()
3. LAG() and LEAD() together
4. PARTITION BY with LAG()
5. Comparing salary values
6. Calculating date differences
7. Custom row offsets
8. Default values
9. Practical employee analysis

========================================================
*/

USE sql_journey;

-- 1. Basic LAG()
-- Display the salary of the employee
-- appearing immediately before each employee
-- when ordered by joining date.
SELECT
    employee_name,
    joining_date,
    salary,
    LAG(salary) OVER (
        ORDER BY joining_date, employee_id
    ) AS previous_salary
FROM employees
ORDER BY joining_date, employee_id;


-- 2. Basic LEAD()
-- Display the salary of the next employee
-- when ordered by joining date.
SELECT
    employee_name,
    joining_date,
    salary,
    LEAD(salary) OVER (
        ORDER BY joining_date, employee_id
    ) AS next_salary
FROM employees
ORDER BY joining_date, employee_id;


-- 3. LAG() and LEAD() together.
SELECT
    employee_name,
    salary,
    LAG(salary) OVER (
        ORDER BY salary DESC, employee_id
    ) AS preceding_salary,
    LEAD(salary) OVER (
        ORDER BY salary DESC, employee_id
    ) AS following_salary
FROM employees
ORDER BY salary DESC, employee_id;


-- 4. LAG() with PARTITION BY
-- Compare salaries within each department,
-- ordered by employee joining date.
SELECT
    employee_name,
    department_id,
    joining_date,
    salary,
    LAG(salary) OVER (
        PARTITION BY department_id
        ORDER BY joining_date, employee_id
    ) AS previous_employee_salary
FROM employees
ORDER BY department_id, joining_date, employee_id;


-- 5. Calculate salary differences.
-- Compare each employee's salary with the
-- preceding employee in the same department.
WITH salary_comparison AS (
    SELECT
        employee_name,
        department_id,
        salary,
        LAG(salary) OVER (
            PARTITION BY department_id
            ORDER BY joining_date, employee_id
        ) AS previous_salary
    FROM employees
)
SELECT
    employee_name,
    department_id,
    salary,
    previous_salary,
    salary - previous_salary AS salary_difference
FROM salary_comparison
ORDER BY department_id, employee_name;


-- 6. Calculate days between joining dates.
WITH joining_history AS (
    SELECT
        employee_name,
        joining_date,
        LAG(joining_date) OVER (
            ORDER BY joining_date, employee_id
        ) AS previous_joining_date
    FROM employees
)
SELECT
    employee_name,
    joining_date,
    previous_joining_date,
    DATEDIFF(
        joining_date,
        previous_joining_date
    ) AS days_between_joinings
FROM joining_history
ORDER BY joining_date;


-- 7. LEAD() for joining-date comparisons.
-- Find the next employee joining date
-- within the same department.
SELECT
    employee_name,
    department_id,
    joining_date,
    LEAD(joining_date) OVER (
        PARTITION BY department_id
        ORDER BY joining_date, employee_id
    ) AS next_joining_date
FROM employees
ORDER BY department_id, joining_date;


-- 8. LAG() with a custom offset.
-- Retrieve the salary two rows earlier.
SELECT
    employee_name,
    salary,
    LAG(salary, 2) OVER (
        ORDER BY salary DESC, employee_id
    ) AS salary_two_rows_before
FROM employees
ORDER BY salary DESC, employee_id;


-- 9. LEAD() with a custom offset.
-- Retrieve the salary two rows later.
SELECT
    employee_name,
    salary,
    LEAD(salary, 2) OVER (
        ORDER BY salary DESC, employee_id
    ) AS salary_two_rows_after
FROM employees
ORDER BY salary DESC, employee_id;


-- 10. LAG() and LEAD() with default values.
-- Return zero when no preceding or
-- following row exists.
SELECT
    employee_name,
    salary,
    LAG(salary, 1, 0) OVER (
        ORDER BY salary DESC, employee_id
    ) AS previous_salary,
    LEAD(salary, 1, 0) OVER (
        ORDER BY salary DESC, employee_id
    ) AS next_salary
FROM employees
ORDER BY salary DESC, employee_id;


-- 11. Practical example
-- Compare each employee's salary to the
-- next lower salary in the company.
WITH salary_sequence AS (
    SELECT
        employee_name,
        salary,
        LEAD(salary) OVER (
            ORDER BY salary DESC, employee_id
        ) AS next_lower_salary
    FROM employees
)
SELECT
    employee_name,
    salary,
    next_lower_salary,
    salary - next_lower_salary AS salary_gap
FROM salary_sequence
ORDER BY salary DESC;


-- 12. Practical example
-- Identify whether a salary is higher
-- or lower than the preceding employee's
-- salary within the same department.
WITH employee_comparison AS (
    SELECT
        employee_name,
        department_id,
        salary,
        LAG(salary) OVER (
            PARTITION BY department_id
            ORDER BY joining_date, employee_id
        ) AS previous_salary
    FROM employees
)
SELECT
    employee_name,
    department_id,
    salary,
    previous_salary,
    CASE
        WHEN previous_salary IS NULL
            THEN 'First Employee'
        WHEN salary > previous_salary
            THEN 'Higher'
        WHEN salary < previous_salary
            THEN 'Lower'
        ELSE 'Equal'
    END AS salary_comparison
FROM employee_comparison
ORDER BY department_id, employee_name;


-- Important:
-- LAG() looks backward in the window order.
-- LEAD() looks forward in the window order.
--
-- The default offset is 1.
--
-- When no matching preceding or following
-- row exists, the result is NULL unless
-- a default value is specified.
--
-- Comparing different employees' salaries
-- does NOT measure an individual's
-- historical salary growth.
