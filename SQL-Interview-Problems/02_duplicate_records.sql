
/*
========================================================
    SQL JOURNEY
    Module 12: SQL Interview Problems
    File: 02_duplicate_records.sql
    Problem: Find Duplicate Records
    Difficulty: Easy to Medium
========================================================

Problem Statement:
Identify duplicate records in a table.

Concepts Covered:
1. GROUP BY
2. COUNT()
3. HAVING
4. LOWER()
5. TRIM()
6. Subqueries
7. CTEs
8. ROW_NUMBER()
9. Removing duplicates from query results

Database: MySQL 8.0+

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: DEMONSTRATION DATABASE
-- =====================================================

-- 1. Remove the previous demo table.
DROP TABLE IF EXISTS demo_interview_contacts;

-- 2. Create a contacts table.
CREATE TABLE demo_interview_contacts (
    contact_id INT PRIMARY KEY,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL
);

-- 3. Insert sample records.
-- Some emails intentionally repeat.

INSERT INTO demo_interview_contacts
    (contact_id, contact_name, email)
VALUES
    (1, 'Arjun Sharma', 'arjun@example.com'),
    (2, 'Priya Das', 'priya@example.com'),
    (3, 'Arjun S', 'ARJUN@example.com'),
    (4, 'Rahul Sen', 'rahul@example.com'),
    (5, 'Priya D', ' priya@example.com '),
    (6, 'Sneha Roy', 'sneha@example.com'),
    (7, 'Arjun Kumar', 'arjun@example.com'),
    (8, 'Ishita Paul', 'ishita@example.com');

-- 4. Display the complete dataset.
SELECT *
FROM demo_interview_contacts
ORDER BY contact_id;


-- =====================================================
-- APPROACH 1: GROUP BY WITH HAVING
-- =====================================================

-- Identify duplicate emails.
-- Convert to lowercase and remove
-- surrounding whitespace before comparing.

SELECT
    LOWER(TRIM(email)) AS normalized_email,
    COUNT(*) AS occurrence_count
FROM demo_interview_contacts
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC, normalized_email;


-- =====================================================
-- APPROACH 2: DISPLAY ALL DUPLICATE RECORDS
-- =====================================================

WITH duplicate_emails AS (
    SELECT
        LOWER(TRIM(email)) AS normalized_email
    FROM demo_interview_contacts
    GROUP BY LOWER(TRIM(email))
    HAVING COUNT(*) > 1
)
SELECT
    c.contact_id,
    c.contact_name,
    c.email
FROM demo_interview_contacts AS c
INNER JOIN duplicate_emails AS d
    ON LOWER(TRIM(c.email)) = d.normalized_email
ORDER BY LOWER(TRIM(c.email)), c.contact_id;


-- =====================================================
-- APPROACH 3: ROW_NUMBER()
-- =====================================================

-- Assign a sequence to records sharing
-- the same normalized email.

WITH numbered_contacts AS (
    SELECT
        contact_id,
        contact_name,
        email,

        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(email))
            ORDER BY contact_id
        ) AS duplicate_number

    FROM demo_interview_contacts
)
SELECT *
FROM numbered_contacts
ORDER BY LOWER(TRIM(email)), duplicate_number;


-- =====================================================
-- APPROACH 4: FIND EXTRA DUPLICATE RECORDS
-- =====================================================

-- Identify records beyond the first
-- occurrence of each email.

WITH numbered_contacts AS (
    SELECT
        contact_id,
        contact_name,
        email,

        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(email))
            ORDER BY contact_id
        ) AS row_num

    FROM demo_interview_contacts
)
SELECT
    contact_id,
    contact_name,
    email
FROM numbered_contacts
WHERE row_num > 1
ORDER BY contact_id;


-- =====================================================
-- APPROACH 5: SELECT ONE RECORD PER EMAIL
-- =====================================================

-- Return only the first contact for
-- each normalized email address.

WITH numbered_contacts AS (
    SELECT
        contact_id,
        contact_name,
        email,

        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(email))
            ORDER BY contact_id
        ) AS row_num

    FROM demo_interview_contacts
)
SELECT
    contact_id,
    contact_name,
    LOWER(TRIM(email)) AS normalized_email
FROM numbered_contacts
WHERE row_num = 1
ORDER BY contact_id;

-- No records are deleted by this query.


-- =====================================================
-- APPROACH 6: COUNT TOTAL EXTRA DUPLICATES
-- =====================================================

WITH email_counts AS (
    SELECT
        LOWER(TRIM(email)) AS normalized_email,
        COUNT(*) AS total_records
    FROM demo_interview_contacts
    GROUP BY LOWER(TRIM(email))
)
SELECT
    COALESCE(
        SUM(total_records - 1),
        0
    ) AS extra_duplicate_records
FROM email_counts;


-- =====================================================
-- APPROACH 7: COUNT UNIQUE EMAIL ADDRESSES
-- =====================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(
        DISTINCT LOWER(TRIM(email))
    ) AS unique_emails
FROM demo_interview_contacts;


-- =====================================================
-- APPROACH 8: PREVENT FUTURE DUPLICATES
-- =====================================================

-- For MySQL 8.0.13+, a functional UNIQUE index
-- can enforce uniqueness on normalized emails.
--
-- Before creating it, existing duplicates
-- must be resolved safely.
--
-- Example (intentionally not executed):
--
-- CREATE UNIQUE INDEX idx_normalized_email
-- ON demo_interview_contacts (
--     (LOWER(TRIM(email)))
-- );


-- =====================================================
-- INTERVIEW NOTES
-- =====================================================

/*
Important:
- GROUP BY groups matching values.
- HAVING COUNT(*) > 1 identifies duplicates.
- ROW_NUMBER() distinguishes individual
  records inside duplicate groups.
- TRIM removes leading/trailing spaces.
- LOWER handles case differences.
- Do not delete duplicate records blindly.
- First determine which record must be kept.
- A UNIQUE constraint or index helps
  prevent future duplicate values.

Approximate complexity:
GROUP BY depends on indexes and execution plan.
ROW_NUMBER() often requires sorting and may
take O(n log n) time without suitable indexing.
*/
