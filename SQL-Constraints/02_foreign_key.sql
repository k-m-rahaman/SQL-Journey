
/*
========================================================
    SQL JOURNEY
    Module 03: SQL Constraints
    File: 02_foreign_key.sql
    Topic: FOREIGN KEY Constraint
========================================================

Description:
A FOREIGN KEY establishes a relationship between
two tables and maintains referential integrity.

Important:
1. References a PRIMARY KEY or suitable UNIQUE key.
2. Prevents invalid references.
3. Maintains consistency between related tables.

Prerequisite:
Run the SQL Basics setup files first.
The departments table must already exist.

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_foreign_key;

-- 2. Create a child table referencing departments.
CREATE TABLE demo_foreign_key (
    assignment_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,

    CONSTRAINT fk_demo_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 3. Insert valid records.
-- Department IDs 101, 102, 103, and 105 exist.
INSERT INTO demo_foreign_key
    (assignment_id, employee_name, department_id)
VALUES
    (1, 'Arjun Sharma', 101),
    (2, 'Priya Das', 101),
    (3, 'Rahul Sen', 102),
    (4, 'Amit Verma', 103),
    (5, 'Vikram Singh', 105);

-- 4. Display all assignments.
SELECT *
FROM demo_foreign_key;

-- 5. Retrieve employee names with departments.
SELECT
    e.assignment_id,
    e.employee_name,
    d.department_name,
    d.location
FROM demo_foreign_key AS e
INNER JOIN departments AS d
    ON e.department_id = d.department_id;

-- 6. Find employees in department 101.
SELECT
    employee_name,
    department_id
FROM demo_foreign_key
WHERE department_id = 101;

-- 7. Invalid example: department 999 does not exist.
-- The FOREIGN KEY constraint rejects this record.
-- INSERT INTO demo_foreign_key
-- VALUES (6, 'Unknown Employee', 999);

-- 8. Examine the table definition.
SHOW CREATE TABLE demo_foreign_key;
