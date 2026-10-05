```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 01_arithmetic_operators.sql
    Topic: Arithmetic Operators

    Description:
    Demonstrates arithmetic operations in SQL.
*/

USE sql_journey;

-- Addition
SELECT
    employee_name,
    salary,
    salary + 5000 AS increased_salary
FROM employees;

-- Subtraction
SELECT
    employee_name,
    salary,
    salary - 5000 AS reduced_salary
FROM employees;

-- Multiplication
SELECT
    employee_name,
    salary,
    salary * 12 AS annual_salary
FROM employees;

-- Division
SELECT
    employee_name,
    salary,
    salary / 12 AS monthly_salary
FROM employees;

-- Calculate a 10% salary bonus.
SELECT
    employee_name,
    salary,
    salary * 0.10 AS bonus
FROM employees;

-- Calculate salary including the 10% bonus.
SELECT
    employee_name,
    salary,
    salary + (salary * 0.10) AS salary_with_bonus
FROM employees;
```
