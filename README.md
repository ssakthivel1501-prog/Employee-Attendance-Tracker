# Employee Attendance Tracker (DBMS Mini-Project)

A professional, normalized, and highly optimized database management system (DBMS) built in MySQL for managing department directories, employee profiles, daily shifts, and leave applications. 

This project is structured as an industry-standard database backend, featuring advanced SQL techniques including stored procedures, audit logging, custom business triggers, and performance indices.

---

## 🚀 Feature

- **3NF Normalized Schema**: Clean relational database model consisting of 4 primary tables: `Departments`, `Employees`, `Attendance`, and `LeaveRequests`, and 1 auxiliary table: `EmployeeAuditLog`.
- **Dynamic Attendance Status**: Automated check-in/out logic via stored procedures that classify employee status (`Present`, `Late`, `Half-Day`, `Absent`).
- **Overlapping Leave Prevention**: Business rules enforced via triggers to prevent employees from requesting overlapping leaves.
- **Auto-Absenteeism on Approved Leaves**: Approving leaves automatically logs 'Absent' (on leave) entries into the daily attendance table.
- **Employee Changes Audit**: Automatically logs historical changes to salaries and department assignments.
- **30 Analytics Queries**: Comprehensive query scripts demonstrating filters, groupings, joins, subqueries, and datetime math.

---

## 📂 Project Structure

```
Employee-Attendance-Tracker/
├── README.md                  # Project overview, installation steps, and schema reference
├── LICENSE                    # MIT License
├── ER_Diagram.md              # Mermaid diagram code and database relationship definitions
├── attendance_tracker.sql     # Monolithic SQL setup file (Setup, Tables, Data, Views, Triggers, Procs)
├── SampleData.sql             # Realistic mock data insertion script
├── Queries.sql                # 30 solved and explained analytic database queries
├── Procedures.sql             # Stored procedures (mark_attendance, approve_leave, summaries)
├── Triggers.sql               # Input verification and auditing triggers
├── Views.sql                  # Views (today_attendance, employee_summary_view, etc.)
└── Documentation/
    └── Project_Documentation.md # Full academic report (Abstract, Design, Testing, Conclusion)
```

---

## ⚙️ Installation & Setup (MySQL Workbench)

### Step 1: Install MySQL & MySQL Workbench
1. Download the **MySQL Installer** for Windows/macOS from the [MySQL Downloads Portal](https://dev.mysql.com/downloads/installer/).
2. Run the installer and choose **Developer Default** or install **MySQL Server** and **MySQL Workbench** manually.
3. Configure the MySQL Server root password and launch MySQL Workbench.

### Step 2: Open Connection & Load Script
1. In MySQL Workbench, create a new connection to your local database instance.
2. Go to **File -> Open SQL Script...** and select [attendance_tracker.sql](file:///attendance_tracker.sql).
3. Alternatively, if you want to run things in modular files, execute them in this order:
   1. [attendance_tracker.sql](file:///attendance_tracker.sql) (schema tables creation only)
   2. [SampleData.sql](file:///SampleData.sql) (inserts mock data)
   3. [Triggers.sql](file:///Triggers.sql) (registers triggers)
   4. [Procedures.sql](file:///Procedures.sql) (registers stored procedures)
   5. [Views.sql](file:///Views.sql) (creates database views)

### Step 3: Run the Schema Setup
1. Click the **Lightning Bolt (Execute)** button in the SQL Editor toolbar to run the loaded script.
2. Refresh the **Schemas** navigator sidebar. You will see `employee_attendance_db` successfully created with all tables, views, procedures, and triggers.

---

## 💡 Usage Examples

### 1. Clocking In/Out via Procedure
To mark an employee clock-in, call the `mark_attendance` procedure with a `check_in` time and a `NULL` `check_out` time:
```sql
-- Marks Employee 5 as present on 2026-07-20 (clock-in at 8:45 AM)
CALL mark_attendance(5, '2026-07-20', '08:45:00', NULL);
```

To update check-out on the same day, pass the check-out time:
```sql
-- Clocks out Employee 5 at 5:30 PM. The system automatically recalculates status
CALL mark_attendance(5, '2026-07-20', '08:45:00', '17:30:00');
```

### 2. Approving Leave Requests
To approve a leave request (which automatically populates daily absent records in the attendance logs):
```sql
-- Approves Leave Request ID 3
CALL approve_leave(3, 'Approved');
```

### 3. Check Audit Logs
To verify that salary updates are tracked:
```sql
-- Update salary
UPDATE Employees SET salary = 120000.00 WHERE emp_id = 5;

-- Query the audit logs
SELECT * FROM EmployeeAuditLog;
```

---

## 📊 Database Schema Reference

| Table | Primary Key | Foreign Keys | Key Constraints |
| :--- | :--- | :--- | :--- |
| **Departments** | `dept_id` | *None* | `dept_name` is UNIQUE |
| **Employees** | `emp_id` | `dept_id` | `email` & `phone` are UNIQUE |
| **Attendance** | `attendance_id` | `emp_id` | UNIQUE `(emp_id, work_date)` |
| **LeaveRequests** | `leave_id` | `emp_id` | `end_date >= start_date` |
| **EmployeeAuditLog** | `audit_id` | *None* | Logs actions, times, and users |

---

## 📷 Screenshots Placeholder
*(Screenshots of tables, views, and successful script execution inside MySQL Workbench should be added to a `Screenshots/` directory in your final submission)*

- `Screenshots/01_Schema_Created.png`
- `Screenshots/02_Mark_Attendance_Test.png`
- `Screenshots/03_Trigger_Validation_Error.png`
- `Screenshots/04_Queries_Execution.png`

---

## 🔮 Future Enhancements
1. **Biometric Integration**: Connect fingerprint / face scanners with API layers to write logs directly to the DBMS.
2. **Slack/Teams Notifications**: Hook triggers to API webhooks notifying employees when their leave request status changes.
3. **Multi-shift Schedules**: Dynamic shift setups allowing evening, night, and rotational shift adjustments.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](file:///LICENSE) file for details.

---

## 👤 Author
- **Sakthivel**
- Final Year B.Tech / B.E. Computer Science and Engineering
