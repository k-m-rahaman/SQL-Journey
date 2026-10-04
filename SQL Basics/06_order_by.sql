```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 06_order_by.sql
    Topic: ORDER BY

    Description:
    Demonstrates sorting query results in
    ascending and descending order.
*/

USE sql_journey;

-- Sort employees by salary in ascending order.
SELECT
    employee_name,
    salary
FROM employees
ORDER BY salary ASC;

-- Sort employees by salary in descending order.
SELECT
    employee_name,
    salary
FROM employees
ORDER BY salary DESC;

-- Sort employees alphabetically by name.
SELECT
    employee_name,
    job_title
FROM employees
ORDER BY employee_name ASC;

-- Sort by department and then salary.
SELECT
    employee_name,
    department_id,
    salary
FROM employees
ORDER BY department_id ASC, salary DESC;
```
