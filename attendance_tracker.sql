-- =====================================================
-- MASTER DATABASE SETUP & SCHEMA
-- EMPLOYEE ATTENDANCE TRACKER
-- =====================================================

CREATE DATABASE IF NOT EXISTS employee_attendance_db;
USE employee_attendance_db;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS EmployeeAuditLog;
DROP TABLE IF EXISTS LeaveRequests;
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Departments;

-- 1. Departments Table
CREATE TABLE Departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(100) UNIQUE NOT NULL,
    budget DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (budget >= 0),
    location VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- 2. Employees Table
CREATE TABLE Employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    phone VARCHAR(15) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    dept_id INT NULL,
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) 
        REFERENCES Departments(dept_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. Attendance Table
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    work_date DATE NOT NULL,
    check_in TIME NOT NULL,
    check_out TIME NULL,
    status ENUM('Present', 'Absent', 'Late', 'Half-Day') NOT NULL DEFAULT 'Present',
    CONSTRAINT fk_attendance_emp FOREIGN KEY (emp_id) 
        REFERENCES Employees(emp_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT uq_emp_date UNIQUE (emp_id, work_date),
    CONSTRAINT chk_check_out CHECK (check_out IS NULL OR check_out >= check_in)
) ENGINE=InnoDB;

-- 4. LeaveRequests Table
CREATE TABLE LeaveRequests (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    leave_type ENUM('Sick', 'Casual', 'Earned', 'Maternity', 'Paternity', 'Unpaid') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    applied_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_id) 
        REFERENCES Employees(emp_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT chk_leave_dates CHECK (end_date >= start_date)
) ENGINE=InnoDB;

-- 5. EmployeeAuditLog Table (For Audit Trigger)
CREATE TABLE EmployeeAuditLog (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    action_type VARCHAR(10) NOT NULL,
    old_salary DECIMAL(10,2) NULL,
    new_salary DECIMAL(10,2) NULL,
    old_dept_id INT NULL,
    new_dept_id INT NULL,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- SAMPLE DATA INSERT STATEMENTS
-- =====================================================


-- Inserting 10 Departments
INSERT INTO Departments (dept_name, budget, location) VALUES
('Human Resources', 150000.0, 'Mumbai, India'),
('Engineering', 850000.0, 'Bengaluru, India'),
('Product Management', 300000.0, 'Bengaluru, India'),
('Marketing', 200000.0, 'Delhi, India'),
('Sales', 250000.0, 'Mumbai, India'),
('Finance', 400000.0, 'Pune, India'),
('Customer Support', 180000.0, 'Hyderabad, India'),
('Legal', 120000.0, 'Delhi, India'),
('Operations', 220000.0, 'Chennai, India'),
('Design', 280000.0, 'Bengaluru, India');

-- Inserting 50 Employees
INSERT INTO Employees (first_name, last_name, email, phone, hire_date, job_title, salary, dept_id) VALUES
('Aarav', 'Sharma', 'aarav.sharma91@corp.com', '+917478163327', '2026-02-18', 'HR Specialist', 73162.56, 1),
('Aditi', 'Patel', 'aditi.patel27@corp.com', '+917440213415', '2022-06-25', 'Software Engineer', 112906.64, 2),
('Amit', 'Verma', 'amit.verma14@corp.com', '+917127978094', '2025-10-01', 'Product Manager', 71756.0, 3),
('Ananya', 'Rao', 'ananya.rao87@corp.com', '+917113971123', '2023-02-16', 'Marketing Specialist', 127342.26, 4),
('Arjun', 'Singh', 'arjun.singh99@corp.com', '+919340505846', '2023-12-03', 'Sales Executive', 96659.04, 5),
('Diya', 'Iyer', 'diya.iyer45@corp.com', '+917027911967', '2025-05-19', 'Financial Analyst', 84128.81, 6),
('Ishan', 'Gupta', 'ishan.gupta29@corp.com', '+917924765563', '2024-05-21', 'Support Representative', 55665.77, 7),
('Kavya', 'Nair', 'kavya.nair22@corp.com', '+918541804686', '2024-05-06', 'Legal Counsel', 137819.75, 8),
('Nikhil', 'Reddy', 'nikhil.reddy68@corp.com', '+919303082117', '2025-07-29', 'Operations Manager', 54062.02, 9),
('Pooja', 'Joshi', 'pooja.joshi47@corp.com', '+919699987374', '2022-10-22', 'UX Designer', 111395.5, 10),
('Rahul', 'Mishra', 'rahul.mishra18@corp.com', '+917196814233', '2022-07-26', 'HR Specialist', 133902.86, 1),
('Riya', 'Sen', 'riya.sen20@corp.com', '+917999829240', '2025-09-16', 'Senior Software Engineer', 76966.96, 2),
('Rohan', 'Saxena', 'rohan.saxena91@corp.com', '+918566942273', '2025-05-12', 'Product Manager', 85856.13, 3),
('Shreya', 'Bose', 'shreya.bose95@corp.com', '+918146660997', '2022-06-11', 'Marketing Specialist', 115050.07, 4),
('Siddharth', 'Das', 'siddharth.das31@corp.com', '+919294113287', '2024-11-25', 'Sales Executive', 98159.92, 5),
('Sneha', 'Kulkarni', 'sneha.kulkarni44@corp.com', '+919748778024', '2023-02-25', 'Financial Analyst', 123730.64, 6),
('Tanvi', 'Kapoor', 'tanvi.kapoor17@corp.com', '+917983753977', '2026-02-04', 'Support Representative', 91133.95, 7),
('Varun', 'Choudhury', 'varun.choudhury18@corp.com', '+917906164396', '2023-02-04', 'Legal Counsel', 69452.05, 8),
('Yash', 'Malhotra', 'yash.malhotra73@corp.com', '+918699226064', '2022-09-02', 'Operations Manager', 61430.23, 9),
('Divya', 'Pillai', 'divya.pillai27@corp.com', '+918059257080', '2023-02-16', 'UX Designer', 130906.59, 10),
('Rohit', 'Sharma', 'rohit.sharma64@corp.com', '+919506254832', '2024-01-14', 'HR Specialist', 70221.89, 1),
('Sunil', 'Gavaskar', 'sunil.gavaskar27@corp.com', '+919188398760', '2023-07-05', 'Software Engineer', 131914.95, 2),
('Sachin', 'Tendulkar', 'sachin.tendulkar24@corp.com', '+917656448479', '2022-10-03', 'Product Manager', 136089.13, 3),
('Virat', 'Kohli', 'virat.kohli64@corp.com', '+919561557300', '2025-12-01', 'Marketing Specialist', 88886.22, 4),
('Mahendra', 'Dhoni', 'mahendra.dhoni69@corp.com', '+919272528809', '2024-11-12', 'Sales Executive', 123232.59, 5),
('Sourav', 'Ganguly', 'sourav.ganguly24@corp.com', '+919927923735', '2023-04-07', 'Financial Analyst', 133388.85, 6),
('Anil', 'Kumble', 'anil.kumble53@corp.com', '+917479112937', '2024-08-17', 'Support Representative', 63188.14, 7),
('Kapil', 'Dev', 'kapil.dev10@corp.com', '+918131247330', '2023-06-20', 'Legal Counsel', 103383.39, 8),
('Rahul', 'Dravid', 'rahul.dravid23@corp.com', '+919685643886', '2024-08-07', 'Operations Manager', 62576.52, 9),
('Jasprit', 'Bumrah', 'jasprit.bumrah30@corp.com', '+919316615266', '2023-04-20', 'UX Designer', 113878.63, 10),
('Hardik', 'Pandya', 'hardik.pandya72@corp.com', '+917083651970', '2025-08-24', 'HR Specialist', 146053.02, 1),
('Ravindra', 'Jadeja', 'ravindra.jadeja49@corp.com', '+918028439863', '2025-12-13', 'Software Engineer', 145971.1, 2),
('Lokesh', 'Rahul', 'lokesh.rahul20@corp.com', '+917367878761', '2023-07-20', 'Product Manager', 157468.22, 3),
('Rishabh', 'Pant', 'rishabh.pant78@corp.com', '+917540137296', '2025-07-22', 'Marketing Specialist', 153887.6, 4),
('Shreyas', 'Iyer', 'shreyas.iyer31@corp.com', '+918138409539', '2023-04-26', 'Sales Executive', 155901.73, 5),
('Shikhar', 'Dhawan', 'shikhar.dhawan79@corp.com', '+919962958940', '2025-02-23', 'Financial Analyst', 90884.11, 6),
('Bhuvneshwar', 'Kumar', 'bhuvneshwar.kumar95@corp.com', '+919791205006', '2024-03-07', 'Support Representative', 148455.62, 7),
('Yuzvendra', 'Chahal', 'yuzvendra.chahal67@corp.com', '+917519709079', '2024-11-19', 'Legal Counsel', 52362.98, 8),
('Kuldeep', 'Yadav', 'kuldeep.yadav12@corp.com', '+919526766690', '2023-03-03', 'Operations Manager', 112670.61, 9),
('Mohammed', 'Shami', 'mohammed.shami10@corp.com', '+917304912982', '2022-09-26', 'UX Designer', 71328.31, 10),
('Ravichandran', 'Ashwin', 'ravichandran.ashwin14@corp.com', '+918419179580', '2025-11-16', 'HR Specialist', 77024.89, 1),
('Cheteshwar', 'Pujara', 'cheteshwar.pujara72@corp.com', '+917920140090', '2023-04-02', 'Software Engineer', 128185.55, 2),
('Ajinkya', 'Rahane', 'ajinkya.rahane83@corp.com', '+919474810179', '2023-08-16', 'Product Manager', 135231.23, 3),
('Ishant', 'Sharma', 'ishant.sharma62@corp.com', '+917817804383', '2025-09-29', 'Marketing Specialist', 120783.02, 4),
('Umesh', 'Yadav', 'umesh.yadav55@corp.com', '+918819256337', '2023-12-21', 'Sales Executive', 144341.23, 5),
('Wriddhiman', 'Saha', 'wriddhiman.saha16@corp.com', '+919892078691', '2022-08-11', 'Financial Analyst', 51970.46, 6),
('Hanuma', 'Vihari', 'hanuma.vihari53@corp.com', '+917469306919', '2024-11-17', 'Support Representative', 66874.02, 7),
('Mayank', 'Agarwal', 'mayank.agarwal67@corp.com', '+917602078388', '2023-11-28', 'Legal Counsel', 77032.69, 8),
('Shubman', 'Gill', 'shubman.gill41@corp.com', '+917323775634', '2023-10-16', 'Operations Manager', 50817.66, 9),
('Prithvi', 'Shaw', 'prithvi.shaw79@corp.com', '+917063384488', '2025-10-01', 'UX Designer', 64125.78, 10);

-- Inserting 20 Leave Requests
INSERT INTO LeaveRequests (emp_id, leave_type, start_date, end_date, status, applied_on) VALUES
(32, 'Maternity', '2026-07-05', '2026-07-06', 'Approved', '2026-07-01 17:42:24'),
(25, 'Sick', '2026-06-23', '2026-06-27', 'Pending', '2026-06-20 17:42:24'),
(28, 'Unpaid', '2026-06-03', '2026-06-07', 'Approved', '2026-05-29 17:42:24'),
(13, 'Earned', '2026-07-02', '2026-07-07', 'Rejected', '2026-07-01 17:42:24'),
(35, 'Sick', '2026-05-31', '2026-06-01', 'Approved', '2026-05-28 17:42:24'),
(38, 'Maternity', '2026-06-17', '2026-06-19', 'Approved', '2026-06-12 17:42:24'),
(33, 'Sick', '2026-05-23', '2026-05-24', 'Rejected', '2026-05-21 17:42:24'),
(5, 'Unpaid', '2026-05-22', '2026-05-26', 'Approved', '2026-05-20 17:42:24'),
(37, 'Casual', '2026-06-12', '2026-06-13', 'Rejected', '2026-06-07 17:42:24'),
(6, 'Maternity', '2026-06-07', '2026-06-12', 'Rejected', '2026-06-02 17:42:24'),
(21, 'Earned', '2026-07-04', '2026-07-06', 'Pending', '2026-07-01 17:42:24'),
(26, 'Casual', '2026-06-05', '2026-06-09', 'Pending', '2026-06-02 17:42:24'),
(49, 'Sick', '2026-07-18', '2026-07-23', 'Rejected', '2026-07-14 17:42:24'),
(7, 'Sick', '2026-06-12', '2026-06-17', 'Pending', '2026-06-10 17:42:24'),
(9, 'Earned', '2026-07-12', '2026-07-15', 'Pending', '2026-07-10 17:42:24'),
(11, 'Maternity', '2026-05-27', '2026-05-30', 'Rejected', '2026-05-22 17:42:24'),
(42, 'Paternity', '2026-07-19', '2026-07-22', 'Rejected', '2026-07-14 17:42:24'),
(7, 'Casual', '2026-06-29', '2026-06-30', 'Rejected', '2026-06-28 17:42:24'),
(36, 'Casual', '2026-06-30', '2026-07-05', 'Approved', '2026-06-27 17:42:24'),
(46, 'Earned', '2026-07-04', '2026-07-09', 'Pending', '2026-07-01 17:42:24');

-- Inserting 100 Attendance records
INSERT INTO Attendance (emp_id, work_date, check_in, check_out, status) VALUES
(1, '2026-07-06', '09:03:00', '17:40:00', 'Present'),
(1, '2026-07-07', '09:02:00', '17:21:00', 'Present'),
(1, '2026-07-08', '09:10:00', '18:35:00', 'Present'),
(1, '2026-07-09', '08:33:00', '17:56:00', 'Present'),
(1, '2026-07-10', '08:47:00', '17:53:00', 'Present'),
(2, '2026-07-06', '08:43:00', '17:02:00', 'Present'),
(2, '2026-07-07', '08:58:00', '18:13:00', 'Present'),
(2, '2026-07-08', '08:41:00', '18:39:00', 'Present'),
(2, '2026-07-09', '08:57:00', '17:51:00', 'Present'),
(2, '2026-07-10', '09:01:00', '17:47:00', 'Present'),
(3, '2026-07-06', '09:42:00', '17:17:00', 'Late'),
(3, '2026-07-07', '08:42:00', '17:54:00', 'Present'),
(3, '2026-07-08', '08:56:00', '18:22:00', 'Present'),
(3, '2026-07-09', '08:37:00', '17:42:00', 'Present'),
(3, '2026-07-10', '09:17:00', '17:49:00', 'Late'),
(4, '2026-07-06', '09:43:00', '18:01:00', 'Late'),
(4, '2026-07-07', '09:11:00', '18:02:00', 'Present'),
(4, '2026-07-08', '09:22:00', '18:27:00', 'Late'),
(4, '2026-07-09', '08:42:00', '12:42:00', 'Half-Day'),
(4, '2026-07-10', '09:00:00', '17:23:00', 'Present'),
(5, '2026-07-06', '09:39:00', '18:42:00', 'Late'),
(5, '2026-07-07', '09:32:00', '18:42:00', 'Late'),
(5, '2026-07-08', '09:44:00', '18:35:00', 'Late'),
(5, '2026-07-09', '09:42:00', '18:43:00', 'Late'),
(5, '2026-07-10', '08:49:00', '18:25:00', 'Present'),
(6, '2026-07-06', '08:39:00', '18:13:00', 'Present'),
(6, '2026-07-07', '09:29:00', '18:28:00', 'Late'),
(6, '2026-07-08', '09:10:00', '17:18:00', 'Present'),
(6, '2026-07-09', '09:05:00', '17:43:00', 'Present'),
(6, '2026-07-10', '08:34:00', '17:02:00', 'Present'),
(7, '2026-07-06', '09:39:00', '17:29:00', 'Late'),
(7, '2026-07-07', '08:52:00', '18:31:00', 'Present'),
(7, '2026-07-08', '08:50:00', '17:57:00', 'Present'),
(7, '2026-07-09', '08:54:00', '18:14:00', 'Present'),
(7, '2026-07-10', '09:03:00', '17:58:00', 'Present'),
(8, '2026-07-06', '09:08:00', '18:42:00', 'Present'),
(8, '2026-07-07', '09:28:00', '18:53:00', 'Late'),
(8, '2026-07-08', '09:10:00', '18:28:00', 'Present'),
(8, '2026-07-09', '08:56:00', '18:49:00', 'Present'),
(8, '2026-07-10', '09:40:00', '17:17:00', 'Late'),
(9, '2026-07-06', '09:15:00', '18:21:00', 'Present'),
(9, '2026-07-07', '08:34:00', '17:14:00', 'Present'),
(9, '2026-07-08', '08:52:00', '17:04:00', 'Present'),
(9, '2026-07-09', '00:00:00', '00:00:00', 'Absent'),
(9, '2026-07-10', '09:24:00', '17:54:00', 'Late'),
(10, '2026-07-06', '09:30:00', '17:22:00', 'Late'),
(10, '2026-07-07', '09:26:00', '17:31:00', 'Late'),
(10, '2026-07-08', '09:31:00', '17:24:00', 'Late'),
(10, '2026-07-09', '09:10:00', '18:58:00', 'Present'),
(10, '2026-07-10', '08:59:00', '18:37:00', 'Present'),
(11, '2026-07-06', '08:32:00', '18:08:00', 'Present'),
(11, '2026-07-07', '08:31:00', '18:24:00', 'Present'),
(11, '2026-07-08', '09:20:00', '18:48:00', 'Late'),
(11, '2026-07-09', '09:26:00', '18:53:00', 'Late'),
(11, '2026-07-10', '08:53:00', '17:22:00', 'Present'),
(12, '2026-07-06', '08:54:00', '12:54:00', 'Half-Day'),
(12, '2026-07-07', '08:36:00', '17:39:00', 'Present'),
(12, '2026-07-08', '08:45:00', '17:36:00', 'Present'),
(12, '2026-07-09', '09:44:00', '18:49:00', 'Late'),
(12, '2026-07-10', '08:54:00', '17:19:00', 'Present'),
(13, '2026-07-06', '08:59:00', '18:36:00', 'Present'),
(13, '2026-07-07', '09:25:00', '17:04:00', 'Late'),
(13, '2026-07-08', '08:33:00', '18:54:00', 'Present'),
(13, '2026-07-09', '08:55:00', '17:22:00', 'Present'),
(13, '2026-07-10', '09:04:00', '18:00:00', 'Present'),
(14, '2026-07-06', '09:06:00', '18:23:00', 'Present'),
(14, '2026-07-07', '09:45:00', '17:27:00', 'Late'),
(14, '2026-07-08', '09:39:00', '18:29:00', 'Late'),
(14, '2026-07-09', '09:20:00', '17:53:00', 'Late'),
(14, '2026-07-10', '09:28:00', '17:48:00', 'Late'),
(15, '2026-07-06', '09:21:00', '17:31:00', 'Late'),
(15, '2026-07-07', '08:45:00', '17:22:00', 'Present'),
(15, '2026-07-08', '09:17:00', '13:17:00', 'Half-Day'),
(15, '2026-07-09', '08:32:00', '17:46:00', 'Present'),
(15, '2026-07-10', '08:52:00', '18:41:00', 'Present'),
(16, '2026-07-06', '09:01:00', '17:18:00', 'Present'),
(16, '2026-07-07', '08:39:00', '18:30:00', 'Present'),
(16, '2026-07-08', '09:27:00', '18:22:00', 'Late'),
(16, '2026-07-09', '09:19:00', '18:14:00', 'Late'),
(16, '2026-07-10', '08:40:00', '17:47:00', 'Present'),
(17, '2026-07-06', '08:36:00', '17:47:00', 'Present'),
(17, '2026-07-07', '09:06:00', '17:18:00', 'Present'),
(17, '2026-07-08', '08:39:00', '17:45:00', 'Present'),
(17, '2026-07-09', '09:02:00', '17:35:00', 'Present'),
(17, '2026-07-10', '08:50:00', '18:06:00', 'Present'),
(18, '2026-07-06', '09:30:00', '18:28:00', 'Late'),
(18, '2026-07-07', '08:38:00', '18:07:00', 'Present'),
(18, '2026-07-08', '09:31:00', '17:36:00', 'Late'),
(18, '2026-07-09', '08:34:00', '17:51:00', 'Present'),
(18, '2026-07-10', '09:05:00', '17:07:00', 'Present'),
(19, '2026-07-06', '09:38:00', '17:49:00', 'Late'),
(19, '2026-07-07', '09:28:00', '18:55:00', 'Late'),
(19, '2026-07-08', '09:19:00', '17:39:00', 'Late'),
(19, '2026-07-09', '08:54:00', '17:40:00', 'Present'),
(19, '2026-07-10', '08:35:00', '17:11:00', 'Present'),
(20, '2026-07-06', '08:30:00', '18:28:00', 'Present'),
(20, '2026-07-07', '09:18:00', '17:14:00', 'Late'),
(20, '2026-07-08', '09:44:00', '18:04:00', 'Late'),
(20, '2026-07-09', '09:40:00', '17:27:00', 'Late'),
(20, '2026-07-10', '08:50:00', '17:58:00', 'Present');



-- =====================================================
-- DATABASE INDEXES
-- =====================================================

-- Index to optimize employee searches by department (joins)
CREATE INDEX idx_emp_dept ON Employees(dept_id);

-- Index to optimize querying attendance by date
CREATE INDEX idx_attendance_date ON Attendance(work_date);

-- Composite index for fast lookup of employee-specific daily attendance records
CREATE INDEX idx_attendance_emp_date ON Attendance(emp_id, work_date);

-- Index to speed up leaf history requests for individual employees
CREATE INDEX idx_leave_emp ON LeaveRequests(emp_id);

-- =====================================================
-- DATABASE TRIGGERS - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================



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

-- =====================================================
-- STORED PROCEDURES - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================



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

-- =====================================================
-- DATABASE VIEWS - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================



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
