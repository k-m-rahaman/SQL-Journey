
/*
========================================================
    SQL JOURNEY
    Module 03: SQL Constraints
    File: 05_check.sql
    Topic: CHECK Constraint
========================================================

Description:
The CHECK constraint validates data against
specified conditions.

Examples:
1. Age must be at least 18.
2. Salary cannot be negative.
3. Marks must fall between 0 and 100.

Requires MySQL 8.0.16 or later for enforced CHECK.

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_check;

-- 2. Create a table with multiple CHECK constraints.
CREATE TABLE demo_check (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    performance_score INT NOT NULL,

    CONSTRAINT chk_employee_age
        CHECK (age >= 18),

    CONSTRAINT chk_employee_salary
        CHECK (salary >= 0),

    CONSTRAINT chk_performance_score
        CHECK (performance_score BETWEEN 0 AND 100)
);

-- 3. Insert valid records.
INSERT INTO demo_check
    (employee_id, employee_name, age, salary, performance_score)
VALUES
    (1, 'Arjun Sharma', 25, 65000, 90),
    (2, 'Priya Das', 23, 58000, 85),
    (3, 'Rahul Sen', 28, 45000, 78),
    (4, 'Sneha Roy', 30, 72000, 95);

-- 4. Display all employees.
SELECT *
FROM demo_check;

-- 5. Find employees with scores above 85.
SELECT
    employee_name,
    performance_score
FROM demo_check
WHERE performance_score > 85;

-- 6. Find employees aged between 20 and 30.
SELECT
    employee_name,
    age
FROM demo_check
WHERE age BETWEEN 20 AND 30;

-- 7. Invalid example: age below 18.
-- INSERT INTO demo_check
-- VALUES (5, 'Test Student', 16, 25000, 75);

-- 8. Invalid example: negative salary.
-- INSERT INTO demo_check
-- VALUES (6, 'Test Employee', 24, -5000, 80);

-- 9. Invalid example: score above 100.
-- INSERT INTO demo_check
-- VALUES (7, 'Test User', 25, 50000, 120);

-- 10. Display the table definition.
SHOW CREATE TABLE demo_check;
