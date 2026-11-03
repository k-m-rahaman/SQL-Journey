
/*
========================================================
    SQL JOURNEY
    Module 12: SQL Interview Problems
    File: 01_second_highest_salary.sql
    Problem: Second Highest Salary
    Difficulty: Easy
========================================================

Problem Statement:
Find the second-highest DISTINCT salary
from the employees table.

Concepts Covered:
1. MAX()
2. Subqueries
3. DISTINCT
4. ORDER BY
5. LIMIT and OFFSET
6. DENSE_RANK()
7. Common Table Expressions
8. Handling missing results

Database: MySQL 8.0+

========================================================
*/

USE sql_journey;

-- =====================================================
-- APPROACH 1: MAX() WITH SUBQUERY
-- =====================================================

-- Find the highest salary below the
-- maximum salary in the company.

SELECT
    MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);

-- Explanation:
-- 1. Inner query finds the highest salary.
-- 2. Outer query excludes that salary.
-- 3. MAX() returns the next-highest value.


-- =====================================================
-- APPROACH 2: DISTINCT WITH LIMIT AND OFFSET
-- =====================================================

SELECT DISTINCT
    salary
FROM employees
WHERE salary IS NOT NULL
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

-- Explanation:
-- DISTINCT removes repeated salary values.
-- DESC sorts salaries from highest to lowest.
-- OFFSET 1 skips the highest distinct salary.
-- LIMIT 1 retrieves the second-highest.


-- =====================================================
-- APPROACH 3: DENSE_RANK()
-- =====================================================

WITH ranked_salaries AS (
    SELECT
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
FROM ranked_salaries
WHERE salary_rank = 2
ORDER BY employee_name;

-- Explanation:
-- DENSE_RANK assigns the same rank to
-- employees earning the same salary.
-- The next distinct salary receives rank 2.


-- =====================================================
-- APPROACH 4: RETURN NULL IF NO SECOND SALARY
-- =====================================================

SELECT (
    SELECT DISTINCT
        salary
    FROM employees
    WHERE salary IS NOT NULL
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS second_highest_salary;

-- Explanation:
-- A scalar subquery returns NULL when
-- there is no second distinct salary.


-- =====================================================
-- APPROACH 5: COUNT DISTINCT HIGHER SALARIES
-- =====================================================

SELECT DISTINCT
    e.salary AS second_highest_salary
FROM employees AS e
WHERE e.salary IS NOT NULL
  AND (
      SELECT COUNT(DISTINCT e2.salary)
      FROM employees AS e2
      WHERE e2.salary > e.salary
  ) = 1;

-- Explanation:
-- Exactly one distinct salary must be
-- greater than the second-highest salary.


-- =====================================================
-- APPROACH 6: HANDLE DUPLICATE TOP SALARIES
-- =====================================================

-- Create an inline demonstration dataset.
-- The maximum salary occurs twice.

WITH sample_salaries AS (
    SELECT 1 AS employee_id, 95000 AS salary
    UNION ALL SELECT 2, 95000
    UNION ALL SELECT 3, 85000
    UNION ALL SELECT 4, 75000
    UNION ALL SELECT 5, 75000
)
SELECT
    MAX(salary) AS second_highest_salary
FROM sample_salaries
WHERE salary < (
    SELECT MAX(salary)
    FROM sample_salaries
);


-- =====================================================
-- APPROACH 7: VERIFY DISTINCT SALARY LEVELS
-- =====================================================

SELECT
    salary,
    COUNT(*) AS employee_count
FROM employees
WHERE salary IS NOT NULL
GROUP BY salary
ORDER BY salary DESC;


-- =====================================================
-- INTERVIEW NOTES
-- =====================================================

/*
Important:
- Second highest means second distinct value.
- Duplicate maximum salaries must not
  change the result.
- MAX() with a subquery is concise.
- DENSE_RANK() is useful when employee
  details must be returned.
- LIMIT/OFFSET is simple for one result.
- Consider NULL salaries and fewer than
  two distinct values.

Approximate complexity:
Indexing and query plans affect performance.

The MAX() method typically scans salary data
to determine the required maximum values.

Sorting approaches may require O(n log n)
work when an appropriate index is unavailable.
*/
