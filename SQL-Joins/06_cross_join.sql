
/*
========================================================
    SQL JOURNEY
    Module 06: SQL Joins
    File: 06_cross_join.sql
    Topic: CROSS JOIN
========================================================

Description:
CROSS JOIN returns every possible combination
of rows from two tables.

This is also called a Cartesian product.

Total rows:
Rows in Table A × Rows in Table B

Concepts Covered:
1. Basic CROSS JOIN
2. CROSS JOIN with COUNT()
3. CROSS JOIN with filtering
4. CROSS JOIN with LIMIT
5. Cartesian product applications

========================================================
*/

USE sql_journey;

-- 1. Basic CROSS JOIN
-- Create every employee-department combination.
SELECT
    e.employee_name,
    d.department_name
FROM join_employees AS e
CROSS JOIN join_departments AS d
ORDER BY e.employee_id, d.department_id;

-- 2. Count all combinations.
SELECT
    COUNT(*) AS total_combinations
FROM join_employees AS e
CROSS JOIN join_departments AS d;

-- 3. Calculate expected combinations.
SELECT
    (SELECT COUNT(*) FROM join_employees)
    *
    (SELECT COUNT(*) FROM join_departments)
    AS expected_combinations;

-- 4. CROSS JOIN with LIMIT
-- Display only the first ten combinations.
SELECT
    e.employee_name,
    d.department_name
FROM join_employees AS e
CROSS JOIN join_departments AS d
ORDER BY e.employee_id, d.department_id
LIMIT 10;

-- 5. CROSS JOIN with filtering
-- Generate combinations where employees
-- are assigned to a department other than
-- their current department.
SELECT
    e.employee_name,
    d.department_name AS alternative_department
FROM join_employees AS e
CROSS JOIN join_departments AS d
WHERE e.department_id <> d.department_id
ORDER BY e.employee_id, d.department_id;

-- Note:
-- Employees with NULL department_id are
-- excluded by this comparison because
-- NULL <> value evaluates to UNKNOWN.

-- 6. Practical example
-- Generate all training assignments.
-- Every employee is paired with every
-- available training course.
SELECT
    e.employee_name,
    c.course_name
FROM join_employees AS e
CROSS JOIN (
    SELECT 'SQL Fundamentals' AS course_name
    UNION ALL
    SELECT 'Python Programming'
    UNION ALL
    SELECT 'Data Analytics'
) AS c
ORDER BY e.employee_id, c.course_name;

-- 7. Practical example
-- Calculate the number of training assignments.
SELECT
    COUNT(*) AS training_assignments
FROM join_employees AS e
CROSS JOIN (
    SELECT 'SQL Fundamentals' AS course_name
    UNION ALL
    SELECT 'Python Programming'
    UNION ALL
    SELECT 'Data Analytics'
) AS c;

-- 8. Generate a multiplication table from 1 to 5.
WITH numbers AS (
    SELECT 1 AS n
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
)
SELECT
    a.n AS first_number,
    b.n AS second_number,
    a.n * b.n AS product
FROM numbers AS a
CROSS JOIN numbers AS b
ORDER BY a.n, b.n;

-- Note:
-- CROSS JOIN can generate large result sets.
-- Use it carefully with large tables.
