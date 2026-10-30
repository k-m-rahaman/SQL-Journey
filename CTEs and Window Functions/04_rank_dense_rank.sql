
/*
========================================================
    SQL JOURNEY
    Module 10: CTEs and Window Functions
    File: 04_rank_dense_rank.sql
    Topic: RANK() and DENSE_RANK()
========================================================

Description:
Ranking window functions assign positions
to records based on their values.

RANK():
Tied values receive the same rank.
Gaps appear after ties.

DENSE_RANK():
Tied values receive the same rank.
No ranking gaps appear.

Concepts Covered:
1. Basic RANK()
2. Basic DENSE_RANK()
3. Comparing ranking functions
4. Ranking with duplicate values
5. Department-wise salary rankings
6. Top-ranked employees
7. Top N distinct salary levels
8. NTILE() salary groups

========================================================
*/

USE sql_journey;

-- 1. Basic RANK()
-- Rank employees by salary.
SELECT
    employee_name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees
ORDER BY salary_rank, employee_id;


-- 2. Basic DENSE_RANK()
-- Rank employees without gaps after ties.
SELECT
    employee_name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS dense_salary_rank
FROM employees
ORDER BY dense_salary_rank, employee_id;


-- 3. Compare three ranking functions.
SELECT
    employee_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC, employee_id
    ) AS row_num,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS dense_rank_value
FROM employees
ORDER BY salary DESC, employee_id;


-- 4. Demonstrate tied values.
-- Inline sample records ensure that
-- multiple employees have equal scores.
WITH demo_scores AS (
    SELECT 'Arjun' AS student, 95 AS score
    UNION ALL SELECT 'Priya', 90
    UNION ALL SELECT 'Rahul', 90
    UNION ALL SELECT 'Sneha', 85
    UNION ALL SELECT 'Amit', 80
)
SELECT
    student,
    score,
    ROW_NUMBER() OVER (
        ORDER BY score DESC, student
    ) AS row_num,
    RANK() OVER (
        ORDER BY score DESC
    ) AS standard_rank,
    DENSE_RANK() OVER (
        ORDER BY score DESC
    ) AS dense_rank_value
FROM demo_scores
ORDER BY score DESC, student;


-- 5. Department-wise salary rankings.
SELECT
    employee_name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS department_rank,
    DENSE_RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS department_dense_rank
FROM employees
ORDER BY department_id, salary DESC;


-- 6. Find the top three salary ranks.
-- Tied employees share the same rank.
WITH salary_rankings AS (
    SELECT
        employee_name,
        salary,
        RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM salary_rankings
WHERE salary_rank <= 3
ORDER BY salary_rank, employee_name;


-- 7. Find employees belonging to the
-- top two distinct salary levels.
WITH dense_salary_rankings AS (
    SELECT
        employee_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_level
    FROM employees
)
SELECT *
FROM dense_salary_rankings
WHERE salary_level <= 2
ORDER BY salary_level, employee_name;


-- 8. Identify employees with the
-- highest salary in each department.
-- Tied highest-paid employees are included.
WITH department_rankings AS (
    SELECT
        employee_name,
        department_id,
        salary,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT
    employee_name,
    department_id,
    salary
FROM department_rankings
WHERE salary_rank = 1
ORDER BY department_id, employee_name;


-- 9. NTILE()
-- Divide employees into three salary groups.
SELECT
    employee_name,
    salary,
    NTILE(3) OVER (
        ORDER BY salary DESC, employee_id
    ) AS salary_group
FROM employees
ORDER BY salary_group, salary DESC;


-- 10. Practical example
-- Rank departments by average employee salary.
WITH department_averages AS (
    SELECT
        d.department_name,
        ROUND(AVG(e.salary), 2) AS average_salary
    FROM departments AS d
    INNER JOIN employees AS e
        ON d.department_id = e.department_id
    GROUP BY
        d.department_id,
        d.department_name
)
SELECT
    department_name,
    average_salary,
    RANK() OVER (
        ORDER BY average_salary DESC
    ) AS department_rank,
    DENSE_RANK() OVER (
        ORDER BY average_salary DESC
    ) AS dense_department_rank
FROM department_averages
ORDER BY department_rank, department_name;


-- Important:
-- ROW_NUMBER(): unique sequential positions.
-- RANK(): equal values share a rank, with gaps.
-- DENSE_RANK(): equal values share a rank,
-- without gaps.
--
-- ORDER BY in a ranking window determines
-- which rows are treated as tied peers.
--
-- Adding employee_id to a RANK() ORDER BY
-- would break salary ties. Therefore, use
-- only salary when ranking salary values.
