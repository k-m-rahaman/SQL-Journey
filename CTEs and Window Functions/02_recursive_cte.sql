
/*
========================================================
    SQL JOURNEY
    Module 10: CTEs and Window Functions
    File: 02_recursive_cte.sql
    Topic: Recursive Common Table Expressions
========================================================

Description:
Recursive CTEs repeatedly reference their
own results to generate new rows.

They are useful for:
1. Number sequences
2. Date sequences
3. Mathematical calculations
4. Organizational hierarchies
5. Hierarchical paths
6. Recursive business reports

Structure:
- Anchor member
- UNION ALL
- Recursive member
- Termination condition

========================================================
*/

USE sql_journey;

-- 1. Generate numbers from 1 to 10.
WITH RECURSIVE number_sequence AS (
    -- Anchor member
    SELECT 1 AS number

    UNION ALL

    -- Recursive member
    SELECT number + 1
    FROM number_sequence
    WHERE number < 10
)
SELECT *
FROM number_sequence;


-- 2. Generate multiples of five up to 50.
WITH RECURSIVE multiples_of_five AS (
    SELECT 5 AS number

    UNION ALL

    SELECT number + 5
    FROM multiples_of_five
    WHERE number < 50
)
SELECT *
FROM multiples_of_five;


-- 3. Generate a date sequence.
-- Create dates from January 1 to January 7.
WITH RECURSIVE date_sequence AS (
    SELECT
        DATE('2026-01-01') AS current_day

    UNION ALL

    SELECT
        DATE_ADD(current_day, INTERVAL 1 DAY)
    FROM date_sequence
    WHERE current_day < '2026-01-07'
)
SELECT *
FROM date_sequence
ORDER BY current_day;


-- 4. Generate a multiplication table.
-- Calculate the multiplication table of 7.
WITH RECURSIVE multiplication AS (
    SELECT 1 AS multiplier

    UNION ALL

    SELECT multiplier + 1
    FROM multiplication
    WHERE multiplier < 10
)
SELECT
    multiplier,
    7 AS base_number,
    multiplier * 7 AS result
FROM multiplication;


-- 5. Calculate factorial values.
-- Generate factorials from 1! to 7!.
WITH RECURSIVE factorial_sequence AS (
    SELECT
        1 AS number,
        CAST(1 AS DECIMAL(20, 0)) AS factorial

    UNION ALL

    SELECT
        number + 1,
        factorial * (number + 1)
    FROM factorial_sequence
    WHERE number < 7
)
SELECT
    number,
    factorial
FROM factorial_sequence;


-- 6. Generate salary brackets.
WITH RECURSIVE salary_brackets AS (
    SELECT 0 AS minimum_salary

    UNION ALL

    SELECT minimum_salary + 25000
    FROM salary_brackets
    WHERE minimum_salary < 100000
)
SELECT
    minimum_salary,
    minimum_salary + 24999 AS maximum_salary
FROM salary_brackets
ORDER BY minimum_salary;


-- 7. Recursive organizational hierarchy.
-- Create a small organization using an inline CTE.
-- No additional database tables are required.
WITH RECURSIVE
team AS (
    SELECT
        1 AS employee_id,
        'Priya Das' AS employee_name,
        CAST(NULL AS SIGNED) AS manager_id

    UNION ALL SELECT 2, 'Arjun Sharma', 1
    UNION ALL SELECT 3, 'Vikram Singh', 1
    UNION ALL SELECT 4, 'Neha Gupta', 2
    UNION ALL SELECT 5, 'Rahul Sen', 2
),
organization AS (
    -- Start with top-level employees.
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS hierarchy_level,
        CAST(employee_name AS CHAR(500))
            AS reporting_path
    FROM team
    WHERE manager_id IS NULL

    UNION ALL

    -- Retrieve direct reports recursively.
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        o.hierarchy_level + 1,
        CONCAT(
            o.reporting_path,
            ' > ',
            e.employee_name
        )
    FROM team AS e
    INNER JOIN organization AS o
        ON e.manager_id = o.employee_id
    WHERE o.hierarchy_level < 10
)
SELECT
    employee_id,
    employee_name,
    manager_id,
    hierarchy_level,
    reporting_path
FROM organization
ORDER BY reporting_path;


-- 8. Generate the first ten Fibonacci numbers.
WITH RECURSIVE fibonacci AS (
    SELECT
        1 AS position,
        CAST(0 AS UNSIGNED) AS current_value,
        CAST(1 AS UNSIGNED) AS next_value

    UNION ALL

    SELECT
        position + 1,
        next_value,
        current_value + next_value
    FROM fibonacci
    WHERE position < 10
)
SELECT
    position,
    current_value AS fibonacci_number
FROM fibonacci
ORDER BY position;


-- 9. Generate the last seven calendar dates
-- ending at the current database date.
WITH RECURSIVE recent_dates AS (
    SELECT
        CURRENT_DATE() AS calendar_date,
        1 AS day_number

    UNION ALL

    SELECT
        DATE_SUB(calendar_date, INTERVAL 1 DAY),
        day_number + 1
    FROM recent_dates
    WHERE day_number < 7
)
SELECT
    calendar_date,
    day_number
FROM recent_dates
ORDER BY calendar_date DESC;


-- Important:
-- WITH RECURSIVE enables self-referencing CTEs.
--
-- Always include a termination condition.
--
-- UNION ALL is commonly used to combine
-- anchor and recursive members.
--
-- Use CAST() when recursive values may
-- require a wider string or numeric type.
--
-- MySQL limits recursion through the
-- cte_max_recursion_depth system setting.
--
-- Hierarchical data should be protected
-- against cycles and excessive recursion.
