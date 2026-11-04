
/*
========================================================
    SQL JOURNEY
    Module 12: SQL Interview Problems
    File: 04_employees_above_average.sql
    Problem: Employees Above Average Salary
    Difficulty: Medium
========================================================

Problem Statement:
Find employees earning more than the average
salary of the company or their department.

Concepts Covered:
1. AVG()
2. Scalar subqueries
3. CTEs
4. Correlated subqueries
5. JOIN
6. GROUP BY
7. Window functions
8. Salary comparison reports

Database: MySQL 8.0+

========================================================
*/

USE sql_journey;


-- =====================================================
-- APPROACH 1: COMPANY AVERAGE
-- =====================================================

-- Find employees earning more than
-- the overall company average salary.

SELECT
    employee_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary DESC;


-- =====================================================
-- APPROACH 2: CTE WITH COMPANY AVERAGE
-- =====================================================

WITH company_average AS (
    SELECT AVG(salary) AS average_salary
    FROM employees
)
SELECT
    e.employee_name,
    e.salary,
    ROUND(c.average_salary, 2)
        AS company_average
FROM employees AS e
CROSS JOIN company_average AS c
WHERE e.salary > c.average_salary
ORDER BY e.salary DESC;


-- =====================================================
-- APPROACH 3: DEPARTMENT AVERAGE
-- =====================================================

-- Find employees earning more than
-- the average salary of their department.

SELECT
    e.employee_name,
    e.department_id,
    e.salary
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.department_id, e.salary DESC;


-- =====================================================
-- APPROACH 4: CTE WITH DEPARTMENT AVERAGES
-- =====================================================

WITH department_averages AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    e.employee_name,
    e.salary,
    d.department_name,
    ROUND(a.average_salary, 2)
        AS department_average
FROM employees AS e
INNER JOIN department_averages AS a
    ON e.department_id = a.department_id
INNER JOIN departments AS d
    ON e.department_id = d.department_id
WHERE e.salary > a.average_salary
ORDER BY d.department_id, e.salary DESC;


-- =====================================================
-- APPROACH 5: WINDOW FUNCTION
-- =====================================================

-- Calculate the department average alongside
-- each employee's salary, then filter.

WITH salary_analysis AS (
    SELECT
        employee_name,
        department_id,
        salary,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS department_average
    FROM employees
)
SELECT
    employee_name,
    department_id,
    salary,
    ROUND(department_average, 2)
        AS department_average
FROM salary_analysis
WHERE salary > department_average
ORDER BY department_id, salary DESC;


-- =====================================================
-- APPROACH 6: PERCENTAGE ABOVE AVERAGE
-- =====================================================

WITH department_averages AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    e.employee_name,
    e.salary,
    ROUND(a.average_salary, 2)
        AS department_average,

    ROUND(
        (
            e.salary - a.average_salary
        ) * 100.0 /
        NULLIF(a.average_salary, 0),
        2
    ) AS percentage_above_average

FROM employees AS e
INNER JOIN department_averages AS a
    ON e.department_id = a.department_id

WHERE e.salary > a.average_salary
ORDER BY percentage_above_average DESC;


-- =====================================================
-- APPROACH 7: COUNT ABOVE-AVERAGE EMPLOYEES
-- =====================================================

WITH salary_analysis AS (
    SELECT
        employee_id,
        department_id,
        salary,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS department_average
    FROM employees
)
SELECT
    department_id,
    COUNT(*) AS above_average_employees
FROM salary_analysis
WHERE salary > department_average
GROUP BY department_id
ORDER BY department_id;


-- =====================================================
-- APPROACH 8: CLASSIFY EMPLOYEE SALARIES
-- =====================================================

WITH company_average AS (
    SELECT AVG(salary) AS average_salary
    FROM employees
)
SELECT
    e.employee_name,
    e.salary,
    CASE
        WHEN e.salary > c.average_salary
            THEN 'Above Average'
        WHEN e.salary < c.average_salary
            THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS salary_status
FROM employees AS e
CROSS JOIN company_average AS c
ORDER BY e.salary DESC;


-- =====================================================
-- INTERVIEW NOTES
-- =====================================================

/*
Important:
- AVG() ignores NULL salary values.
- A scalar subquery calculates a single
  comparison value.
- A correlated subquery can calculate
  a separate average for each department.
- CTEs can make complex queries easier to read.
- Window functions preserve employee rows.
- NULLIF() prevents division by zero.

Performance:
Avoid repeating expensive calculations
unnecessarily when analyzing large tables.

Use EXPLAIN to inspect actual execution plans.
*/
