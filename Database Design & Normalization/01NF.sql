
/*
========================================================
    SQL JOURNEY
    Module 11: Database Design & Normalization
    File: 01NF.sql
    Topic: First Normal Form (1NF)
========================================================

Description:
First Normal Form requires:
1. Atomic values in every field
2. No repeating groups
3. Identifiable rows
4. Consistent column meanings

Concepts Covered:
1. Unnormalized course lists
2. Atomic attribute values
3. Converting lists into separate rows
4. Composite primary keys
5. Querying normalized enrollments

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: NON-1NF DESIGN
-- =====================================================

-- 1. Reset demonstration tables.
DROP TABLE IF EXISTS demo_1nf_enrollments;
DROP TABLE IF EXISTS demo_1nf_bad_students;

-- 2. Create a table with multiple
-- course names stored in one field.
CREATE TABLE demo_1nf_bad_students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    courses VARCHAR(255)
);

-- 3. Insert sample records.
INSERT INTO demo_1nf_bad_students VALUES
    (101, 'Arjun Sharma', 'SQL,Python,DBMS'),
    (102, 'Priya Das', 'SQL,Java'),
    (103, 'Rahul Sen', 'Python,DBMS'),
    (104, 'Sneha Roy', 'SQL,Python,Java');

-- 4. Display the problematic structure.
SELECT *
FROM demo_1nf_bad_students;

-- Problem:
-- The courses column contains several
-- independent course values.
--
-- Individual courses are difficult
-- to validate, update, or query reliably.
--
-- This design treats a collection of
-- course names as a single attribute.


-- =====================================================
-- SECTION 2: FIRST NORMAL FORM
-- =====================================================

-- 5. Create an atomic enrollment table.
-- Every row represents one student-course pair.
CREATE TABLE demo_1nf_enrollments (
    student_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    course_name VARCHAR(100) NOT NULL,

    PRIMARY KEY (student_id, course_name)
);

-- 6. Insert atomic enrollment records.
INSERT INTO demo_1nf_enrollments VALUES
    (101, 'Arjun Sharma', 'SQL'),
    (101, 'Arjun Sharma', 'Python'),
    (101, 'Arjun Sharma', 'DBMS'),

    (102, 'Priya Das', 'SQL'),
    (102, 'Priya Das', 'Java'),

    (103, 'Rahul Sen', 'Python'),
    (103, 'Rahul Sen', 'DBMS'),

    (104, 'Sneha Roy', 'SQL'),
    (104, 'Sneha Roy', 'Python'),
    (104, 'Sneha Roy', 'Java');

-- 7. Display the normalized records.
SELECT *
FROM demo_1nf_enrollments
ORDER BY student_id, course_name;

-- 8. Find all students enrolled in SQL.
SELECT
    student_id,
    student_name
FROM demo_1nf_enrollments
WHERE course_name = 'SQL';

-- 9. Count students enrolled in each course.
SELECT
    course_name,
    COUNT(*) AS total_students
FROM demo_1nf_enrollments
GROUP BY course_name
ORDER BY total_students DESC, course_name;

-- 10. Count courses for each student.
SELECT
    student_id,
    student_name,
    COUNT(*) AS total_courses
FROM demo_1nf_enrollments
GROUP BY student_id, student_name
ORDER BY student_id;

-- 11. Find students enrolled in at least
-- three courses.
SELECT
    student_id,
    student_name,
    COUNT(*) AS course_count
FROM demo_1nf_enrollments
GROUP BY student_id, student_name
HAVING COUNT(*) >= 3;

-- 12. Display the primary key structure.
SHOW CREATE TABLE demo_1nf_enrollments;

-- Important:
-- Each course is now stored separately.
--
-- The composite key identifies each
-- student-course enrollment.
--
-- However, student_name is still repeated
-- for different courses.
--
-- This table satisfies the illustrated
-- 1NF requirements but still has a partial
-- dependency and is not in 2NF.
