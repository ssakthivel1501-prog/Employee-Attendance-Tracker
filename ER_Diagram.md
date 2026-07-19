# Entity Relationship (ER) Diagram - Employee Attendance Tracker

This document contains the Entity Relationship diagram and details the database relationships for the Employee Attendance Tracker database system.

## Mermaid ER Diagram

The following Mermaid diagram displays the tables, fields, constraints, primary keys (PK), and foreign keys (FK) that establish referential integrity.

```mermaid
erDiagram
    DEPARTMENTS ||--o{ EMPLOYEES : "has"
    EMPLOYEES ||--o{ ATTENDANCE : "registers"
    EMPLOYEES ||--o{ LEAVE_REQUESTS : "requests"
    EMPLOYEES ||--o{ EMPLOYEE_AUDIT_LOG : "triggers logging for"

    DEPARTMENTS {
        int dept_id PK "AUTO_INCREMENT"
        varchar dept_name UK "NOT NULL"
        decimal budget "CHECK >= 0"
        varchar location "NOT NULL"
    }

    EMPLOYEES {
        int emp_id PK "AUTO_INCREMENT"
        varchar first_name "NOT NULL"
        varchar last_name "NOT NULL"
        varchar email UK "NOT NULL, CHECK format"
        varchar phone UK "NOT NULL"
        date hire_date "NOT NULL"
        varchar job_title "NOT NULL"
        decimal salary "CHECK > 0"
        int dept_id FK "ON DELETE SET NULL"
    }

    ATTENDANCE {
        int attendance_id PK "AUTO_INCREMENT"
        int emp_id FK "ON DELETE CASCADE"
        date work_date "NOT NULL, UNIQUE (emp_id, work_date)"
        time check_in "NOT NULL"
        time check_out "CHECK check_out >= check_in"
        enum status "Present, Absent, Late, Half-Day"
    }

    LEAVE_REQUESTS {
        int leave_id PK "AUTO_INCREMENT"
        int emp_id FK "ON DELETE CASCADE"
        enum leave_type "Sick, Casual, Earned, Maternity, Paternity, Unpaid"
        date start_date "NOT NULL"
        date end_date "NOT NULL, CHECK end_date >= start_date"
        enum status "Pending, Approved, Rejected"
        timestamp applied_on "DEFAULT CURRENT_TIMESTAMP"
    }

    EMPLOYEE_AUDIT_LOG {
        int audit_id PK "AUTO_INCREMENT"
        int emp_id "NOT NULL"
        varchar action_type "NOT NULL"
        decimal old_salary "NULL"
        decimal new_salary "NULL"
        int old_dept_id "NULL"
        int new_dept_id "NULL"
        varchar changed_by "NOT NULL"
        timestamp changed_at "DEFAULT CURRENT_TIMESTAMP"
    }
```

## Relationships Explanation

### 1. Departments to Employees (1:N / One-to-Many)
- **Description**: A single department can have multiple employees assigned to it. An employee can belong to at most one department at any time.
- **Implementation**: The `Employees` table contains the foreign key `dept_id` referencing the `Departments` table's primary key `dept_id`.
- **Referential Integrity**: `ON DELETE SET NULL` is applied. If a department is deleted, the employees in that department will have their `dept_id` set to `NULL` (unassigned) rather than being deleted, preserving employee records.

### 2. Employees to Attendance (1:N / One-to-Many)
- **Description**: An employee can have many daily attendance records over time. Each attendance record belongs to exactly one employee.
- **Implementation**: The `Attendance` table contains the foreign key `emp_id` referencing the `Employees` table's primary key `emp_id`.
- **Referential Integrity**: `ON DELETE CASCADE` is applied. If an employee record is deleted, all their attendance history is automatically removed.
- **Unique Constraint**: The combination of `(emp_id, work_date)` is marked as `UNIQUE` to ensure an employee can have at most one attendance record per day.

### 3. Employees to Leave Requests (1:N / One-to-Many)
- **Description**: An employee can submit multiple leave requests over time. Each leave request belongs to one employee.
- **Implementation**: The `LeaveRequests` table contains the foreign key `emp_id` referencing the `Employees` table's primary key `emp_id`.
- **Referential Integrity**: `ON DELETE CASCADE` is applied. If an employee is deleted, all their associated leave requests are removed.

### 4. Employees to Employee Audit Log (1:N / One-to-Many - Conceptual Tracking)
- **Description**: Changes made to an employee's profile (like salary adjustments or department transfers) are captured in the audit log for historical tracking and compliance.
- **Implementation**: Trigger-based insertions log metadata to `EmployeeAuditLog` on modifications to the `Employees` table.
