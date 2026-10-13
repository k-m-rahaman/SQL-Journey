
/*
========================================================
    SQL JOURNEY
    Module 04: SQL Functions
    File: 03_date_functions.sql
    Topic: Date and Time Functions
========================================================

Description:
Date functions help retrieve, format,
compare, and calculate date values.

Functions Covered:
1. CURRENT_DATE()
2. NOW()
3. YEAR()
4. MONTH()
5. DAY()
6. DATEDIFF()
7. DATE_ADD()
8. DATE_SUB()
9. TIMESTAMPDIFF()
10. DATE_FORMAT()

========================================================
*/

USE sql_journey;

-- 1. CURRENT_DATE()
-- Display today's date.
SELECT
    CURRENT_DATE() AS today_date;

-- 2. NOW()
-- Display the current date and time.
SELECT
    NOW() AS current_datetime;

-- 3. YEAR()
-- Extract the joining year.
SELECT
    employee_name,
    joining_date,
    YEAR(joining_date) AS joining_year
FROM employees;

-- 4. MONTH()
-- Extract the joining month.
SELECT
    employee_name,
    MONTH(joining_date) AS joining_month
FROM employees;

-- 5. DAY()
-- Extract the day of joining.
SELECT
    employee_name,
    DAY(joining_date) AS joining_day
FROM employees;

-- 6. DATEDIFF()
-- Calculate days since an employee joined.
SELECT
    employee_name,
    joining_date,
    DATEDIFF(
        CURRENT_DATE(),
        joining_date
    ) AS days_employed
FROM employees;

-- 7. DATE_ADD()
-- Add six months to the joining date.
SELECT
    employee_name,
    joining_date,
    DATE_ADD(
        joining_date,
        INTERVAL 6 MONTH
    ) AS review_date
FROM employees;

-- 8. DATE_SUB()
-- Subtract thirty days from today's date.
SELECT
    DATE_SUB(
        CURRENT_DATE(),
        INTERVAL 30 DAY
    ) AS thirty_days_ago;

-- 9. TIMESTAMPDIFF()
-- Calculate completed years of service.
SELECT
    employee_name,
    joining_date,
    TIMESTAMPDIFF(
        YEAR,
        joining_date,
        CURRENT_DATE()
    ) AS years_of_service
FROM employees;

-- 10. DATE_FORMAT()
-- Convert dates into a readable format.
SELECT
    employee_name,
    DATE_FORMAT(
        joining_date,
        '%d %M %Y'
    ) AS formatted_joining_date
FROM employees;

-- 11. Practical example
-- Find employees who joined in 2024.
SELECT
    employee_name,
    job_title,
    joining_date
FROM employees
WHERE joining_date >= '2024-01-01'
  AND joining_date < '2025-01-01';

-- 12. Practical example
-- Find employees with at least three years of service.
SELECT
    employee_name,
    joining_date,
    TIMESTAMPDIFF(
        YEAR,
        joining_date,
        CURRENT_DATE()
    ) AS experience_years
FROM employees
WHERE joining_date <= DATE_SUB(
    CURRENT_DATE(),
    INTERVAL 3 YEAR
);

-- 13. Display employees by joining date.
SELECT
    employee_name,
    joining_date
FROM employees
ORDER BY joining_date ASC;
