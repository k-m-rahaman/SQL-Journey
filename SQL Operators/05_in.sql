```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 05_in.sql
    Topic: IN Operator

    Description:
    IN checks whether a value matches any value
    in a specified list.
*/

USE sql_journey;

-- Employees from departments 101, 103, or 105.
SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id IN (101, 103, 105);

-- Employees with selected job titles.
SELECT
    employee_name,
    job_title
FROM employees
WHERE job_title IN (
    'Software Engineer',
    'Data Analyst',
    'ML Engineer'
);

-- NOT IN:
-- Employees who do not belong to departments 101 or 105.
SELECT
    employee_name,
    department_id
FROM employees
WHERE department_id NOT IN (101, 105);
```
