
/*
========================================================
    SQL JOURNEY
    Module 12: SQL Interview Problems
    File: 05_consecutive_dates.sql
    Problem: Consecutive Dates
    Difficulty: Hard
========================================================

Problem Statement:
Find users with activity on at least
three consecutive calendar days.

Concepts Covered:
1. Date functions
2. DISTINCT
3. LAG()
4. ROW_NUMBER()
5. CTEs
6. DATE_SUB()
7. DATEDIFF()
8. GROUP BY and HAVING
9. Gaps and Islands
10. Longest activity streak

Database: MySQL 8.0+

========================================================
*/

USE sql_journey;

-- =====================================================
-- SECTION 1: DEMONSTRATION DATA
-- =====================================================

-- 1. Reset the activity table.
DROP TABLE IF EXISTS demo_interview_activity;

-- 2. Create the activity table.
CREATE TABLE demo_interview_activity (
    activity_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    activity_date DATE NOT NULL
);

-- 3. Insert activity records.
-- Some users have consecutive dates.
-- Some users have gaps between dates.

INSERT INTO demo_interview_activity
    (activity_id, user_id, activity_date)
VALUES
    (1, 101, '2026-10-01'),
    (2, 101, '2026-10-02'),
    (3, 101, '2026-10-03'),
    (4, 101, '2026-10-05'),
    (5, 101, '2026-10-06'),

    (6, 102, '2026-10-01'),
    (7, 102, '2026-10-03'),
    (8, 102, '2026-10-04'),
    (9, 102, '2026-10-05'),

    (10, 103, '2026-10-08'),
    (11, 103, '2026-10-09'),
    (12, 103, '2026-10-10'),
    (13, 103, '2026-10-10'),

    (14, 104, '2026-10-04');

-- User 103 has two events on the same day.
-- The duplicate date must count as one day.

-- 4. Display all activity records.
SELECT *
FROM demo_interview_activity
ORDER BY user_id, activity_date, activity_id;


-- =====================================================
-- APPROACH 1: FIND DISTINCT ACTIVE DAYS
-- =====================================================

-- Count unique active dates for each user.

SELECT
    user_id,
    COUNT(DISTINCT activity_date)
        AS total_active_days
FROM demo_interview_activity
GROUP BY user_id
ORDER BY user_id;


-- =====================================================
-- APPROACH 2: LAG() TO DETECT CONSECUTIVE DAYS
-- =====================================================

WITH unique_days AS (
    SELECT DISTINCT
        user_id,
        activity_date
    FROM demo_interview_activity
),
activity_history AS (
    SELECT
        user_id,
        activity_date,
        LAG(activity_date) OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS previous_date
    FROM unique_days
)
SELECT
    user_id,
    activity_date,
    previous_date,
    CASE
        WHEN DATEDIFF(
            activity_date,
            previous_date
        ) = 1
            THEN 'Consecutive'
        ELSE 'New Streak'
    END AS activity_status
FROM activity_history
ORDER BY user_id, activity_date;


-- =====================================================
-- APPROACH 3: GAPS AND ISLANDS
-- =====================================================

-- Consecutive dates produce the same
-- grouping date when ROW_NUMBER()
-- is subtracted from each activity date.

WITH unique_days AS (
    SELECT DISTINCT
        user_id,
        activity_date
    FROM demo_interview_activity
),
numbered_days AS (
    SELECT
        user_id,
        activity_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS day_number
    FROM unique_days
),
grouped_days AS (
    SELECT
        user_id,
        activity_date,
        DATE_SUB(
            activity_date,
            INTERVAL day_number DAY
        ) AS streak_group
    FROM numbered_days
)
SELECT
    user_id,
    MIN(activity_date) AS streak_start,
    MAX(activity_date) AS streak_end,
    COUNT(*) AS consecutive_days
FROM grouped_days
GROUP BY user_id, streak_group
ORDER BY user_id, streak_start;


-- =====================================================
-- APPROACH 4: FIND STREAKS OF AT LEAST 3 DAYS
-- =====================================================

WITH unique_days AS (
    SELECT DISTINCT
        user_id,
        activity_date
    FROM demo_interview_activity
),
numbered_days AS (
    SELECT
        user_id,
        activity_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS day_number
    FROM unique_days
),
grouped_days AS (
    SELECT
        user_id,
        activity_date,
        DATE_SUB(
            activity_date,
            INTERVAL day_number DAY
        ) AS streak_group
    FROM numbered_days
)
SELECT
    user_id,
    MIN(activity_date) AS streak_start,
    MAX(activity_date) AS streak_end,
    COUNT(*) AS consecutive_days
FROM grouped_days
GROUP BY user_id, streak_group
HAVING COUNT(*) >= 3
ORDER BY user_id, streak_start;


-- =====================================================
-- APPROACH 5: LONGEST STREAK FOR EACH USER
-- =====================================================

WITH unique_days AS (
    SELECT DISTINCT
        user_id,
        activity_date
    FROM demo_interview_activity
),
numbered_days AS (
    SELECT
        user_id,
        activity_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS day_number
    FROM unique_days
),
grouped_days AS (
    SELECT
        user_id,
        activity_date,
        DATE_SUB(
            activity_date,
            INTERVAL day_number DAY
        ) AS streak_group
    FROM numbered_days
),
streaks AS (
    SELECT
        user_id,
        MIN(activity_date) AS streak_start,
        MAX(activity_date) AS streak_end,
        COUNT(*) AS consecutive_days
    FROM grouped_days
    GROUP BY user_id, streak_group
),
ranked_streaks AS (
    SELECT
        user_id,
        streak_start,
        streak_end,
        consecutive_days,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY consecutive_days DESC,
                     streak_start ASC
        ) AS streak_rank
    FROM streaks
)
SELECT
    user_id,
    streak_start,
    streak_end,
    consecutive_days
FROM ranked_streaks
WHERE streak_rank = 1
ORDER BY consecutive_days DESC, user_id;


-- =====================================================
-- APPROACH 6: SELF JOIN FOR 3-DAY SEQUENCES
-- =====================================================

-- Find the starting dates of any
-- three-day consecutive activity sequence.

WITH unique_days AS (
    SELECT DISTINCT
        user_id,
        activity_date
    FROM demo_interview_activity
)
SELECT
    a.user_id,
    a.activity_date AS first_day,
    b.activity_date AS second_day,
    c.activity_date AS third_day
FROM unique_days AS a
INNER JOIN unique_days AS b
    ON a.user_id = b.user_id
   AND b.activity_date = DATE_ADD(
       a.activity_date,
       INTERVAL 1 DAY
   )
INNER JOIN unique_days AS c
    ON a.user_id = c.user_id
   AND c.activity_date = DATE_ADD(
       a.activity_date,
       INTERVAL 2 DAY
   )
ORDER BY a.user_id, a.activity_date;


-- =====================================================
-- APPROACH 7: IDENTIFY GAPS BETWEEN ACTIVE DAYS
-- =====================================================

WITH unique_days AS (
    SELECT DISTINCT
        user_id,
        activity_date
    FROM demo_interview_activity
),
activity_history AS (
    SELECT
        user_id,
        activity_date,
        LAG(activity_date) OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS previous_date
    FROM unique_days
)
SELECT
    user_id,
    previous_date,
    activity_date,
    DATEDIFF(
        activity_date,
        previous_date
    ) - 1 AS inactive_days_between
FROM activity_history
WHERE DATEDIFF(
    activity_date,
    previous_date
) > 1
ORDER BY user_id, activity_date;


-- =====================================================
-- INTERVIEW NOTES
-- =====================================================

/*
Important:
- Remove duplicate user-date combinations
  before calculating streaks.
- LAG() helps identify previous dates.
- ROW_NUMBER() creates a sequential position.
- Consecutive dates share a stable group key
  when their row numbers are subtracted.
- GROUP BY identifies each continuous streak.
- HAVING filters streaks by length.
- The approach handles multiple activity
  streaks belonging to the same user.

Complexity:
Sorting activity dates generally requires
O(n log n) work without a suitable index.
Window calculations then process the
ordered records.
*/
