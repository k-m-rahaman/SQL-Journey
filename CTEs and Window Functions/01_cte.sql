
/*
========================================================
    SQL JOURNEY
    Module 10: CTEs and Window Functions
    File: 01_cte.sql
    Topic: Common Table Expressions (CTEs)
========================================================

Description:
A Common Table Expression is a named temporary
result set defined using the WITH keyword.

CTEs improve query readability and help organize
complex operations into smaller logical steps.

Concepts Covered:
1. Basic WITH clause
2. CTE with filtering
3. CTE with aggregate functions
4. CTE with JOIN
5. Multiple CTEs
6. CTE with subqueries
7. CTE for salary analysis
8. Reusing a CTE

========================================================
*/

USE sql_journey;

-- 1. Basic CTE
-- Retrieve employees earning more than 60000.
WITH high_salary_employees AS (
    SELECT
        employee_id,
        employee_name,
        salary
    FROM employees
    WHERE salary > 60000
)
SELECT *
FROM high_salary_employees
ORDER BY salary DESC;


-- 2. CTE with AVG()
-- Calculate the company average salary.
WITH salary_statistics AS (
    SELECT
        ROUND(AVG(salary), 2) AS average_salary
    FROM employees
)
SELECT *
FROM salary_statistics;


-- 3. CTE with JOIN
-- Create a reusable employee-department result.
WITH employee_details AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.salary,
        d.department_name
    FROM employees AS e
    INNER JOIN departments AS d
        ON e.department_id = d.department_id
)
SELECT *
FROM employee_details
ORDER BY employee_id;


-- 4. CTE with GROUP BY
-- Calculate department-wise total salaries.
WITH department_payroll AS (
    SELECT
        department_id,
        COUNT(*) AS employee_count,
        SUM(salary) AS total_salary,
        ROUND(AVG(salary), 2) AS average_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_payroll
ORDER BY total_salary DESC;


-- 5. Multiple CTEs
-- Compare employee salaries against
-- the overall company average.
WITH
company_average AS (
    SELECT AVG(salary) AS avg_salary
    FROM employees
),
employee_salaries AS (
    SELECT
        employee_name,
        salary
    FROM employees
)
SELECT
    e.employee_name,
    e.salary,
    ROUND(c.avg_salary, 2) AS company_average
FROM employee_salaries AS e
CROSS JOIN company_average AS c
WHERE e.salary > c.avg_salary
ORDER BY e.salary DESC;


-- 6. CTE with HAVING
-- Find departments with average salaries
-- greater than 60000.
WITH department_averages AS (
    SELECT
        department_id,
        ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_averages
WHERE avg_salary > 60000
ORDER BY avg_salary DESC;


-- 7. CTE with CASE
-- Classify employees into salary categories.
WITH salary_categories AS (
    SELECT
        employee_name,
        salary,
        CASE
            WHEN salary >= 80000 THEN 'High'
            WHEN salary >= 60000 THEN 'Medium'
            ELSE 'Standard'
        END AS salary_category
    FROM employees
)
SELECT
    employee_name,
    salary,
    salary_category
FROM salary_categories
ORDER BY salary DESC;


-- 8. Practical example
-- Find employees earning more than
-- their department's average salary.
WITH department_averages AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    e.employee_name,
    e.salary,
    e.department_id,
    ROUND(d.average_salary, 2)
        AS department_average
FROM employees AS e
INNER JOIN department_averages AS d
    ON e.department_id = d.department_id
WHERE e.salary > d.average_salary
ORDER BY e.department_id, e.salary DESC;


-- 9. CTE with multiple stages
-- Identify departments whose total payroll
-- exceeds the average departmental payroll.
WITH
department_totals AS (
    SELECT
        department_id,
        SUM(salary) AS total_salary
    FROM employees
    GROUP BY department_id
),
average_payroll AS (
    SELECT
        AVG(total_salary) AS average_total
    FROM department_totals
)
SELECT
    d.department_id,
    d.total_salary,
    ROUND(a.average_total, 2)
        AS average_department_payroll
FROM department_totals AS d
CROSS JOIN average_payroll AS a
WHERE d.total_salary > a.average_total
ORDER BY d.total_salary DESC;


-- 10. Reuse the same CTE multiple times.
-- Compare each department's payroll
-- with the payroll of department 101.
WITH department_totals AS (
    SELECT
        department_id,
        SUM(salary) AS total_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_id,
    d.total_salary
FROM department_totals AS d
WHERE d.total_salary > (
    SELECT total_salary
    FROM department_totals
    WHERE department_id = 101
)
ORDER BY d.total_salary DESC;


-- Important:
-- A CTE begins with the WITH keyword.
--
-- A CTE normally exists only during
-- the statement in which it is defined.
--
-- Multiple CTEs can be separated by commas.
--
-- CTEs can improve readability but are
-- not automatically faster than subqueries.
