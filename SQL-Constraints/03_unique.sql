
/*
========================================================
    SQL JOURNEY
    Module 03: SQL Constraints
    File: 03_unique.sql
    Topic: UNIQUE Constraint
========================================================

Description:
The UNIQUE constraint ensures that values in
specified columns are not duplicated.

Unlike PRIMARY KEY, MySQL allows multiple NULL
values in a nullable UNIQUE column.

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_unique;

-- 2. Create a table with UNIQUE constraints.
CREATE TABLE demo_unique (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

-- 3. Insert valid records.
INSERT INTO demo_unique
    (user_id, username, email, phone)
VALUES
    (1, 'arjun_01', 'arjun@example.com', '9876543210'),
    (2, 'priya_02', 'priya@example.com', '9876543211'),
    (3, 'rahul_03', 'rahul@example.com', '9876543212'),
    (4, 'sneha_04', 'sneha@example.com', '9876543213');

-- 4. Display all records.
SELECT *
FROM demo_unique;

-- 5. Search using a unique email address.
SELECT
    user_id,
    username,
    email
FROM demo_unique
WHERE email = 'priya@example.com';

-- 6. Insert records with NULL email values.
-- MySQL permits multiple NULL values in UNIQUE columns.
INSERT INTO demo_unique
    (user_id, username, email)
VALUES
    (5, 'amit_05', NULL),
    (6, 'neha_06', NULL);

-- 7. Display records with missing emails.
SELECT *
FROM demo_unique
WHERE email IS NULL;

-- 8. Invalid example: duplicate username.
-- INSERT INTO demo_unique
-- VALUES (7, 'arjun_01', 'new@example.com', NULL);

-- 9. Invalid example: duplicate email.
-- INSERT INTO demo_unique
-- VALUES (8, 'new_user', 'priya@example.com', NULL);

-- 10. Display table structure.
DESCRIBE demo_unique;
