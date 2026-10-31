
/*
========================================================
    SQL JOURNEY
    Module 10: CTEs and Window Functions
    File: 06_partition_by.sql
    Topic: PARTITION BY and Window Analytics
========================================================

Description:
PARTITION BY divides result rows into groups
for independent window calculations.

Unlike GROUP BY, window functions preserve
individual rows in the result set.

Concepts Covered:
1. PARTITION BY with COUNT()
2. PARTITION BY with SUM()
3. PARTITION BY with AVG()
4. MIN() and MAX() window calculations
5. Salary contribution percentages
6. Running totals
7. Moving averages
8. FIRST_VALUE()
9. LAST_VALUE()
10. Named windows
11. Department analytics

========================================================
*/

USE sql_journey;

-- 1. PARTITION BY with COUNT()
-- Display the number of employees in
-- each employee's department.
SELECT
    employee_name,
    department_id,
    COUNT(*) OVER (
        PARTITION BY department_id
    ) AS department_employee_count
FROM employees
ORDER BY department_id, employee_id;


-- 2. PARTITION BY with SUM()
-- Display the total department salary
-- beside each employee's salary.
SELECT
    employee_name,
    department_id,
    salary,
    SUM(salary) OVER (
        PARTITION BY department_id
    ) AS department_total_salary
FROM employees
ORDER BY department_id, employee_id;


-- 3. PARTITION BY with AVG()
-- Compare employees with their department average.
SELECT
    employee_name,
    department_id,
    salary,
    ROUND(
        AVG(salary) OVER (
            PARTITION BY department_id
        ),
        2
    ) AS department_average
FROM employees
ORDER BY department_id, salary DESC;


-- 4. PARTITION BY with MIN() and MAX()
-- Display department salary ranges.
SELECT
    employee_name,
    department_id,
    salary,
    MIN(salary) OVER (
        PARTITION BY department_id
    ) AS department_minimum,
    MAX(salary) OVER (
        PARTITION BY department_id
    ) AS department_maximum
FROM employees
ORDER BY department_id, salary DESC;


-- 5. Calculate salary contribution percentages.
-- Measure each employee's share of their
-- department's total payroll.
SELECT
    employee_name,
    department_id,
    salary,
    ROUND(
        100.0 * salary /
        NULLIF(
            SUM(salary) OVER (
                PARTITION BY department_id
            ),
            0
        ),
        2
    ) AS payroll_percentage
FROM employees
ORDER BY department_id, salary DESC;


-- 6. Running total by department.
-- Accumulate salaries from highest to lowest.
SELECT
    employee_name,
    department_id,
    salary,
    SUM(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC, employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_salary_total
FROM employees
ORDER BY department_id, salary DESC, employee_id;


-- 7. Moving average.
-- Calculate the average salary of the
-- current employee and previous employee
-- in joining-date order.
SELECT
    employee_name,
    department_id,
    joining_date,
    salary,
    ROUND(
        AVG(salary) OVER (
            PARTITION BY department_id
            ORDER BY joining_date, employee_id
            ROWS BETWEEN 1 PRECEDING
                     AND CURRENT ROW
        ),
        2
    ) AS moving_average_salary
FROM employees
ORDER BY department_id, joining_date, employee_id;


-- 8. FIRST_VALUE()
-- Display the highest-paid employee
-- within each department.
SELECT
    employee_name,
    department_id,
    salary,
    FIRST_VALUE(employee_name) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC, employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS highest_paid_employee
FROM employees
ORDER BY department_id, salary DESC;


-- 9. LAST_VALUE()
-- Display the lowest-paid employee
-- within each department.
SELECT
    employee_name,
    department_id,
    salary,
    LAST_VALUE(employee_name) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC, employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS lowest_paid_employee
FROM employees
ORDER BY department_id, salary DESC;


-- 10. Named windows
-- Reuse a window definition for
-- multiple analytical calculations.
SELECT
    employee_name,
    department_id,
    salary,
    COUNT(*) OVER dept_window
        AS department_count,
    SUM(salary) OVER dept_window
        AS department_payroll,
    ROUND(
        AVG(salary) OVER dept_window,
        2
    ) AS department_average
FROM employees
WINDOW dept_window AS (
    PARTITION BY department_id
)
ORDER BY department_id, salary DESC;


-- 11. Practical example
-- Complete employee and department analysis.
SELECT
    e.employee_name,
    d.department_name,
    e.salary,

    COUNT(*) OVER (
        PARTITION BY e.department_id
    ) AS department_employee_count,

    SUM(e.salary) OVER (
        PARTITION BY e.department_id
    ) AS department_payroll,

    ROUND(
        AVG(e.salary) OVER (
            PARTITION BY e.department_id
        ),
        2
    ) AS department_average,

    RANK() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS salary_rank

FROM employees AS e
INNER JOIN departments AS d
    ON e.department_id = d.department_id
ORDER BY d.department_id, salary_rank, e.employee_id;


-- 12. Compare each employee's salary
-- with their department's average.
WITH department_analysis AS (
    SELECT
        employee_name,
        department_id,
        salary,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS department_average
    FROM employees
)
SELECT
    employee_name,
    department_id,
    salary,
    ROUND(department_average, 2)
        AS department_average,
    ROUND(salary - department_average, 2)
        AS difference_from_average,
    CASE
        WHEN salary > department_average
            THEN 'Above Average'
        WHEN salary < department_average
            THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS salary_status
FROM department_analysis
ORDER BY department_id, salary DESC;


-- Important:
-- PARTITION BY divides rows into groups.
--
-- ORDER BY inside OVER() defines window
-- ordering when the function needs it.
--
-- ROWS defines a physical row-based frame.
--
-- Window functions preserve individual rows.
--
-- GROUP BY usually reduces results to
-- one row per group.
--
-- LAST_VALUE() may require an explicit
-- full-partition frame to return the
-- true final row of a partition.
