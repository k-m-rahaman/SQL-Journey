
/*
========================================================
    SQL JOURNEY
    Module 11: Database Design & Normalization
    File: 02NF.sql
    Topic: Second Normal Form (2NF)
========================================================

Description:
Second Normal Form requires:
1. The table must satisfy 1NF.
2. Non-key attributes must depend on
   the entire candidate key.
3. Partial dependencies must be removed.

Concepts Covered:
1. Composite primary keys
2. Functional dependencies
3. Partial dependencies
4. Splitting related information
5. Foreign key relationships
6. Student-course enrollment design

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: DESIGN VIOLATING 2NF
-- =====================================================

-- 1. Reset demonstration tables.
DROP TABLE IF EXISTS demo_2nf_enrollments;
DROP TABLE IF EXISTS demo_2nf_students;
DROP TABLE IF EXISTS demo_2nf_courses;
DROP TABLE IF EXISTS demo_2nf_bad_enrollments;

-- 2. Create a table with a composite primary key.
CREATE TABLE demo_2nf_bad_enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    marks INT,

    PRIMARY KEY (student_id, course_id)
);

-- 3. Insert student enrollment records.
INSERT INTO demo_2nf_bad_enrollments VALUES
    (101, 201, 'Arjun Sharma', 'SQL', 90),
    (101, 202, 'Arjun Sharma', 'Python', 85),
    (102, 201, 'Priya Das', 'SQL', 95),
    (102, 203, 'Priya Das', 'Java', 88),
    (103, 202, 'Rahul Sen', 'Python', 78),
    (103, 203, 'Rahul Sen', 'Java', 82);

-- 4. Display the records.
SELECT *
FROM demo_2nf_bad_enrollments
ORDER BY student_id, course_id;

-- Functional Dependencies:
--
-- student_id -> student_name
-- course_id -> course_name
-- (student_id, course_id) -> marks
--
-- The composite primary key is:
-- (student_id, course_id)
--
-- Problem:
-- student_name depends only on student_id.
-- course_name depends only on course_id.
--
-- These are partial dependencies.
-- Therefore, this design violates 2NF.


-- =====================================================
-- SECTION 2: SECOND NORMAL FORM
-- =====================================================

-- 5. Create a separate students table.
CREATE TABLE demo_2nf_students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

-- 6. Create a separate courses table.
CREATE TABLE demo_2nf_courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);

-- 7. Create a student-course relationship table.
CREATE TABLE demo_2nf_enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    marks INT,

    PRIMARY KEY (student_id, course_id),

    FOREIGN KEY (student_id)
        REFERENCES demo_2nf_students(student_id),

    FOREIGN KEY (course_id)
        REFERENCES demo_2nf_courses(course_id),

    CHECK (marks BETWEEN 0 AND 100)
);

-- 8. Insert unique students.
INSERT INTO demo_2nf_students
SELECT DISTINCT
    student_id,
    student_name
FROM demo_2nf_bad_enrollments;

-- 9. Insert unique courses.
INSERT INTO demo_2nf_courses
SELECT DISTINCT
    course_id,
    course_name
FROM demo_2nf_bad_enrollments;

-- 10. Insert student enrollments.
INSERT INTO demo_2nf_enrollments
SELECT
    student_id,
    course_id,
    marks
FROM demo_2nf_bad_enrollments;


-- =====================================================
-- SECTION 3: QUERY THE 2NF DESIGN
-- =====================================================

-- 11. Display students.
SELECT *
FROM demo_2nf_students
ORDER BY student_id;

-- 12. Display courses.
SELECT *
FROM demo_2nf_courses
ORDER BY course_id;

-- 13. Display enrollments.
SELECT *
FROM demo_2nf_enrollments
ORDER BY student_id, course_id;

-- 14. Reconstruct the complete enrollment report.
SELECT
    s.student_id,
    s.student_name,
    c.course_id,
    c.course_name,
    e.marks
FROM demo_2nf_enrollments AS e
INNER JOIN demo_2nf_students AS s
    ON e.student_id = s.student_id
INNER JOIN demo_2nf_courses AS c
    ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_id;

-- 15. Calculate average marks per course.
SELECT
    c.course_name,
    ROUND(AVG(e.marks), 2) AS average_marks
FROM demo_2nf_courses AS c
INNER JOIN demo_2nf_enrollments AS e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY average_marks DESC;

-- 16. Count enrollments per student.
SELECT
    s.student_name,
    COUNT(e.course_id) AS total_courses
FROM demo_2nf_students AS s
LEFT JOIN demo_2nf_enrollments AS e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name
ORDER BY s.student_id;

-- 17. Demonstrate updating one student record.
-- No changes to enrollment rows are needed.
UPDATE demo_2nf_students
SET student_name = 'Arjun Kumar Sharma'
WHERE student_id = 101;

-- 18. Verify the change across the joined report.
SELECT
    s.student_name,
    c.course_name,
    e.marks
FROM demo_2nf_enrollments AS e
INNER JOIN demo_2nf_students AS s
    ON e.student_id = s.student_id
INNER JOIN demo_2nf_courses AS c
    ON e.course_id = c.course_id
WHERE s.student_id = 101;

-- 19. Inspect the normalized schema.
SHOW CREATE TABLE demo_2nf_enrollments;

-- Important:
-- In the 2NF design:
--
-- student_name depends on student_id.
-- course_name depends on course_id.
-- marks depends on the complete
-- (student_id, course_id) relationship.
--
-- No non-key attribute in the enrollment
-- table depends on only part of its key.
--
-- A table with a single-column candidate
-- key cannot have a partial dependency
-- on part of that key.
