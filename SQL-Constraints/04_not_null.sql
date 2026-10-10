
/*
========================================================
    SQL JOURNEY
    Module 03: SQL Constraints
    File: 04_not_null.sql
    Topic: NOT NULL Constraint
========================================================

Description:
The NOT NULL constraint prevents NULL values
from being stored in a column.

It is commonly used for mandatory information
such as names, email addresses, and salaries.

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_not_null;

-- 2. Create a table with mandatory fields.
CREATE TABLE demo_not_null (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    phone VARCHAR(15)
);

-- 3. Insert complete records.
INSERT INTO demo_not_null
    (employee_id, employee_name, email, salary, phone)
VALUES
    (1, 'Arjun Sharma', 'arjun@example.com', 65000, '9876543210'),
    (2, 'Priya Das', 'priya@example.com', 58000, NULL),
    (3, 'Rahul Sen', 'rahul@example.com', 45000, '9876543212'),
    (4, 'Sneha Roy', 'sneha@example.com', 72000, NULL);

-- 4. Display all records.
SELECT *
FROM demo_not_null;

-- 5. Find employees with available phone numbers.
SELECT
    employee_name,
    phone
FROM demo_not_null
WHERE phone IS NOT NULL;

-- 6. Find employees without phone numbers.
SELECT
    employee_name,
    email
FROM demo_not_null
WHERE phone IS NULL;

-- 7. Invalid example: employee_name cannot be NULL.
-- INSERT INTO demo_not_null
-- VALUES (5, NULL, 'unknown@example.com', 40000, NULL);

-- 8. Invalid example: salary cannot be NULL.
-- INSERT INTO demo_not_null
-- VALUES (6, 'Neha Gupta', 'neha@example.com', NULL, NULL);

-- 9. Display table structure.
DESCRIBE demo_not_null;
