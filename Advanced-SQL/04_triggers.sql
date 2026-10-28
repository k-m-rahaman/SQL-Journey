
/*
========================================================
    SQL JOURNEY
    Module 09: Advanced SQL
    File: 04_triggers.sql
    Topic: Database Triggers
========================================================

Description:
Triggers automatically execute SQL statements
when database records are modified.

This demonstration creates an employee audit
system to track database changes.

Concepts Covered:
1. CREATE TRIGGER
2. AFTER INSERT
3. AFTER UPDATE
4. AFTER DELETE
5. OLD and NEW keywords
6. Audit logging
7. DROP TRIGGER
8. SHOW TRIGGERS

========================================================
*/

USE sql_journey;

-- 1. Remove existing demonstration triggers.
DROP TRIGGER IF EXISTS trg_demo_after_insert;
DROP TRIGGER IF EXISTS trg_demo_after_update;
DROP TRIGGER IF EXISTS trg_demo_after_delete;

-- 2. Remove demonstration tables.
DROP TABLE IF EXISTS demo_trigger_audit;
DROP TABLE IF EXISTS demo_trigger_employees;

-- 3. Create the employee table.
CREATE TABLE demo_trigger_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_id INT,
    CONSTRAINT chk_demo_trigger_salary
        CHECK (salary >= 0)
) ENGINE = InnoDB;

-- 4. Create an audit log table.
CREATE TABLE demo_trigger_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    action_description VARCHAR(255),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 5. Change the delimiter.
DELIMITER $$

-- 6. AFTER INSERT trigger.
-- Automatically log every new employee.
CREATE TRIGGER trg_demo_after_insert
AFTER INSERT ON demo_trigger_employees
FOR EACH ROW
BEGIN
    INSERT INTO demo_trigger_audit (
        employee_id,
        action_type,
        old_salary,
        new_salary,
        action_description
    )
    VALUES (
        NEW.employee_id,
        'INSERT',
        NULL,
        NEW.salary,
        'New employee record created'
    );
END$$

-- 7. AFTER UPDATE trigger.
-- Log changes when an employee's salary changes.
CREATE TRIGGER trg_demo_after_update
AFTER UPDATE ON demo_trigger_employees
FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN

        INSERT INTO demo_trigger_audit (
            employee_id,
            action_type,
            old_salary,
            new_salary,
            action_description
        )
        VALUES (
            NEW.employee_id,
            'UPDATE',
            OLD.salary,
            NEW.salary,
            'Employee salary updated'
        );
    END IF;
END$$

-- 8. AFTER DELETE trigger.
-- Automatically log deleted employee records.
CREATE TRIGGER trg_demo_after_delete
AFTER DELETE ON demo_trigger_employees
FOR EACH ROW
BEGIN
    INSERT INTO demo_trigger_audit (
        employee_id,
        action_type,
        old_salary,
        new_salary,
        action_description
    )
    VALUES (
        OLD.employee_id,
        'DELETE',
        OLD.salary,
        NULL,
        'Employee record deleted'
    );
END$$

-- 9. Restore the delimiter.
DELIMITER ;

-- 10. Insert employees.
-- The INSERT trigger runs automatically.
INSERT INTO demo_trigger_employees
    (employee_id, employee_name, salary, department_id)
VALUES
    (101, 'Arjun Sharma', 60000, 1),
    (102, 'Priya Das', 70000, 2),
    (103, 'Rahul Sen', 50000, 3);

-- 11. Display the audit log.
SELECT *
FROM demo_trigger_audit
ORDER BY audit_id;

-- 12. Update an employee's salary.
-- The UPDATE trigger runs automatically.
UPDATE demo_trigger_employees
SET salary = 75000
WHERE employee_id = 102;

-- 13. Verify the salary update log.
SELECT
    employee_id,
    old_salary,
    new_salary,
    action_time
FROM demo_trigger_audit
WHERE action_type = 'UPDATE';

-- 14. Update a non-salary field.
-- No new audit record is created because
-- the UPDATE trigger logs salary changes only.
UPDATE demo_trigger_employees
SET department_id = 4
WHERE employee_id = 101;

-- 15. Delete an employee record.
-- The DELETE trigger runs automatically.
DELETE FROM demo_trigger_employees
WHERE employee_id = 103;

-- 16. Display remaining employees.
SELECT *
FROM demo_trigger_employees
ORDER BY employee_id;

-- 17. Display complete audit history.
SELECT
    audit_id,
    employee_id,
    action_type,
    old_salary,
    new_salary,
    action_description,
    action_time
FROM demo_trigger_audit
ORDER BY audit_id;

-- 18. Count events by action type.
SELECT
    action_type,
    COUNT(*) AS total_events
FROM demo_trigger_audit
GROUP BY action_type
ORDER BY action_type;

-- 19. Calculate salary differences
-- for recorded salary updates.
SELECT
    employee_id,
    old_salary,
    new_salary,
    new_salary - old_salary AS salary_difference
FROM demo_trigger_audit
WHERE action_type = 'UPDATE';

-- 20. Display the demonstration triggers.
SHOW TRIGGERS FROM sql_journey
LIKE 'demo_trigger_employees';

-- Important:
-- INSERT triggers use NEW values.
-- DELETE triggers use OLD values.
-- UPDATE triggers can access both.
--
-- Triggers are executed automatically.
-- They do not require a CALL statement.
--
-- Audit records in this example are
-- stored without a foreign key to the
-- employee table so deleted employee
-- IDs can remain in the audit history.
