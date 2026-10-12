
/*
========================================================
    SQL JOURNEY
    Module 04: SQL Functions
    File: 02_numeric_functions.sql
    Topic: Numeric Functions
========================================================

Description:
Numeric functions perform mathematical
calculations on numeric database values.

Functions Covered:
1. ROUND()
2. CEIL()
3. FLOOR()
4. ABS()
5. MOD()
6. POWER()
7. SQRT()

========================================================
*/

USE sql_journey;

-- 1. ROUND()
-- Round a number to two decimal places.
SELECT
    ROUND(125.6789, 2) AS rounded_number;

-- Calculate and round a 12.5% salary bonus.
SELECT
    employee_name,
    salary,
    ROUND(salary * 0.125, 2) AS bonus
FROM employees;

-- 2. CEIL()
-- Round a number upward to the next integer.
SELECT
    CEIL(45.21) AS ceiling_value;

-- 3. FLOOR()
-- Round a number downward to an integer.
SELECT
    FLOOR(45.89) AS floor_value;

-- 4. ABS()
-- Return the absolute value of a number.
SELECT
    ABS(-7500) AS absolute_value;

-- 5. MOD()
-- Return the remainder after division.
SELECT
    MOD(25, 4) AS remainder;

-- Find employees with even employee IDs.
SELECT
    employee_id,
    employee_name
FROM employees
WHERE MOD(employee_id, 2) = 0;

-- 6. POWER()
-- Raise a number to a specified exponent.
SELECT
    POWER(2, 5) AS power_result;

-- 7. SQRT()
-- Calculate the square root.
SELECT
    SQRT(144) AS square_root;

-- 8. Practical example
-- Calculate a 10% salary increase.
SELECT
    employee_name,
    salary AS current_salary,
    ROUND(salary * 0.10, 2) AS increment_amount,
    ROUND(salary * 1.10, 2) AS revised_salary
FROM employees;

-- 9. Practical example
-- Calculate a 5% deduction and final salary.
SELECT
    employee_name,
    salary,
    ROUND(salary * 0.05, 2) AS deduction,
    ROUND(salary * 0.95, 2) AS final_salary
FROM employees;

-- 10. Find the three highest-paid employees.
SELECT
    employee_name,
    ROUND(salary, 2) AS salary
FROM employees
ORDER BY salary DESC
LIMIT 3;
