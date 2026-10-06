```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 03_logical_operators.sql
    Topic: Logical Operators

    Description:
    Demonstrates AND, OR, and NOT.
*/

USE sql_journey;

-- AND:
-- Both conditions must be true.
SELECT *
FROM employees
WHERE salary > 60000
  AND department_id = 101;

-- OR:
-- At least one condition must be true.
SELECT *
FROM employees
WHERE department_id = 101
   OR department_id = 105;

-- NOT:
-- Reverses a condition.
SELECT *
FROM employees
WHERE NOT department_id = 101;

-- Combining multiple logical conditions.
SELECT
    employee_name,
    salary,
    department_id
FROM employees
WHERE salary >= 60000
  AND (department_id = 101 OR department_id = 105);
```
