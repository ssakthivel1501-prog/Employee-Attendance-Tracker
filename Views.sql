-- =====================================================
-- DATABASE VIEWS - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================

USE employee_attendance_db;

-- 1. today_attendance
-- Real-time check on who has clocked in today, their times, and current status.
CREATE OR REPLACE VIEW today_attendance AS
SELECT 
    a.attendance_id,
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.job_title,
    d.dept_name,
    a.work_date,
    a.check_in,
    a.check_out,
    a.status
FROM Attendance a
INNER JOIN Employees e ON a.emp_id = e.emp_id
LEFT JOIN Departments d ON e.dept_id = d.dept_id
WHERE a.work_date = CURDATE();

-- 2. employee_summary_view
-- Consolidates work statistics and calculates the attendance rate percentage for each employee.
CREATE OR REPLACE VIEW employee_summary_view AS
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
    ROUND((SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 WHEN a.status = 'Half-Day' THEN 0.5 ELSE 0 END) / NULLIF(COUNT(a.attendance_id), 0)) * 100, 2) AS attendance_rate_pct
FROM Employees e
LEFT JOIN Departments d ON e.dept_id = d.dept_id
LEFT JOIN Attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id, e.first_name, e.last_name, e.job_title, d.dept_name;

-- 3. department_attendance
-- Aggregates daily attendance figures at the department level.
CREATE OR REPLACE VIEW department_attendance AS
SELECT 
    d.dept_id,
    d.dept_name,
    a.work_date,
    COUNT(DISTINCT e.emp_id) AS total_department_employees,
    SUM(CASE WHEN a.status IN ('Present', 'Late', 'Half-Day') THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    ROUND((SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 WHEN a.status = 'Half-Day' THEN 0.5 ELSE 0 END) / NULLIF(COUNT(DISTINCT e.emp_id), 0)) * 100, 2) AS daily_attendance_pct
FROM Departments d
INNER JOIN Employees e ON d.dept_id = e.dept_id
INNER JOIN Attendance a ON e.emp_id = a.emp_id
GROUP BY d.dept_id, d.dept_name, a.work_date;

-- 4. pending_leave_requests
-- Lists all leave requests awaiting approval, detailing employee, department, and duration.
CREATE OR REPLACE VIEW pending_leave_requests AS
SELECT 
    lr.leave_id,
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name,
    lr.leave_type,
    lr.start_date,
    lr.end_date,
    DATEDIFF(lr.end_date, lr.start_date) + 1 AS total_leave_days,
    lr.status,
    lr.applied_on
FROM LeaveRequests lr
INNER JOIN Employees e ON lr.emp_id = e.emp_id
LEFT JOIN Departments d ON e.dept_id = d.dept_id
WHERE lr.status = 'Pending';
