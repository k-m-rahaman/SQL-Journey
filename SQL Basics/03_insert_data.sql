```sql
/*
    SQL Journey
    Part 01: SQL Basics

    File: 03_insert_data.sql
    Topic: Inserting Data

    Description:
    Inserts sample departments and employee records
    into the database.
*/

USE sql_journey;

-- Insert department records.
INSERT INTO departments
    (department_id, department_name, location)
VALUES
    (101, 'Computer Science', 'Kolkata'),
    (102, 'Human Resources', 'Delhi'),
    (103, 'Finance', 'Mumbai'),
    (104, 'Marketing', 'Bangalore'),
    (105, 'Research and Development', 'Hyderabad');

-- Insert employee records.
INSERT INTO employees
    (employee_id, employee_name, job_title, salary, department_id, joining_date)
VALUES
    (1, 'Arjun Sharma', 'Software Engineer', 65000.00, 101, '2024-01-15'),
    (2, 'Priya Das', 'Data Analyst', 58000.00, 101, '2024-03-10'),
    (3, 'Rahul Sen', 'HR Executive', 45000.00, 102, '2023-11-20'),
    (4, 'Sneha Roy', 'HR Manager', 72000.00, 102, '2022-07-18'),
    (5, 'Amit Verma', 'Financial Analyst', 62000.00, 103, '2023-05-12'),
    (6, 'Neha Gupta', 'Accountant', 50000.00, 103, '2024-02-25'),
    (7, 'Rohan Mehta', 'Marketing Executive', 48000.00, 104, '2023-09-05'),
    (8, 'Ananya Bose', 'Marketing Manager', 75000.00, 104, '2021-06-14'),
    (9, 'Vikram Singh', 'ML Engineer', 85000.00, 105, '2022-10-30'),
    (10, 'Ishita Paul', 'Research Scientist', 92000.00, 105, '2021-12-01');
```
