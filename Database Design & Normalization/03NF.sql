
/*
========================================================
    SQL JOURNEY
    Module 11: Database Design & Normalization
    File: 03NF.sql
    Topic: Third Normal Form (3NF)
========================================================

Description:
Third Normal Form requires:
1. The table must satisfy 2NF.
2. Transitive dependencies of non-prime
   attributes must be eliminated.

This example demonstrates a typical
employee-department relationship.

Concepts Covered:
1. Functional dependencies
2. Transitive dependencies
3. Removing repeated department attributes
4. Entity separation
5. Foreign keys
6. Relational JOINs
7. Consistent data updates

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: DESIGN VIOLATING 3NF
-- =====================================================

-- 1. Reset demonstration tables.
DROP TABLE IF EXISTS demo_3nf_employees;
DROP TABLE IF EXISTS demo_3nf_departments;
DROP TABLE IF EXISTS demo_3nf_bad_employees;

-- 2. Create a table with repeated department data.
CREATE TABLE demo_3nf_bad_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    department_location VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2)
);

-- 3. Insert employee records.
INSERT INTO demo_3nf_bad_employees VALUES
    (1, 'Arjun Sharma', 101,
     'Engineering', 'Kolkata', 65000),

    (2, 'Priya Das', 101,
     'Engineering', 'Kolkata', 58000),

    (3, 'Rahul Sen', 102,
     'Human Resources', 'Delhi', 45000),

    (4, 'Sneha Roy', 102,
     'Human Resources', 'Delhi', 72000),

    (5, 'Amit Verma', 103,
     'Finance', 'Mumbai', 62000),

    (6, 'Neha Gupta', 103,
     'Finance', 'Mumbai', 50000);

-- 4. Display the repeated information.
SELECT *
FROM demo_3nf_bad_employees
ORDER BY employee_id;

-- Functional Dependencies:
--
-- employee_id -> employee_name
-- employee_id -> department_id
-- employee_id -> salary
--
-- department_id -> department_name
-- department_id -> department_location
--
-- Therefore:
-- employee_id -> department_id
--             -> department_name
--
-- Problem:
-- Department details depend on department_id,
-- which is not the primary key of this table.
--
-- This creates a transitive dependency
-- and violates 3NF under these business rules.


-- =====================================================
-- SECTION 2: THIRD NORMAL FORM
-- =====================================================

-- 5. Create a separate department table.
CREATE TABLE demo_3nf_departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_location VARCHAR(100) NOT NULL
);

-- 6. Create the employee table.
CREATE TABLE demo_3nf_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    salary DECIMAL(10, 2),

    FOREIGN KEY (department_id)
        REFERENCES demo_3nf_departments(department_id),

    CHECK (salary >= 0)
);

-- 7. Insert unique department information.
INSERT INTO demo_3nf_departments
SELECT DISTINCT
    department_id,
    department_name,
    department_location
FROM demo_3nf_bad_employees;

-- 8. Insert employee records.
INSERT INTO demo_3nf_employees
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM demo_3nf_bad_employees;


-- =====================================================
-- SECTION 3: QUERY THE 3NF DESIGN
-- =====================================================

-- 9. Display departments.
SELECT *
FROM demo_3nf_departments
ORDER BY department_id;

-- 10. Display employees.
SELECT *
FROM demo_3nf_employees
ORDER BY employee_id;

-- 11. Reconstruct the employee report.
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    d.department_location,
    e.salary
FROM demo_3nf_employees AS e
INNER JOIN demo_3nf_departments AS d
    ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- 12. Count employees per department.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM demo_3nf_departments AS d
LEFT JOIN demo_3nf_employees AS e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;

-- 13. Calculate average salaries.
SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM demo_3nf_departments AS d
INNER JOIN demo_3nf_employees AS e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;

-- 14. Update a department's location once.
UPDATE demo_3nf_departments
SET department_location = 'Bengaluru'
WHERE department_id = 101;

-- 15. Verify that employees now reference
-- the updated department information.
SELECT
    e.employee_name,
    d.department_name,
    d.department_location
FROM demo_3nf_employees AS e
INNER JOIN demo_3nf_departments AS d
    ON e.department_id = d.department_id
WHERE d.department_id = 101;

-- 16. Demonstrate inserting a department
-- even before hiring an employee.
INSERT INTO demo_3nf_departments
    (department_id, department_name,
     department_location)
VALUES
    (104, 'Research and Development', 'Hyderabad');

-- 17. Show departments with no employees.
SELECT
    d.department_id,
    d.department_name
FROM demo_3nf_departments AS d
LEFT JOIN demo_3nf_employees AS e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- 18. Display foreign key information.
SHOW CREATE TABLE demo_3nf_employees;

-- Important:
-- Department information is stored once.
--
-- Employees reference departments
-- through a foreign key.
--
-- Updating a department does not require
-- updating every employee record.
--
-- The schema reduces common update,
-- insertion, and deletion anomalies.
--
-- Formal 3NF also considers all candidate
-- keys and prime attributes. This example
-- illustrates the common transitive
-- dependency problem.
