-- =====================================================
-- DATABASE TRIGGERS - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================

USE employee_attendance_db;

DROP TRIGGER IF EXISTS before_attendance_insert;
DROP TRIGGER IF EXISTS before_attendance_update;
DROP TRIGGER IF EXISTS before_leave_insert;
DROP TRIGGER IF EXISTS after_employee_update;

-- 1. before_attendance_insert
-- Ensures check_out (if present) is chronologically after check_in.
DELIMITER //

CREATE TRIGGER before_attendance_insert
BEFORE INSERT ON Attendance
FOR EACH ROW
BEGIN
    IF NEW.check_out IS NOT NULL AND NEW.check_out <> '00:00:00' AND NEW.check_out < NEW.check_in THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Constraint Violation: Check-out time cannot be before check-in time.';
    END IF;
END //

DELIMITER ;

-- 2. before_attendance_update
-- Ensures check_out is chronologically after check_in on updates (e.g. through the mark_attendance procedure).
DELIMITER //

CREATE TRIGGER before_attendance_update
BEFORE UPDATE ON Attendance
FOR EACH ROW
BEGIN
    IF NEW.check_out IS NOT NULL AND NEW.check_out <> '00:00:00' AND NEW.check_out < NEW.check_in THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Constraint Violation: Check-out time cannot be before check-in time.';
    END IF;
END //

DELIMITER ;

-- 3. before_leave_insert
-- Validates leave date ranges and ensures that an employee doesn't request overlapping approved leaves.
DELIMITER //

CREATE TRIGGER before_leave_insert
BEFORE INSERT ON LeaveRequests
FOR EACH ROW
BEGIN
    DECLARE overlapping_count INT;

    -- Validate date range
    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Constraint Violation: Leave end_date must be greater than or equal to start_date.';
    END IF;

    -- Check for overlapping approved leave requests
    SELECT COUNT(*) INTO overlapping_count
    FROM LeaveRequests
    WHERE emp_id = NEW.emp_id
      AND status = 'Approved'
      AND NOT (NEW.end_date < start_date OR NEW.start_date > end_date);

    IF overlapping_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Business Rule Violation: Employee has an overlapping approved leave for this date range.';
    END IF;
END //

DELIMITER ;

-- 4. after_employee_update
-- Logs any changes in an employee's salary or department mapping to the audit table.
DELIMITER //

CREATE TRIGGER after_employee_update
AFTER UPDATE ON Employees
FOR EACH ROW
BEGIN
    -- Check if critical fields (Salary or Department ID) were modified
    IF OLD.salary <> NEW.salary OR 
       IFNULL(OLD.dept_id, 0) <> IFNULL(NEW.dept_id, 0) THEN
        
        INSERT INTO EmployeeAuditLog (
            emp_id, 
            action_type, 
            old_salary, 
            new_salary, 
            old_dept_id, 
            new_dept_id, 
            changed_by, 
            changed_at
        )
        VALUES (
            OLD.emp_id, 
            'UPDATE', 
            OLD.salary, 
            NEW.salary, 
            OLD.dept_id, 
            NEW.dept_id, 
            USER(), 
            NOW()
        );
    END IF;
END //

DELIMITER ;
