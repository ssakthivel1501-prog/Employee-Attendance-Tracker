# Project Documentation: Employee Attendance Tracker

---

## 1. ABSTRACT
In modern organizations, maintaining accurate records of employee attendance and leave requests is critical for payroll accuracy, performance evaluations, resource allocation, and general operational efficiency. Traditional manual systems, such as paper registers or basic spreadsheets, are prone to human errors, data duplication, lack of historical tracking, and security vulnerabilities. This project, titled **Employee Attendance Tracker**, introduces a robust, normalized (3NF), relational database management system (RDBMS) tailored to automate employee shifts, daily clock-in/out records, leave requests, and audit tracking.

Developed utilizing **MySQL 8.0+**, the database model ensures strict referential integrity, performance optimization through indexing, automated validation via triggers, and structured data queries using stored procedures and views. The result is a highly scalable, secure, and performant back-end system that provides real-time attendance analytics, automated status updates (e.g., classifying late clock-ins or half-days), and comprehensive logging of salary updates or department transfers. This documentation details the design, implementation, and testing phases of this project.

---

## 2. INTRODUCTION
An organization's workforce is its most valuable asset. However, managing this asset requires an effective system to track when employees work, how often they are absent, and how their leave requests are approved. 

The **Employee Attendance Tracker** is a DBMS mini-project designed to bridge the gap between administrative requirements and technical execution. The system stores detailed records of departments, employees, daily attendance, and leave requests. By leveraging the power of SQL, it eliminates manual reconciliation, provides immediate reporting, and gives decision-makers an audit trail of any critical data changes.

---

## 3. OBJECTIVES
The primary objectives of this database design are:
1. **Data Normalization**: Design a database structure up to Third Normal Form (3NF) to eliminate data redundancy and anomalies.
2. **Referential Integrity**: Establish strong relationships between departments, employees, attendance, and leave requests to prevent orphaned records.
3. **Automated Business Logic**: Implement stored procedures and triggers to automate status calculation (Present, Late, Half-Day, Absent), audit logging, and date validations.
4. **Optimized Performance**: Apply database indexes to speed up standard search queries, aggregate calculations, and join operations.
5. **Real-time Analytics**: Develop database views to allow HR managers to view today's attendance, pending leave requests, and department-wide metrics instantaneously.

---

## 4. PROBLEM STATEMENT
Manual attendance recording methods suffer from several systemic flaws:
- **Time Theft and Inaccuracies**: Employees manually logging incorrect times (e.g., back-dating check-ins).
- **Data Redundancy**: Redundant entries of employee profiles across different departments or spreadsheets.
- **Disconnected Systems**: Leave approvals not updating attendance records, leading to incorrect marking of "Absent" instead of "On Leave".
- **Lack of Audits**: No history of changes made to sensitive data like salaries or department assignments.
- **Reporting Delay**: Generating monthly attendance percentages or department reports takes hours of manual filtering and calculation.

This project addresses these challenges by consolidating all operations into a single RDBMS where logic is implemented at the database level to ensure consistency.

---

## 5. SYSTEM DESIGN

### System Architecture
The system follows a standard client-server database architecture. The database server (MySQL) stores the data and executes the business logic (stored procedures, triggers, views), while a client interface (e.g., MySQL Workbench or a web application) issues queries.

```
+--------------------+       SQL Queries       +----------------------------+
|  Client Interface  | ----------------------> |        MySQL Server        |
| (Workbench / App)  | <---------------------- | (Schema, Triggers, Procs)  |
+--------------------+    Result Datasets      +----------------------------+
```

### Key Modules
1. **Department Management**: Handles the creation of company departments, budget allocation, and location tracking.
2. **Employee Directory**: Stores employee profiles, salaries, job titles, and links them to departments.
3. **Attendance Logging**: Handles daily clock-in/out and calculates shift statuses.
4. **Leave Management**: Records leave applications, dates, types, and statuses.
5. **Security & Auditing**: Monitors and logs changes to employee records.

---

## 6. DATABASE DESIGN

The database schema consists of four primary tables and one auxiliary audit table. All tables are designed to meet 3NF guidelines.

### Schema Details

#### 1. Departments Table
- **Purpose**: Stores information about various departments in the organization.
- **Primary Key**: `dept_id` (INT, Auto Increment)
- **Attributes**:
  - `dept_name`: UNIQUE, NOT NULL (VARCHAR)
  - `budget`: DECIMAL (Check budget >= 0)
  - `location`: NOT NULL (VARCHAR)

#### 2. Employees Table
- **Purpose**: Manages employee personal details, job titles, salaries, and department associations.
- **Primary Key**: `emp_id` (INT, Auto Increment)
- **Foreign Key**: `dept_id` (References `Departments(dept_id)` with `ON DELETE SET NULL`)
- **Attributes**:
  - `first_name`, `last_name`: NOT NULL (VARCHAR)
  - `email`: UNIQUE, NOT NULL (VARCHAR, with format validation)
  - `phone`: UNIQUE, NOT NULL (VARCHAR)
  - `hire_date`: NOT NULL (DATE)
  - `job_title`: NOT NULL (VARCHAR)
  - `salary`: NOT NULL (DECIMAL, Check salary > 0)

#### 3. Attendance Table
- **Purpose**: Records daily clock-in and clock-out details.
- **Primary Key**: `attendance_id` (INT, Auto Increment)
- **Foreign Key**: `emp_id` (References `Employees(emp_id)` with `ON DELETE CASCADE`)
- **Composite Unique Key**: `(emp_id, work_date)` ensures only one record per employee per day.
- **Attributes**:
  - `work_date`: NOT NULL (DATE)
  - `check_in`: NOT NULL (TIME)
  - `check_out`: NULL (TIME, Check check_out >= check_in)
  - `status`: ENUM ('Present', 'Absent', 'Late', 'Half-Day')

#### 4. LeaveRequests Table
- **Purpose**: Tracks leave applications and their current status.
- **Primary Key**: `leave_id` (INT, Auto Increment)
- **Foreign Key**: `emp_id` (References `Employees(emp_id)` with `ON DELETE CASCADE`)
- **Attributes**:
  - `leave_type`: ENUM ('Sick', 'Casual', 'Earned', 'Maternity', 'Paternity', 'Unpaid')
  - `start_date`, `end_date`: NOT NULL (DATE, Check end_date >= start_date)
  - `status`: ENUM ('Pending', 'Approved', 'Rejected')
  - `applied_on`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

#### 5. EmployeeAuditLog Table (Auxiliary)
- **Purpose**: Automatically captures audit details of employee updates.
- **Primary Key**: `audit_id` (INT, Auto Increment)
- **Attributes**:
  - `emp_id` (INT, NOT NULL)
  - `action_type` (VARCHAR)
  - `old_salary`, `new_salary` (DECIMAL)
  - `old_dept_id`, `new_dept_id` (INT)
  - `changed_by` (VARCHAR)
  - `changed_at` (TIMESTAMP)

---

## 7. IMPLEMENTATION

### Database Setup
The script creates the `employee_attendance_db` database and runs definitions in sequence.

### Triggers & Business Rules
- **Overlapping Leave Check**: The `before_leave_insert` trigger checks if the employee already has an approved leave request that overlaps with the new request's date range. If an overlap is found, it raises an error.
- **Salary/Dept Audit**: The `after_employee_update` trigger listens for changes to salary or department in the `Employees` table and inserts a record in `EmployeeAuditLog` detailing the old value, new value, execution user, and timestamp.
- **Clock-out Validation**: The `before_attendance_insert` and `before_attendance_update` triggers validate that check-out times cannot be chronologically prior to check-in times.

### Stored Procedures
- `mark_attendance()`: Utilizes `INSERT ... ON DUPLICATE KEY UPDATE` to mark the check-in time and status on the first call of the day, and update the check-out time and recalculate the status (e.g. Present, Late, or Half-Day) on the second call.
- `approve_leave()`: Changes leave request status. If the status is updated to 'Approved', it runs a loop through the date range and logs daily 'Absent' (or 'On Leave') records in the `Attendance` table to keep logs consistent.

---

## 8. TESTING

### Query Test Cases
The system was validated using 30 SQL queries testing different scenarios:
- **Aggregation**: Total payroll costs, employee count per department.
- **Time Calculations**: Using `TIMEDIFF()` to calculate exact work hours per day.
- **Date Differences**: Using `DATEDIFF()` to check leave durations.
- **Join Logic**: Combining department locations, employee profiles, and attendance flags.

### Stored Procedure Validation
1. **Calling mark_attendance()**:
   ```sql
   CALL mark_attendance(1, '2026-07-20', '08:30:00', NULL);
   -- Result: Inserts attendance record for Employee 1 with status 'Present'.
   
   CALL mark_attendance(1, '2026-07-20', '08:30:00', '18:00:00');
   -- Result: Updates check_out to '18:00:00'. Status remains 'Present'.
   ```

2. **Trigger Audit Log Validation**:
   ```sql
   UPDATE Employees SET salary = 95000.00 WHERE emp_id = 1;
   SELECT * FROM EmployeeAuditLog;
   -- Result: Successfully captured old and new salary details, user, and date.
   ```

---

## 9. ADVANTAGES
- **Eliminates Human Errors**: Automatic calculation of shift status based on database rules.
- **High Data Integrity**: Multi-table relationships, constraints, and triggers ensure invalid data is rejected.
- **Data Traceability**: Full audit logs for updates on key columns.
- **Performance**: Indexes reduce response time on analytical reports.
- **Consistency**: Integrated leave approval automatically marks employee attendance.

---

## 10. LIMITATIONS
- **Single-Timezone Support**: Relies on system-wide timestamps; might require updates for multi-region teams.
- **No Direct Biometric Integration**: Requires an API middleware to sync physical fingerprint scanners/rfid directly to the database.

---

## 11. FUTURE SCOPE
- **Integration with Biometric APIs**: Write Python or Node.js scripts to pull logs from hardware scanners directly into the `mark_attendance` procedure.
- **Geofencing**: Add GPS coordinates check to the `Attendance` table to ensure employees clock-in within office premises.
- **Shift Rostering**: Support multiple shifts (e.g., Night shifts, Evening shifts) by adding a `Shifts` configuration table.

---

## 12. CONCLUSION
The **Employee Attendance Tracker** database project successfully demonstrates how relational database design principles can solve real-world organizational challenges. By adhering to 3NF normalization, creating complex triggers for date validation and auditing, and building stored procedures with `ON DUPLICATE KEY UPDATE` syntax, the project represents a robust, industry-ready backend architecture suitable for final-year college assessment.

---

## 13. REFERENCES
1. Silberschatz, A., Korth, H. F., & Sudarshan, S. (2019). *Database System Concepts* (7th ed.). McGraw-Hill.
2. MySQL 8.0 Reference Manual. Available at: https://dev.mysql.com/doc/refman/8.0/en/
3. Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of Database Systems* (7th ed.). Pearson.
