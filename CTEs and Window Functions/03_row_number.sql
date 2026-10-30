
/*
========================================================
    SQL JOURNEY
    Module 10: CTEs and Window Functions
    File: 03_row_number.sql
    Topic: ROW_NUMBER() Window Function
========================================================

Description:
ROW_NUMBER() assigns sequential row numbers
to records within an ordered window.

Concepts Covered:
1. Basic ROW_NUMBER()
2. ROW_NUMBER() with salary sorting
3. ROW_NUMBER() with PARTITION BY
4. Department-wise rankings
5. Top N employees per department
6. Pagination using row numbers
7. Earliest and latest employees
8. Unique display identifiers

========================================================
*/

USE sql_journey;

-- 1. Basic ROW_NUMBER()
-- Assign numbers based on employee ID.
SELECT
    ROW_NUMBER() OVER (
        ORDER BY employee_id
    ) AS row_num,
    employee_id,
    employee_name
FROM employees
ORDER BY row_num;


-- 2. ROW_NUMBER() with salary
-- Number employees from highest to lowest salary.
SELECT
    employee_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC, employee_id
    ) AS salary_position
FROM employees
ORDER BY salary_position;


-- 3. ROW_NUMBER() with PARTITION BY
-- Restart numbering for each department.
SELECT
    employee_name,
    department_id,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC, employee_id
    ) AS department_row_number
FROM employees
ORDER BY department_id, department_row_number;


-- 4. ROW_NUMBER() with JOIN
-- Display department names and employee positions.
SELECT
    d.department_name,
    e.employee_name,
    e.salary,
    ROW_NUMBER() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC, e.employee_id
    ) AS salary_position
FROM employees AS e
INNER JOIN departments AS d
    ON e.department_id = d.department_id
ORDER BY d.department_id, salary_position;


-- 5. Top two employees per department
-- Use a CTE because a window function
-- cannot be used directly in WHERE.
WITH ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC, employee_id
        ) AS row_num
    FROM employees
)
SELECT
    employee_name,
    department_id,
    salary,
    row_num
FROM ranked_employees
WHERE row_num <= 2
ORDER BY department_id, row_num;


-- 6. Pagination using ROW_NUMBER()
-- Retrieve positions 4 through 6
-- when employees are ordered by salary.
WITH numbered_employees AS (
    SELECT
        employee_id,
        employee_name,
        salary,
        ROW_NUMBER() OVER (
            ORDER BY salary DESC, employee_id
        ) AS row_num
    FROM employees
)
SELECT *
FROM numbered_employees
WHERE row_num BETWEEN 4 AND 6
ORDER BY row_num;


-- 7. Find the earliest employee
-- in every department.
WITH joining_order AS (
    SELECT
        employee_name,
        department_id,
        joining_date,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY joining_date ASC, employee_id
        ) AS row_num
    FROM employees
)
SELECT
    employee_name,
    department_id,
    joining_date
FROM joining_order
WHERE row_num = 1
ORDER BY department_id;


-- 8. Find the latest employee
-- to join each department.
WITH recent_joiners AS (
    SELECT
        employee_name,
        department_id,
        joining_date,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY joining_date DESC, employee_id
        ) AS row_num
    FROM employees
)
SELECT
    employee_name,
    department_id,
    joining_date
FROM recent_joiners
WHERE row_num = 1
ORDER BY department_id;


-- 9. Generate display identifiers.
-- These identifiers are query results,
-- not permanent employee primary keys.
SELECT
    employee_id,
    employee_name,
    CONCAT(
        'EMP-',
        LPAD(
            ROW_NUMBER() OVER (
                ORDER BY employee_id
            ),
            3,
            '0'
        )
    ) AS display_id
FROM employees
ORDER BY employee_id;


-- 10. Practical example
-- Find the highest-paid employee
-- in every department.
WITH ranked_salaries AS (
    SELECT
        e.employee_name,
        e.salary,
        d.department_name,
        ROW_NUMBER() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC, e.employee_id
        ) AS salary_rank
    FROM employees AS e
    INNER JOIN departments AS d
        ON e.department_id = d.department_id
)
SELECT
    department_name,
    employee_name,
    salary
FROM ranked_salaries
WHERE salary_rank = 1
ORDER BY salary DESC;


-- Important:
-- ROW_NUMBER() always assigns unique
-- sequential numbers within each partition.
--
-- PARTITION BY restarts the numbering.
--
-- ORDER BY inside OVER() determines the
-- order in which row numbers are assigned.
--
-- Add a unique column such as employee_id
-- to make ordering deterministic when
-- salary or date values are tied.
