```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 04_select.sql
    Topic: SELECT Statement

    Description:
    Demonstrates different ways to retrieve data
    from a table.
*/

USE sql_journey;

-- Select all columns.
SELECT *
FROM employees;

-- Select specific columns.
SELECT
    employee_id,
    employee_name,
    job_title
FROM employees;

-- Select employee names and salaries.
SELECT
    employee_name,
    salary
FROM employees;
```
