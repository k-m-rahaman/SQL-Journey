```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 02_comparison_operators.sql
    Topic: Comparison Operators

    Description:
    Demonstrates operators used to compare values.
*/

USE sql_journey;

-- Equal to (=)
SELECT *
FROM employees
WHERE department_id = 101;

-- Not equal to (!=)
SELECT *
FROM employees
WHERE department_id != 101;

-- Greater than (>)
SELECT *
FROM employees
WHERE salary > 60000;

-- Less than (<)
SELECT *
FROM employees
WHERE salary < 60000;

-- Greater than or equal to (>=)
SELECT *
FROM employees
WHERE salary >= 75000;

-- Less than or equal to (<=)
SELECT *
FROM employees
WHERE salary <= 50000;
```
