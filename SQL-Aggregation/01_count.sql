
/*
========================================================
    SQL JOURNEY
    Module 05: SQL Aggregation
    File: 01_count.sql
    Topic: COUNT() Function
========================================================

Description:
COUNT() is an aggregate function used to count
rows or non-NULL values in a database.

Concepts Covered:
1. COUNT(*)
2. COUNT(column)
3. COUNT(DISTINCT column)
4. COUNT() with WHERE
5. COUNT() with GROUP BY
6. COUNT() with JOIN

========================================================
*/

USE sql_journey;

-- 1. COUNT(*)
-- Count all employees in the database.
SELECT
    COUNT(*) AS total_employees
FROM employees;

-- 2. COUNT(column)
-- Count employees with a non-NULL job title.
SELECT
    COUNT(job_title) AS employees_with_jobs
FROM employees;

-- 3. COUNT(DISTINCT)
-- Count the number of unique departments
-- represented in the employees table.
SELECT
    COUNT(DISTINCT department_id) AS total_departments
FROM employees;

-- 4. COUNT() with WHERE
-- Count employees earning more than 60000.
SELECT
    COUNT(*) AS high_salary_employees
FROM employees
WHERE salary > 60000;

-- 5. Count employees who joined in 2024.
SELECT
    COUNT(*) AS employees_joined_2024
FROM employees
WHERE joining_date >= '2024-01-01'
  AND joining_date < '2025-01-01';

-- 6. COUNT() with GROUP BY
-- Count employees in each department.
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 7. COUNT() with JOIN
-- Display department names with employee counts.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_employees DESC;

-- 8. Practical example
-- Count employees with the word 'Manager'
-- appearing in their job title.
SELECT
    COUNT(*) AS total_managers
FROM employees
WHERE job_title LIKE '%Manager%';

-- 9. Count employees with missing salary values.
SELECT
    COUNT(*) AS missing_salary_records
FROM employees
WHERE salary IS NULL;

-- Note:
-- COUNT(*) counts rows.
-- COUNT(column) ignores NULL values.
-- COUNT(DISTINCT column) counts unique non-NULL values.
