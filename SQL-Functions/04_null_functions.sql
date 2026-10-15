
/*
========================================================
    SQL JOURNEY
    Module 04: SQL Functions
    File: 04_null_functions.sql
    Topic: NULL Handling Functions
========================================================

Description:
NULL represents a missing or unknown value.

These functions help handle missing data
and produce meaningful query results.

Concepts Covered:
1. IS NULL
2. IS NOT NULL
3. IFNULL()
4. COALESCE()
5. NULLIF()

========================================================
*/

USE sql_journey;

-- 1. IS NULL
-- Find employees without an assigned job title.
SELECT
    employee_name,
    job_title
FROM employees
WHERE job_title IS NULL;

-- 2. IS NOT NULL
-- Find employees with an assigned job title.
SELECT
    employee_name,
    job_title
FROM employees
WHERE job_title IS NOT NULL;

-- 3. IFNULL()
-- Replace NULL with a default value.
SELECT
    employee_name,
    IFNULL(
        job_title,
        'Not Assigned'
    ) AS employee_role
FROM employees;

-- 4. IFNULL() with a simple example.
SELECT
    IFNULL(
        NULL,
        'No Value Available'
    ) AS result;

-- 5. COALESCE()
-- Return the first non-NULL value.
SELECT
    COALESCE(
        NULL,
        NULL,
        'SQL Journey',
        'Database'
    ) AS first_available_value;

-- 6. COALESCE() with employee data.
SELECT
    employee_name,
    COALESCE(
        job_title,
        'Unknown Role'
    ) AS display_role
FROM employees;

-- 7. NULLIF()
-- Return NULL if two expressions are equal.
SELECT
    NULLIF(100, 100) AS result;

-- 8. NULLIF() with different values.
SELECT
    NULLIF(100, 200) AS result;

-- 9. Prevent division by zero.
-- NULLIF converts a zero denominator to NULL.
SELECT
    100 / NULLIF(0, 0) AS safe_division;

-- 10. Practical example
-- Display a fallback location when the value
-- is missing or equals Kolkata.
SELECT
    department_name,
    location,
    COALESCE(
        NULLIF(location, 'Kolkata'),
        'Default Location'
    ) AS display_location
FROM departments;

-- 11. Practical example
-- Replace NULL values in an employee report.
SELECT
    employee_id,
    employee_name,
    COALESCE(
        job_title,
        'Not Assigned'
    ) AS job_title,
    COALESCE(
        salary,
        0
    ) AS displayed_salary
FROM employees;

-- 12. Difference between NULL and zero.
SELECT
    IFNULL(NULL, 0) AS null_as_zero,
    NULLIF(0, 0) AS zero_as_null;
