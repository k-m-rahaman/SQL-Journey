
/*
========================================================
    SQL JOURNEY
    Module 09: Advanced SQL
    File: 01_views.sql
    Topic: SQL Views
========================================================

Description:
A VIEW is a virtual table based on the
result of a stored SELECT statement.

Views simplify complex queries, improve
reusability, and can help control access
to selected database information.

Concepts Covered:
1. CREATE VIEW
2. SELECT from a VIEW
3. Views with JOIN
4. Views with aggregate functions
5. Filtering and sorting views
6. CREATE OR REPLACE VIEW
7. SHOW CREATE VIEW
8. DROP VIEW

========================================================
*/

USE sql_journey;

-- 1. Remove previous demonstration views.
DROP VIEW IF EXISTS vw_advanced_high_salary;
DROP VIEW IF EXISTS vw_advanced_department_summary;
DROP VIEW IF EXISTS vw_advanced_employee_directory;

-- 2. Create a basic employee directory view.
CREATE VIEW vw_advanced_employee_directory AS
SELECT
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.salary,
    e.joining_date,
    d.department_name,
    d.location
FROM employees AS e
LEFT JOIN departments AS d
    ON e.department_id = d.department_id;

-- 3. Retrieve all records from the view.
SELECT *
FROM vw_advanced_employee_directory
ORDER BY employee_id;

-- 4. Filter results from the view.
-- Find employees earning more than 60000.
SELECT
    employee_name,
    department_name,
    salary
FROM vw_advanced_employee_directory
WHERE salary > 60000
ORDER BY salary DESC;

-- 5. Create an aggregate view.
-- Summarize employee and salary statistics
-- for every department.
CREATE VIEW vw_advanced_department_summary AS
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salary,
    ROUND(AVG(e.salary), 2) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name;

-- 6. Retrieve department summaries.
SELECT *
FROM vw_advanced_department_summary
ORDER BY total_salary DESC;

-- 7. Filter departments by average salary.
SELECT
    department_name,
    average_salary
FROM vw_advanced_department_summary
WHERE average_salary > 60000
ORDER BY average_salary DESC;

-- 8. Create a view for high-earning employees.
CREATE VIEW vw_advanced_high_salary AS
SELECT
    employee_id,
    employee_name,
    job_title,
    salary
FROM employees
WHERE salary >= 75000;

-- 9. Retrieve high-earning employees.
SELECT *
FROM vw_advanced_high_salary
ORDER BY salary DESC;

-- 10. Modify an existing view.
-- Replace the high-salary view with
-- a threshold of 70000.
CREATE OR REPLACE VIEW vw_advanced_high_salary AS
SELECT
    employee_id,
    employee_name,
    job_title,
    salary,
    department_id
FROM employees
WHERE salary >= 70000;

-- 11. Verify the updated view.
SELECT *
FROM vw_advanced_high_salary
ORDER BY salary DESC;

-- 12. Display the definition of a view.
SHOW CREATE VIEW vw_advanced_employee_directory;

-- 13. List the demonstration views.
SELECT
    table_name,
    is_updatable
FROM information_schema.views
WHERE table_schema = 'sql_journey'
  AND table_name LIKE 'vw_advanced_%'
ORDER BY table_name;

-- 14. Demonstrate removing a temporary view.
CREATE VIEW vw_advanced_temporary AS
SELECT
    employee_id,
    employee_name
FROM employees;

DROP VIEW IF EXISTS vw_advanced_temporary;

-- Note:
-- Views store query definitions, not separate
-- copies of the underlying table data.
--
-- Aggregate views are generally not updatable.
-- View permissions should be managed carefully.
--
-- The three main demonstration views remain
-- available after this script finishes.
