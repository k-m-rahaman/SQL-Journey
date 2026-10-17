
/*
========================================================
    SQL JOURNEY
    Module 05: SQL Aggregation
    File: 05_group_by_having.sql
    Topic: GROUP BY and HAVING
========================================================

Description:
GROUP BY groups rows with matching values.

HAVING filters groups based on aggregate
conditions such as COUNT(), SUM(), and AVG().

Concepts Covered:
1. Basic GROUP BY
2. GROUP BY with COUNT()
3. GROUP BY with SUM()
4. GROUP BY with AVG()
5. HAVING with COUNT()
6. HAVING with AVG()
7. WHERE vs HAVING
8. Multiple-column grouping
9. Department salary analysis

========================================================
*/

USE sql_journey;

-- 1. Basic GROUP BY
-- Count employees in each department.
SELECT
    department_id,
    COUNT(*) AS total_employees
FROM employees
GROUP BY department_id;

-- 2. GROUP BY with SUM()
-- Calculate department-wise salary expenses.
SELECT
    department_id,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department_id
ORDER BY total_salary DESC;

-- 3. GROUP BY with AVG()
-- Calculate department-wise average salaries.
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id;

-- 4. HAVING with COUNT()
-- Find departments containing more than one employee.
SELECT
    department_id,
    COUNT(*) AS total_employees
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 1;

-- 5. HAVING with AVG()
-- Find departments where average salary
-- is greater than 60000.
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 60000;

-- 6. HAVING with SUM()
-- Find departments whose total salary
-- exceeds 120000.
SELECT
    department_id,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department_id
HAVING SUM(salary) > 120000;

-- 7. WHERE vs HAVING
-- WHERE filters individual employees first.
-- HAVING filters the resulting groups.
SELECT
    department_id,
    COUNT(*) AS high_salary_employees,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
WHERE salary > 50000
GROUP BY department_id
HAVING COUNT(*) >= 2;

-- 8. GROUP BY with JOIN
-- Show employee counts using department names.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY employee_count DESC;

-- 9. GROUP BY multiple columns
-- Count employees by department and job title.
SELECT
    department_id,
    job_title,
    COUNT(*) AS employee_count
FROM employees
GROUP BY
    department_id,
    job_title
ORDER BY department_id, job_title;

-- 10. Practical example
-- Complete department salary report.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    COALESCE(SUM(e.salary), 0) AS total_salary,
    ROUND(AVG(e.salary), 2) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_salary DESC;

-- 11. Practical example
-- Find departments with an average salary
-- higher than the overall company average.
SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS department_average
FROM departments AS d
INNER JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
HAVING AVG(e.salary) > (
    SELECT AVG(salary)
    FROM employees
);

-- 12. Practical example
-- Find departments with at least two employees
-- and total salary expenses above 100000.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    SUM(e.salary) AS total_salary
FROM departments AS d
INNER JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
HAVING COUNT(e.employee_id) >= 2
   AND SUM(e.salary) > 100000
ORDER BY total_salary DESC;

-- SQL Logical Processing Order:
-- 1. FROM / JOIN
-- 2. WHERE
-- 3. GROUP BY
-- 4. HAVING
-- 5. SELECT
-- 6. ORDER BY
-- 7. LIMIT

-- Remember:
-- WHERE filters rows before grouping.
-- HAVING filters groups after aggregation.
