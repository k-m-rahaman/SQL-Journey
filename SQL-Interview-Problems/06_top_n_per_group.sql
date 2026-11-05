
/*
========================================================
    SQL JOURNEY
    Module 12: SQL Interview Problems
    File: 06_top_n_per_group.sql
    Problem: Top N Records per Group
    Difficulty: Hard
========================================================

Problem Statement:
Find the top N employees in each department
based on performance scores or salaries.

Concepts Covered:
1. ROW_NUMBER()
2. RANK()
3. DENSE_RANK()
4. PARTITION BY
5. ORDER BY
6. Common Table Expressions
7. Handling duplicate scores
8. Dynamic Top N queries
9. Top N records using subqueries
10. Department-wise analysis

Database: MySQL 8.0+

========================================================
*/

USE sql_journey;


-- =====================================================
-- SECTION 1: CREATE DEMONSTRATION DATA
-- =====================================================

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_interview_performance;

-- 2. Create an employee performance table.
CREATE TABLE demo_interview_performance (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    performance_score INT NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,

    CONSTRAINT chk_demo_performance_score
        CHECK (performance_score BETWEEN 0 AND 100)
);

-- 3. Insert employee performance records.
-- Some employees intentionally have equal scores.

INSERT INTO demo_interview_performance
    (employee_id, employee_name, department_id,
     performance_score, salary)
VALUES
    (1, 'Arjun Sharma', 101, 96, 85000),
    (2, 'Priya Das', 101, 92, 79000),
    (3, 'Vikram Singh', 101, 92, 81000),
    (4, 'Rohit Sen', 101, 86, 60000),
    (5, 'Neha Gupta', 101, 79, 52000),

    (6, 'Sneha Roy', 102, 94, 80000),
    (7, 'Rahul Sen', 102, 89, 60000),
    (8, 'Amit Kapoor', 102, 89, 62000),
    (9, 'Ishita Paul', 102, 82, 56000),

    (10, 'Ananya Bose', 103, 97, 91000),
    (11, 'Karan Mehta', 103, 93, 88000),
    (12, 'Riya Das', 103, 90, 75000),
    (13, 'Suman Dey', 103, 90, 73000),
    (14, 'Tara Ghosh', 103, 75, 48000);

-- 4. Display the complete dataset.
SELECT *
FROM demo_interview_performance
ORDER BY department_id, performance_score DESC;


-- =====================================================
-- APPROACH 1: ROW_NUMBER()
-- =====================================================

-- Find the top 2 employees in each department.
-- Each employee receives a unique position.
-- Employee ID breaks ties deterministically.

WITH ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        performance_score,

        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC,
                     employee_id ASC
        ) AS row_num

    FROM demo_interview_performance
)
SELECT
    employee_name,
    department_id,
    performance_score,
    row_num
FROM ranked_employees
WHERE row_num <= 2
ORDER BY department_id, row_num;


-- =====================================================
-- APPROACH 2: RANK()
-- =====================================================

-- Find employees within the top 2 ranks
-- of each department.
--
-- Tied employees share the same rank.
-- This may return more than 2 employees.

WITH ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        performance_score,

        RANK() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC
        ) AS performance_rank

    FROM demo_interview_performance
)
SELECT
    employee_name,
    department_id,
    performance_score,
    performance_rank
FROM ranked_employees
WHERE performance_rank <= 2
ORDER BY department_id,
         performance_rank,
         employee_id;


-- =====================================================
-- APPROACH 3: DENSE_RANK()
-- =====================================================

-- Find employees belonging to the top
-- 3 distinct performance score levels.
--
-- Ties are preserved.
-- Ranking gaps are not introduced.

WITH dense_ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        performance_score,

        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC
        ) AS dense_rank_value

    FROM demo_interview_performance
)
SELECT
    employee_name,
    department_id,
    performance_score,
    dense_rank_value
FROM dense_ranked_employees
WHERE dense_rank_value <= 3
ORDER BY department_id,
         dense_rank_value,
         employee_id;


-- =====================================================
-- APPROACH 4: COMPARE ALL THREE RANKING FUNCTIONS
-- =====================================================

SELECT
    employee_name,
    department_id,
    performance_score,

    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY performance_score DESC,
                 employee_id
    ) AS row_num,

    RANK() OVER (
        PARTITION BY department_id
        ORDER BY performance_score DESC
    ) AS standard_rank,

    DENSE_RANK() OVER (
        PARTITION BY department_id
        ORDER BY performance_score DESC
    ) AS dense_rank_value

FROM demo_interview_performance
ORDER BY department_id,
         performance_score DESC,
         employee_id;


-- =====================================================
-- APPROACH 5: DYNAMIC TOP N
-- =====================================================

-- Change the value of N to select
-- a different number of employees.

SET @top_n = 3;

WITH numbered_employees AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        performance_score,

        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC,
                     employee_id
        ) AS row_num

    FROM demo_interview_performance
)
SELECT
    employee_name,
    department_id,
    performance_score
FROM numbered_employees
WHERE row_num <= @top_n
ORDER BY department_id, row_num;


-- =====================================================
-- APPROACH 6: TOP EMPLOYEE IN EVERY DEPARTMENT
-- =====================================================

-- Return every employee sharing the
-- highest performance score in a department.

WITH department_leaders AS (
    SELECT
        employee_name,
        department_id,
        performance_score,

        RANK() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC
        ) AS performance_rank

    FROM demo_interview_performance
)
SELECT
    employee_name,
    department_id,
    performance_score
FROM department_leaders
WHERE performance_rank = 1
ORDER BY department_id, employee_name;


-- =====================================================
-- APPROACH 7: TOP 2 SALARIES PER DEPARTMENT
-- =====================================================

-- Use the original employees table.
-- Retrieve the top 2 highest-paid employees
-- within each department.

WITH salary_rankings AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        salary,

        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC, employee_id
        ) AS salary_position

    FROM employees
    WHERE salary IS NOT NULL
)
SELECT
    employee_name,
    department_id,
    salary,
    salary_position
FROM salary_rankings
WHERE salary_position <= 2
ORDER BY department_id, salary_position;


-- =====================================================
-- APPROACH 8: CORRELATED SUBQUERY
-- =====================================================

-- Find employees who belong to the
-- top 2 distinct score levels in
-- their respective departments.
--
-- Count the number of distinct scores
-- greater than the current employee's score.

SELECT
    e.employee_name,
    e.department_id,
    e.performance_score
FROM demo_interview_performance AS e
WHERE (
    SELECT COUNT(DISTINCT e2.performance_score)
    FROM demo_interview_performance AS e2
    WHERE e2.department_id = e.department_id
      AND e2.performance_score > e.performance_score
) < 2
ORDER BY e.department_id,
         e.performance_score DESC,
         e.employee_id;


-- =====================================================
-- APPROACH 9: TOP 2 WITH DEPARTMENT NAMES
-- =====================================================

-- Combine the ranking results with
-- the departments table from Part 1.

WITH ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        department_id,
        performance_score,

        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC,
                     employee_id
        ) AS row_num

    FROM demo_interview_performance
)
SELECT
    d.department_name,
    r.employee_name,
    r.performance_score,
    r.row_num AS department_position
FROM ranked_employees AS r
INNER JOIN departments AS d
    ON r.department_id = d.department_id
WHERE r.row_num <= 2
ORDER BY d.department_id, r.row_num;


-- =====================================================
-- APPROACH 10: COUNT TOP-RANKED EMPLOYEES
-- =====================================================

-- Count how many employees appear within
-- the top 2 distinct performance levels.

WITH ranked_employees AS (
    SELECT
        department_id,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY performance_score DESC
        ) AS performance_rank
    FROM demo_interview_performance
)
SELECT
    department_id,
    COUNT(*) AS employees_in_top_two_levels
FROM ranked_employees
WHERE performance_rank <= 2
GROUP BY department_id
ORDER BY department_id;


-- =====================================================
-- INTERVIEW NOTES
-- =====================================================

/*
Important:
1. ROW_NUMBER() returns a unique position.

2. RANK() handles ties and skips ranks.

3. DENSE_RANK() handles ties without
   skipping rank values.

4. PARTITION BY restarts ranking
   within each department.

5. Use CTEs or derived tables to filter
   the result of window functions.

6. For exactly N rows per group, use
   ROW_NUMBER() with deterministic ordering.

7. To include tied employees, use
   RANK() or DENSE_RANK() depending
   on the required interpretation.

8. Correlated subqueries can also
   solve Top N per Group problems.

9. Always clarify whether the interviewer
   wants N rows, N ranking positions,
   or N distinct score levels.

Complexity:
Window-function approaches typically
involve sorting records within groups.

Without suitable indexes, sorting commonly
requires O(n log n) time.

Memory usage and actual performance
depend on the database execution plan.
*/
