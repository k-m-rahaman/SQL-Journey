```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 07_distinct.sql
    Topic: DISTINCT

    Description:
    DISTINCT removes duplicate values from
    the result of a query.
*/

USE sql_journey;

-- Display all unique job titles.
SELECT DISTINCT job_title
FROM employees;

-- Display all departments represented in employees.
SELECT DISTINCT department_id
FROM employees;

-- Display unique combinations of department and job title.
SELECT DISTINCT
    department_id,
    job_title
FROM employees;
```
