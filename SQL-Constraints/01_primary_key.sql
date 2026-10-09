
/*
========================================================
    SQL JOURNEY
    Module 03: SQL Constraints
    File: 01_primary_key.sql
    Topic: PRIMARY KEY Constraint
========================================================

Description:
A PRIMARY KEY uniquely identifies every row in a table.

Rules:
1. Values must be unique.
2. NULL values are not allowed.
3. A table can have only one PRIMARY KEY.
4. A primary key can contain multiple columns.

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_primary_key;

-- 2. Create a table with a PRIMARY KEY.
CREATE TABLE demo_primary_key (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    age INT,
    course VARCHAR(100)
);

-- 3. Insert valid student records.
INSERT INTO demo_primary_key
    (student_id, student_name, age, course)
VALUES
    (101, 'Arjun Sharma', 20, 'Computer Science'),
    (102, 'Priya Das', 21, 'Artificial Intelligence'),
    (103, 'Rahul Sen', 19, 'Data Science'),
    (104, 'Sneha Roy', 22, 'Cyber Security');

-- 4. Display all students.
SELECT *
FROM demo_primary_key;

-- 5. Find a student using the PRIMARY KEY.
SELECT
    student_id,
    student_name,
    course
FROM demo_primary_key
WHERE student_id = 102;

-- 6. Invalid example: duplicate PRIMARY KEY.
-- This query would produce an error.
-- INSERT INTO demo_primary_key
-- VALUES (101, 'Amit Kumar', 20, 'Information Technology');

-- 7. Invalid example: NULL PRIMARY KEY.
-- This query would also produce an error.
-- INSERT INTO demo_primary_key
-- VALUES (NULL, 'Neha Gupta', 21, 'Computer Science');

-- 8. Display the table structure.
DESCRIBE demo_primary_key;
