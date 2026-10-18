
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 00_join_setup.sql
    Topic: Join Demonstration Database Setup
========================================================

Description:
Creates two related tables for practicing SQL JOINs.

Tables:
1. join_departments
2. join_employees

The sample data includes:
- Employees assigned to departments
- An employee without a department
- A department without employees
- Employees with assigned managers

Important:
Run this file before executing the join examples.

Rerunning this file resets ONLY the demonstration
tables created by this script.

========================================================
*/

USE sql_journey;

-- 1. Remove existing demonstration tables.
-- Delete the child table first because of foreign keys.
DROP TABLE IF EXISTS join_employees;
DROP TABLE IF EXISTS join_departments;

-- 2. Create the departments table.
CREATE TABLE join_departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

-- 3. Create the employees table.
CREATE TABLE join_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100),
    salary DECIMAL(10, 2),
    department_id INT,
    manager_id INT,

    CONSTRAINT fk_join_department
        FOREIGN KEY (department_id)
        REFERENCES join_departments(department_id),

    CONSTRAINT fk_join_manager
        FOREIGN KEY (manager_id)
        REFERENCES join_employees(employee_id)
);

-- 4. Insert department records.
INSERT INTO join_departments
    (department_id, department_name, location)
VALUES
    (101, 'Engineering', 'Kolkata'),
    (102, 'Human Resources', 'Delhi'),
    (103, 'Finance', 'Mumbai'),
    (104, 'Marketing', 'Bangalore'),
    (105, 'Legal', 'Hyderabad');

-- Department 105 intentionally has no employees.

-- 5. Insert managers first.
INSERT INTO join_employees
    (employee_id, employee_name, job_title,
     salary, department_id, manager_id)
VALUES
    (1, 'Priya Das', 'Engineering Manager', 90000, 101, NULL),
    (2, 'Sneha Roy', 'HR Manager', 78000, 102, NULL),
    (3, 'Amit Verma', 'Finance Manager', 85000, 103, NULL),
    (4, 'Ananya Bose', 'Marketing Manager', 82000, 104, NULL);

-- 6. Insert additional employees.
INSERT INTO join_employees
    (employee_id, employee_name, job_title,
     salary, department_id, manager_id)
VALUES
    (5, 'Arjun Sharma', 'Software Engineer', 65000, 101, 1),
    (6, 'Rahul Sen', 'HR Executive', 45000, 102, 2),
    (7, 'Neha Gupta', 'Accountant', 50000, 103, 3),
    (8, 'Vikram Singh', 'ML Engineer', 85000, 101, 1),
    (9, 'Ishita Paul', 'Research Consultant', 72000, NULL, NULL);

-- Employee 9 intentionally has no department.

-- 7. Verify departments.
SELECT *
FROM join_departments
ORDER BY department_id;

-- 8. Verify employees.
SELECT *
FROM join_employees
ORDER BY employee_id;

-- 9. Display record counts.
SELECT
    (SELECT COUNT(*) FROM join_departments)
        AS total_departments,
    (SELECT COUNT(*) FROM join_employees)
        AS total_employees;
