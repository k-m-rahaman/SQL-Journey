```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 07_is_null.sql
    Topic: NULL Values

    Description:
    Demonstrates how to check for NULL values.

    Important:
    NULL represents a missing or unknown value.
    NULL cannot be compared using = or !=.
*/

USE sql_journey;

-- Find records where location is NULL.
SELECT *
FROM departments
WHERE location IS NULL;

-- Find records where location is NOT NULL.
SELECT *
FROM departments
WHERE location IS NOT NULL;

-- Employees with a NULL job title.
SELECT
    employee_name,
    job_title
FROM employees
WHERE job_title IS NULL;

-- Employees with a known job title.
SELECT
    employee_name,
    job_title
FROM employees
WHERE job_title IS NOT NULL;
```
