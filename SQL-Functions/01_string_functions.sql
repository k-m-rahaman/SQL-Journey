
/*
========================================================
    SQL JOURNEY
    Module 04: SQL Functions
    File: 01_string_functions.sql
    Topic: String Functions
========================================================

Description:
String functions help manipulate and process
text stored in database columns.

Functions Covered:
1. UPPER()
2. LOWER()
3. LENGTH()
4. CHAR_LENGTH()
5. CONCAT()
6. CONCAT_WS()
7. SUBSTRING()
8. TRIM()
9. REPLACE()

========================================================
*/

USE sql_journey;

-- 1. UPPER()
-- Convert employee names to uppercase.
SELECT
    employee_name,
    UPPER(employee_name) AS uppercase_name
FROM employees;

-- 2. LOWER()
-- Convert job titles to lowercase.
SELECT
    job_title,
    LOWER(job_title) AS lowercase_title
FROM employees;

-- 3. LENGTH()
-- Calculate the length of text in bytes.
SELECT
    employee_name,
    LENGTH(employee_name) AS name_length_bytes
FROM employees;

-- 4. CHAR_LENGTH()
-- Count the number of characters.
SELECT
    employee_name,
    CHAR_LENGTH(employee_name) AS character_count
FROM employees;

-- 5. CONCAT()
-- Combine employee names and job titles.
SELECT
    CONCAT(
        employee_name,
        ' - ',
        job_title
    ) AS employee_details
FROM employees;

-- 6. CONCAT_WS()
-- Combine multiple strings using a separator.
SELECT
    CONCAT_WS(
        ' | ',
        employee_name,
        job_title,
        department_id
    ) AS employee_information
FROM employees;

-- 7. SUBSTRING()
-- Extract the first five characters of a name.
SELECT
    employee_name,
    SUBSTRING(employee_name, 1, 5) AS short_name
FROM employees;

-- 8. TRIM()
-- Remove unnecessary spaces from text.
SELECT
    TRIM('   SQL Journey   ') AS clean_text;

-- 9. REPLACE()
-- Replace a word within a string.
SELECT
    job_title,
    REPLACE(
        job_title,
        'Engineer',
        'Developer'
    ) AS updated_title
FROM employees;

-- 10. Practical example
-- Generate a formatted employee description.
SELECT
    employee_id,
    CONCAT(
        UPPER(employee_name),
        ' works as ',
        LOWER(job_title)
    ) AS employee_summary
FROM employees;
