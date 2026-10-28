
/*
========================================================
    SQL JOURNEY
    Module 09: Advanced SQL
    File: 05_transactions.sql
    Topic: Database Transactions
========================================================

Description:
Transactions group multiple SQL operations
into a single logical unit.

They help maintain database consistency
when performing related operations.

Concepts Covered:
1. START TRANSACTION
2. COMMIT
3. ROLLBACK
4. SAVEPOINT
5. ROLLBACK TO SAVEPOINT
6. RELEASE SAVEPOINT
7. ACID properties
8. Bank account transfer examples

========================================================
*/

USE sql_journey;

-- 1. Remove the previous demonstration table.
DROP TABLE IF EXISTS demo_bank_accounts;

-- 2. Create a bank accounts table.
-- InnoDB supports transactional operations.
CREATE TABLE demo_bank_accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    balance DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_demo_nonnegative_balance
        CHECK (balance >= 0)
) ENGINE = InnoDB;

-- 3. Insert sample bank accounts.
INSERT INTO demo_bank_accounts
    (account_id, account_holder, balance)
VALUES
    (101, 'Arjun Sharma', 10000.00),
    (102, 'Priya Das', 5000.00);

-- 4. Display initial balances.
SELECT *
FROM demo_bank_accounts
ORDER BY account_id;

-- 5. Calculate total available money.
SELECT
    SUM(balance) AS total_money
FROM demo_bank_accounts;

-- =====================================================
-- EXAMPLE 1: ROLLBACK
-- =====================================================

-- 6. Begin a transaction.
START TRANSACTION;

-- 7. Deduct 1000 from account 101.
UPDATE demo_bank_accounts
SET balance = balance - 1000
WHERE account_id = 101;

-- 8. Add 1000 to account 102.
UPDATE demo_bank_accounts
SET balance = balance + 1000
WHERE account_id = 102;

-- 9. Display temporary balances.
SELECT *
FROM demo_bank_accounts
ORDER BY account_id;

-- 10. Cancel the complete transaction.
ROLLBACK;

-- 11. Verify that balances are restored.
SELECT *
FROM demo_bank_accounts
ORDER BY account_id;

-- =====================================================
-- EXAMPLE 2: COMMIT
-- =====================================================

-- 12. Begin a new transaction.
START TRANSACTION;

-- 13. Transfer 2000 from account 101
-- to account 102.
UPDATE demo_bank_accounts
SET balance = balance - 2000
WHERE account_id = 101
  AND balance >= 2000;

UPDATE demo_bank_accounts
SET balance = balance + 2000
WHERE account_id = 102;

-- 14. Save the transaction permanently.
COMMIT;

-- 15. Display updated balances.
SELECT *
FROM demo_bank_accounts
ORDER BY account_id;

-- 16. Verify that total money is unchanged.
SELECT
    SUM(balance) AS total_money_after_transfer
FROM demo_bank_accounts;

-- =====================================================
-- EXAMPLE 3: SAVEPOINT
-- =====================================================

-- 17. Begin another transaction.
START TRANSACTION;

-- 18. Transfer 500 from account 101
-- to account 102.
UPDATE demo_bank_accounts
SET balance = balance - 500
WHERE account_id = 101
  AND balance >= 500;

UPDATE demo_bank_accounts
SET balance = balance + 500
WHERE account_id = 102;

-- 19. Create a SAVEPOINT.
SAVEPOINT after_first_transfer;

-- 20. Perform another transfer of 250.
UPDATE demo_bank_accounts
SET balance = balance - 250
WHERE account_id = 101
  AND balance >= 250;

UPDATE demo_bank_accounts
SET balance = balance + 250
WHERE account_id = 102;

-- 21. View temporary balances.
SELECT *
FROM demo_bank_accounts
ORDER BY account_id;

-- 22. Undo only the second transfer.
ROLLBACK TO SAVEPOINT after_first_transfer;

-- 23. View balances after partial rollback.
SELECT *
FROM demo_bank_accounts
ORDER BY account_id;

-- 24. Remove the savepoint.
RELEASE SAVEPOINT after_first_transfer;

-- 25. Commit the remaining changes.
COMMIT;

-- 26. Display final balances.
SELECT
    account_id,
    account_holder,
    balance
FROM demo_bank_accounts
ORDER BY account_id;

-- 27. Verify the final total.
SELECT
    SUM(balance) AS final_total_money
FROM demo_bank_accounts;

-- =====================================================
-- ACID PROPERTIES
-- =====================================================

/*
ATOMICITY:
All operations in a transaction are treated
as one logical unit.

CONSISTENCY:
Transactions should preserve valid database
rules and constraints.

ISOLATION:
Concurrent transactions have defined
visibility and interaction rules.

DURABILITY:
Committed changes survive system failures
under the database engine's durability guarantees.
*/

-- Important:
-- This is a controlled educational example
-- using known account IDs and balances.
--
-- Production banking transfers must check
-- affected rows, handle failures, manage
-- concurrency, and ROLLBACK when required.
--
-- Never assume that a conditional UPDATE
-- succeeded without checking its result.
--
-- CREATE TABLE and DROP TABLE statements
-- cause implicit commits in MySQL.
-- Keep DDL outside transaction demonstrations.
