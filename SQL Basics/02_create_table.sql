```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 02_create_table.sql
    Topic: Creating Tables

    Description:
    Creates the departments and employees tables
    that will be used throughout the SQL Journey.
*/

USE sql_journey;

-- Create the departments table.
CREATE TABLE IF NOT EXISTS departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

-- Create the employees table.
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100),
    salary DECIMAL(10, 2),
    department_id INT,
    joining_date DATE,

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);
```
