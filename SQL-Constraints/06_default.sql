
/*
========================================================
    SQL JOURNEY
    Module 03: SQL Constraints
    File: 06_default.sql
    Topic: DEFAULT Constraint
========================================================

Description:
The DEFAULT constraint provides an automatic
value when a column is omitted during INSERT.

Common uses:
1. Default account status.
2. Default salary or quantity.
3. Automatic creation timestamp.
4. Default country or location.

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_default;

-- 2. Create a table containing DEFAULT values.
CREATE TABLE demo_default (
    user_id INT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    country VARCHAR(50) DEFAULT 'India',
    login_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Insert records without supplying default columns.
INSERT INTO demo_default
    (user_id, username)
VALUES
    (1, 'Arjun Sharma'),
    (2, 'Priya Das'),
    (3, 'Rahul Sen');

-- 4. Insert a user with customized values.
INSERT INTO demo_default
    (user_id, username, status, country, login_count)
VALUES
    (4, 'Sneha Roy', 'Inactive', 'India', 5);

-- 5. Display all records.
SELECT *
FROM demo_default;

-- 6. Find active users.
SELECT
    username,
    status,
    country
FROM demo_default
WHERE status = 'Active';

-- 7. Find users who have never logged in.
SELECT
    username,
    login_count
FROM demo_default
WHERE login_count = 0;

-- 8. Update the status of a specific user.
UPDATE demo_default
SET status = 'Inactive'
WHERE user_id = 2;

-- 9. Increase a user's login count.
UPDATE demo_default
SET login_count = login_count + 1
WHERE user_id = 1;

-- 10. Display updated records.
SELECT
    user_id,
    username,
    status,
    login_count,
    created_at
FROM demo_default
ORDER BY user_id;

-- 11. Display the table definition.
SHOW CREATE TABLE demo_default;
