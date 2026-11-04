
/*
========================================================
    SQL JOURNEY
    Module 12: SQL Interview Problems
    File: 03_nth_highest_salary.sql
    Problem: Nth Highest Salary
    Difficulty: Medium
========================================================

Problem Statement:
Find the Nth highest DISTINCT salary
from an employee table.

Concepts Covered:
1. User-defined variables
2. DISTINCT
3. DENSE_RANK()
4. Correlated subqueries
5. CTEs
6. PARTITION BY
7. Handling ties
8. Handling missing rank values

Database: MySQL 8.0+

========================================================
*/

USE sql_journey;

-- Set the desired salary rank.
-- Change this value to find another rank.
SET @nth_salary_rank = 3;


-- =====================================================
-- APPROACH 1: DENSE_RANK() WITH A CTE
-- =====================================================

WITH salary_levels AS (
    SELECT DISTINCT salary
    FROM employees
    WHERE salary IS NOT NULL
),
ranked_salaries AS (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM salary_levels
)
SELECT
    salary AS nth_highest_salary
FROM ranked_salaries
WHERE salary_rank = @nth_salary_rank;


-- =====================================================
-- APPROACH 2: CORRELATED SUBQUERY
-- =====================================================

-- A salary is the Nth highest if exactly
-- N - 1 distinct salaries are greater.

SELECT DISTINCT
    e.salary AS nth_highest_salary
FROM employees AS e
WHERE e.salary IS NOT NULL
  AND (
      SELECT COUNT(DISTINCT e2.salary)
      FROM employees AS e2
      WHERE e2.salary > e.salary
  ) = @nth_salary_rank - 1;


-- =====================================================
-- APPROACH 3: FIND EMPLOYEES AT THE NTH SALARY
-- =====================================================

WITH ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
    WHERE salary IS NOT NULL
)
SELECT
    employee_name,
    salary,
    salary_rank
FROM ranked_employees
WHERE salary_rank = @nth_salary_rank
ORDER BY employee_id;


-- =====================================================
-- APPROACH 4: RETURN NULL WHEN RANK IS MISSING
-- =====================================================

WITH salary_levels AS (
    SELECT DISTINCT salary
    FROM employees
    WHERE salary IS NOT NULL
),
ranked_salaries AS (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM salary_levels
)
SELECT (
    SELECT salary
    FROM ranked_salaries
    WHERE salary_rank = @nth_salary_rank
) AS nth_highest_salary;

-- If N exceeds the number of distinct salaries,
-- the scalar subquery returns NULL.


-- =====================================================
-- APPROACH 5: NTH HIGHEST SALARY PER DEPARTMENT
-- =====================================================

-- Find the second-highest distinct salary
-- within every department.

SET @department_rank = 2;

WITH department_rankings AS (
    SELECT
        employee_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
    WHERE salary IS NOT NULL
)
SELECT
    employee_name,
    department_id,
    salary
FROM department_rankings
WHERE salary_rank = @department_rank
ORDER BY department_id, employee_name;


-- =====================================================
-- APPROACH 6: HANDLE DUPLICATE SALARIES
-- =====================================================

WITH sample_salaries AS (
    SELECT 1 AS employee_id, 100000 AS salary
    UNION ALL SELECT 2, 100000
    UNION ALL SELECT 3, 90000
    UNION ALL SELECT 4, 80000
    UNION ALL SELECT 5, 80000
),
ranked AS (
    SELECT
        employee_id,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM sample_salaries
)
SELECT *
FROM ranked
ORDER BY salary_rank, employee_id;


-- =====================================================
-- APPROACH 7: DISPLAY ALL DISTINCT SALARY RANKS
-- =====================================================

WITH salary_levels AS (
    SELECT DISTINCT salary
    FROM employees
    WHERE salary IS NOT NULL
)
SELECT
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM salary_levels
ORDER BY salary_rank;


-- =====================================================
-- INTERVIEW NOTES
-- =====================================================

/*
Important:
- N must be a positive integer.
- Nth highest usually means Nth distinct salary.
- DENSE_RANK() handles ties without gaps.
- ROW_NUMBER() counts individual rows and
  is not equivalent when duplicate salaries exist.
- PARTITION BY allows ranking within departments.
- Return NULL if the requested rank does not exist.

Performance:
Window functions may require sorting.
Correlated subqueries may perform repeated
comparisons depending on optimizer behavior.
*/
