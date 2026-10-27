
/*
========================================================
    SQL JOURNEY
    Module 09: Advanced SQL
    File: 03_stored_procedures.sql
    Topic: Stored Procedures
========================================================

Description:
Stored procedures execute reusable SQL logic
inside the MySQL database.

Concepts Covered:
1. CREATE PROCEDURE
2. CALL
3. IN parameters
4. OUT parameters
5. INOUT parameters
6. Local variables
7. IF conditions
8. SIGNAL for validation
9. DROP PROCEDURE

========================================================
*/

USE sql_journey;

-- 1. Remove previous demonstration procedures.
DROP PROCEDURE IF EXISTS sp_demo_get_employees;
DROP PROCEDURE IF EXISTS sp_demo_department_payroll;
DROP PROCEDURE IF EXISTS sp_demo_add_bonus;
DROP PROCEDURE IF EXISTS sp_demo_raise_salary;

-- 2. Reset the demonstration table.
DROP TABLE IF EXISTS demo_procedure_employees;

-- 3. Create a dedicated employee table.
CREATE TABLE demo_procedure_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_demo_procedure_salary
        CHECK (salary >= 0)
) ENGINE = InnoDB;

-- 4. Copy sample records.
INSERT INTO demo_procedure_employees
    (employee_id, employee_name, department_id, salary)
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM employees;

-- 5. Change the delimiter for stored procedures.
DELIMITER $$

-- 6. Procedure with an IN parameter.
-- Retrieve employees from a department.
CREATE PROCEDURE sp_demo_get_employees(
    IN p_department_id INT
)
BEGIN
    SELECT
        employee_id,
        employee_name,
        salary
    FROM demo_procedure_employees
    WHERE department_id = p_department_id
    ORDER BY employee_id;
END$$

-- 7. Procedure with an OUT parameter.
-- Calculate total payroll for a department.
CREATE PROCEDURE sp_demo_department_payroll(
    IN p_department_id INT,
    OUT p_total_payroll DECIMAL(12, 2)
)
BEGIN
    SELECT
        COALESCE(SUM(salary), 0)
    INTO p_total_payroll
    FROM demo_procedure_employees
    WHERE department_id = p_department_id;
END$$

-- 8. Procedure with an INOUT parameter.
-- Add an employee's 5% bonus to a running total.
CREATE PROCEDURE sp_demo_add_bonus(
    IN p_employee_id INT,
    INOUT p_running_bonus DECIMAL(12, 2)
)
BEGIN
    DECLARE v_bonus DECIMAL(12, 2);

    SELECT
        ROUND(salary * 0.05, 2)
    INTO v_bonus
    FROM demo_procedure_employees
    WHERE employee_id = p_employee_id;

    IF v_bonus IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee not found';
    END IF;

    SET p_running_bonus =
        COALESCE(p_running_bonus, 0) + v_bonus;
END$$

-- 9. Procedure with validation and UPDATE.
-- Apply a salary increase between 0% and 20%.
CREATE PROCEDURE sp_demo_raise_salary(
    IN p_employee_id INT,
    IN p_percentage DECIMAL(5, 2)
)
BEGIN
    -- Validate the percentage.
    IF p_percentage IS NULL
       OR p_percentage <= 0
       OR p_percentage > 20 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Raise percentage must be above 0 and at most 20';
    END IF;

    -- Validate the employee.
    IF NOT EXISTS (
        SELECT 1
        FROM demo_procedure_employees
        WHERE employee_id = p_employee_id
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee not found';
    END IF;

    -- Update the employee salary.
    UPDATE demo_procedure_employees
    SET salary = ROUND(
        salary * (1 + p_percentage / 100),
        2
    )
    WHERE employee_id = p_employee_id;
END$$

-- 10. Restore the standard delimiter.
DELIMITER ;

-- 11. Call the IN parameter procedure.
CALL sp_demo_get_employees(101);

-- 12. Call the OUT parameter procedure.
SET @total_payroll = 0;

CALL sp_demo_department_payroll(
    101,
    @total_payroll
);

SELECT
    @total_payroll AS department_payroll;

-- 13. Call the INOUT parameter procedure.
SET @bonus_total = 0;

CALL sp_demo_add_bonus(1, @bonus_total);
CALL sp_demo_add_bonus(2, @bonus_total);

SELECT
    @bonus_total AS combined_bonus;

-- 14. Display salary before the increase.
SELECT
    employee_id,
    employee_name,
    salary
FROM demo_procedure_employees
WHERE employee_id = 1;

-- 15. Apply a 5% salary increase.
CALL sp_demo_raise_salary(1, 5);

-- 16. Display the updated salary.
SELECT
    employee_id,
    employee_name,
    salary
FROM demo_procedure_employees
WHERE employee_id = 1;

-- 17. Display all stored procedures.
SHOW PROCEDURE STATUS
WHERE Db = 'sql_journey'
  AND Name LIKE 'sp_demo_%';

-- 18. Inspect a procedure definition.
SHOW CREATE PROCEDURE sp_demo_raise_salary;

-- 19. Invalid calls (commented out).
-- These demonstrate validation errors.

-- CALL sp_demo_raise_salary(1, -5);
-- CALL sp_demo_raise_salary(1, 50);
-- CALL sp_demo_raise_salary(999, 5);

-- 20. Demonstrate removing a procedure.
DELIMITER $$

CREATE PROCEDURE sp_demo_temporary()
BEGIN
    SELECT 'Temporary procedure' AS message;
END$$

DELIMITER ;

CALL sp_demo_temporary();

DROP PROCEDURE IF EXISTS sp_demo_temporary;

-- Important:
-- IN passes a value into the procedure.
-- OUT returns a value to the caller.
-- INOUT accepts and modifies a value.
--
-- SQLSTATE '45000' represents a
-- user-defined exception.
--
-- Salary changes are limited to the
-- demonstration table, not employees.
