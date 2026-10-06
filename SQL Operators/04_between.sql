```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 04_between.sql
    Topic: BETWEEN

    Description:
    BETWEEN checks whether a value falls within
    an inclusive range.
*/

USE sql_journey;

-- Employees with salaries between 50000 and 70000.
SELECT
    employee_name,
    salary
FROM employees
WHERE salary BETWEEN 50000 AND 70000;

-- Employees who joined between two dates.
SELECT
    employee_name,
    joining_date
FROM employees
WHERE joining_date BETWEEN '2023-01-01' AND '2024-12-31';

-- BETWEEN includes both boundary values.
SELECT *
FROM employees
WHERE salary BETWEEN 50000 AND 50000;
```
