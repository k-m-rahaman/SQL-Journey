```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 08_limit.sql
    Topic: LIMIT

    Description:
    LIMIT restricts the number of rows returned
    by a query.
*/

USE sql_journey;

-- Display the first 5 employees.
SELECT *
FROM employees
LIMIT 5;

-- Display the 3 highest-paid employees.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- Display the 2 lowest-paid employees.
SELECT
    employee_name,
    job_title,
    salary
FROM employees
ORDER BY salary ASC
LIMIT 2;
```

