```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 05_where.sql
    Topic: WHERE Clause

    Description:
    The WHERE clause filters records based on
    a specified condition.
*/

USE sql_journey;

-- Find employees earning more than 60000.
SELECT *
FROM employees
WHERE salary > 60000;

-- Find employees belonging to department 101.
SELECT *
FROM employees
WHERE department_id = 101;

-- Find employees with the job title 'Software Engineer'.
SELECT *
FROM employees
WHERE job_title = 'Software Engineer';

-- Find employees who joined after January 1, 2024.
SELECT *
FROM employees
WHERE joining_date > '2024-01-01';
```
