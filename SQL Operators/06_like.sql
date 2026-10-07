```sql
/*
    SQL Journey
    Part 02: SQL Operators

    File: 06_like.sql
    Topic: LIKE Operator

    Description:
    LIKE is used for pattern matching.

    Wildcards:
    % = zero or more characters
    _ = exactly one character
*/

USE sql_journey;

-- Names starting with 'A'.
SELECT
    employee_name
FROM employees
WHERE employee_name LIKE 'A%';

-- Names ending with 'a'.
SELECT
    employee_name
FROM employees
WHERE employee_name LIKE '%a';

-- Names containing 'an'.
SELECT
    employee_name
FROM employees
WHERE employee_name LIKE '%an%';

-- Job titles containing 'Manager'.
SELECT
    employee_name,
    job_title
FROM employees
WHERE job_title LIKE '%Manager%';

-- Names where the second character is 'r'.
SELECT
    employee_name
FROM employees
WHERE employee_name LIKE '_r%';
```
