-- =====================================================
-- STORED PROCEDURES - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================

USE employee_attendance_db;

DROP PROCEDURE IF EXISTS mark_attendance;
DROP PROCEDURE IF EXISTS approve_leave;
DROP PROCEDURE IF EXISTS employee_summary;
DROP PROCEDURE IF EXISTS department_report;

-- 1. mark_attendance()
-- Marks check-in or updates check-out, dynamically computing the status.
-- Implements INSERT ... ON DUPLICATE KEY UPDATE as requested.
DELIMITER //

CREATE PROCEDURE mark_attendance(
    IN p_emp_id INT,
    IN p_work_date DATE,
    IN p_check_in TIME,
    IN p_check_out TIME
)
BEGIN
    DECLARE v_status VARCHAR(20) DEFAULT 'Present';
    DECLARE v_work_hours DECIMAL(4,2);

    -- Set status based on check-in hour
    IF p_check_in > '09:15:00' THEN
        SET v_status = 'Late';
    END IF;

    -- If check-out is provided, calculate if it qualifies for half-day
    IF p_check_out IS NOT NULL THEN
        SET v_work_hours = HOUR(TIMEDIFF(p_check_out, p_check_in)) + MINUTE(TIMEDIFF(p_check_out, p_check_in)) / 60.0;
        IF v_work_hours < 4.0 THEN
            SET v_status = 'Half-Day';
        ELSEIF v_work_hours >= 4.0 AND p_check_in > '09:15:00' THEN
            SET v_status = 'Late';
        ELSE
            SET v_status = 'Present';
        END IF;
    END IF;

    -- Using ON DUPLICATE KEY UPDATE to mark check-in or update check-out
    INSERT INTO Attendance (emp_id, work_date, check_in, check_out, status)
    VALUES (p_emp_id, p_work_date, p_check_in, p_check_out, v_status)
    ON DUPLICATE KEY UPDATE
        check_out = IFNULL(p_check_out, check_out),
        -- Recalculate status dynamically based on check-in and the new check-out time
        status = CASE
            WHEN p_check_out IS NOT NULL AND (HOUR(TIMEDIFF(p_check_out, check_in)) + MINUTE(TIMEDIFF(p_check_out, check_in)) / 60.0) < 4.0 THEN 'Half-Day'
            WHEN check_in > '09:15:00' THEN 'Late'
            ELSE 'Present'
        END;
END //

DELIMITER ;

-- 2. approve_leave()
-- Approves or rejects a leave request. If approved, automatically logs absent records
-- for the leave date range in the attendance table.
DELIMITER //

CREATE PROCEDURE approve_leave(
    IN p_leave_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE v_emp_id INT;
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_current_date DATE;

    -- Ensure transaction control
    START TRANSACTION;

    -- Update the status of the leave request
    UPDATE LeaveRequests 
    SET status = p_status 
    WHERE leave_id = p_leave_id;

    -- If approved, insert attendance records of status 'Absent'
    IF p_status = 'Approved' THEN
        SELECT emp_id, start_date, end_date INTO v_emp_id, v_start_date, v_end_date
        FROM LeaveRequests
        WHERE leave_id = p_leave_id;

        SET v_current_date = v_start_date;

        WHILE v_current_date <= v_end_date DO
            -- Insert 'Absent' status for each date in the range, handling duplicates
            INSERT INTO Attendance (emp_id, work_date, check_in, check_out, status)
            VALUES (v_emp_id, v_current_date, '00:00:00', '00:00:00', 'Absent')
            ON DUPLICATE KEY UPDATE
                check_in = '00:00:00',
                check_out = '00:00:00',
                status = 'Absent';

            SET v_current_date = DATE_ADD(v_current_date, INTERVAL 1 DAY);
        END WHILE;
    END IF;

    COMMIT;
END //

DELIMITER ;

-- 3. employee_summary()
-- Aggregates work stats for a single employee.
DELIMITER //

CREATE PROCEDURE employee_summary(
    IN p_emp_id INT
)
BEGIN
    SELECT 
        e.emp_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        e.job_title,
        d.dept_name,
        COUNT(a.attendance_id) AS total_logged_days,
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days,
        SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_days,
        SUM(CASE WHEN a.status = 'Half-Day' THEN 1 ELSE 0 END) AS half_days,
        SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_days,
        ROUND((SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 WHEN a.status = 'Half-Day' THEN 0.5 ELSE 0 END) / NULLIF(COUNT(a.attendance_id), 0)) * 100, 2) AS attendance_percentage
    FROM Employees e
    LEFT JOIN Departments d ON e.dept_id = d.dept_id
    LEFT JOIN Attendance a ON e.emp_id = a.emp_id
    WHERE e.emp_id = p_emp_id
    GROUP BY e.emp_id, e.first_name, e.last_name, e.job_title, d.dept_name;
END //

DELIMITER ;

-- 4. department_report()
-- Returns general metrics and performance stats for a department.
DELIMITER //

CREATE PROCEDURE department_report(
    IN p_dept_id INT
)
BEGIN
    SELECT 
        d.dept_id,
        d.dept_name,
        d.location,
        COUNT(DISTINCT e.emp_id) AS total_employees,
        ROUND(AVG(e.salary), 2) AS average_salary,
        COUNT(DISTINCT CASE WHEN a.work_date = CURDATE() AND a.status IN ('Present', 'Late', 'Half-Day') THEN e.emp_id END) AS employees_present_today,
        COUNT(DISTINCT CASE WHEN lr.status = 'Pending' THEN lr.leave_id END) AS pending_leave_requests
    FROM Departments d
    LEFT JOIN Employees e ON d.dept_id = e.dept_id
    LEFT JOIN Attendance a ON e.emp_id = a.emp_id
    LEFT JOIN LeaveRequests lr ON e.emp_id = lr.emp_id
    WHERE d.dept_id = p_dept_id
    GROUP BY d.dept_id, d.dept_name, d.location;
END //

DELIMITER ;
