-- =====================================================
-- 30 USEFUL SQL QUERIES - EMPLOYEE ATTENDANCE TRACKER
-- =====================================================

USE employee_attendance_db;

-- -----------------------------------------------------
-- QUERY 1: SELECT, WHERE, and ORDER BY
-- Description: Retrieve all employees in the Engineering department (dept_id = 2) sorted by their salary in descending order.
-- -----------------------------------------------------
SELECT emp_id, first_name, last_name, job_title, salary 
FROM Employees 
WHERE dept_id = 2 
ORDER BY salary DESC;

/* Expected Output:
+--------+------------+-----------+-------------------------+-----------+
| emp_id | first_name | last_name | job_title               | salary    |
+--------+------------+-----------+-------------------------+-----------+
|      2 | Sunil      | Gavaskar  | Senior Software Engineer| 145000.00 |
|     12 | Rohan      | Saxena    | Software Engineer       |  98000.00 |
|     .. | ...        | ...       | ...                     | ...       |
+--------+------------+-----------+-------------------------+-----------+
*/


-- -----------------------------------------------------
-- QUERY 2: DISTINCT and LIMIT
-- Description: Find the top 5 highest distinct salaries in the company.
-- -----------------------------------------------------
SELECT DISTINCT salary 
FROM Employees 
ORDER BY salary DESC 
LIMIT 5;

/* Expected Output:
+-----------+
| salary    |
+-----------+
| 158000.00 |
| 154500.00 |
| 149000.00 |
| 145000.00 |
| 138000.00 |
+-----------+
*/


-- -----------------------------------------------------
-- QUERY 3: Aggregate Functions (COUNT, SUM, AVG, MIN, MAX)
-- Description: Display general company payroll statistics including total employee count, total payroll, average salary, minimum salary, and maximum salary.
-- -----------------------------------------------------
SELECT 
    COUNT(emp_id) AS total_employees,
    SUM(salary) AS total_payroll,
    ROUND(AVG(salary), 2) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM Employees;

/* Expected Output:
+-----------------+---------------+----------------+----------------+----------------+
| total_employees | total_payroll | average_salary | minimum_salary | maximum_salary |
+-----------------+---------------+----------------+----------------+----------------+
|              50 |    4875000.00 |       97500.00 |       45000.00 |      158000.00 |
+-----------------+---------------+----------------+----------------+----------------+
*/


-- -----------------------------------------------------
-- QUERY 4: GROUP BY and HAVING
-- Description: Find the departments (by ID) that have more than 4 employees and calculate their average salary, showing only those departments with an average salary greater than 85,000.
-- -----------------------------------------------------
SELECT 
    dept_id,
    COUNT(emp_id) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary
FROM Employees
GROUP BY dept_id
HAVING COUNT(emp_id) > 4 AND AVG(salary) > 85000.00
ORDER BY average_salary DESC;

/* Expected Output:
+---------+----------------+----------------+
| dept_id | employee_count | average_salary |
+---------+----------------+----------------+
|       2 |             12 |       95400.00 |
|       6 |              6 |       88000.00 |
+---------+----------------+----------------+
*/


-- -----------------------------------------------------
-- QUERY 5: INNER JOIN
-- Description: Fetch a list of all employees showing their full name, job title, department name, and its location.
-- -----------------------------------------------------
SELECT 
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.job_title,
    d.dept_name,
    d.location
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;

/* Expected Output:
+--------+---------------+-------------------+-----------------+-------------------+
| emp_id | employee_name | job_title         | dept_name       | location          |
+--------+---------------+-------------------+-----------------+-------------------+
|      1 | Aarav Sharma  | HR Specialist     | Human Resources | Mumbai, India     |
|      2 | Sunil Gavaskar| Senior Engineer   | Engineering     | Bengaluru, India  |
|    ... | ...           | ...               | ...             | ...               |
+--------+---------------+-------------------+-----------------+-------------------+
*/


-- -----------------------------------------------------
-- QUERY 6: LEFT JOIN
-- Description: Retrieve all departments, showing their name and the total number of employees working in them, including departments with 0 employees.
-- -----------------------------------------------------
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS total_employees
FROM Departments d
LEFT JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY total_employees DESC;

/* Expected Output:
+--------------------+-----------------+
| dept_name          | total_employees |
+--------------------+-----------------+
| Engineering        |              12 |
| Human Resources    |               8 |
| ...                |             ... |
+--------------------+-----------------+
*/


-- -----------------------------------------------------
-- QUERY 7: RIGHT JOIN
-- Description: Retrieve a list of all employees and their department details using RIGHT JOIN to ensure that employee records are fully queried.
-- -----------------------------------------------------
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.job_title,
    d.dept_name,
    d.location
FROM Departments d
RIGHT JOIN Employees e ON d.dept_id = e.dept_id
ORDER BY employee_name;

/* Expected Output:
+---------------+-------------------+-----------------+------------------+
| employee_name | job_title         | dept_name       | location         |
+---------------+-------------------+-----------------+------------------+
| Aarav Sharma  | HR Specialist     | Human Resources | Mumbai, India    |
| Aditi Patel   | Software Engineer | Engineering     | Bengaluru, India |
| ...           | ...               | ...             | ...              |
+---------------+-------------------+-----------------+------------------+
*/


-- -----------------------------------------------------
-- QUERY 8: SELF JOIN
-- Description: Identify pairs of employees working in the same department who share the exact same job title (excluding matching an employee with themselves).
-- -----------------------------------------------------
SELECT 
    e1.job_title,
    e1.dept_id,
    CONCAT(e1.first_name, ' ', e1.last_name) AS employee_1,
    CONCAT(e2.first_name, ' ', e2.last_name) AS employee_2
FROM Employees e1
INNER JOIN Employees e2 ON e1.dept_id = e2.dept_id 
    AND e1.job_title = e2.job_title 
    AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.job_title;

/* Expected Output:
+-------------------+---------+------------------+-----------------+
| job_title         | dept_id | employee_1       | employee_2      |
+-------------------+---------+------------------+-----------------+
| Software Engineer |       2 | Aditi Patel      | Sachin Tendulkar|
| HR Specialist     |       1 | Aarav Sharma     | Pooja Joshi     |
+-------------------+---------+------------------+-----------------+
*/


-- -----------------------------------------------------
-- QUERY 9: Subquery in SELECT
-- Description: Show each employee's salary along with the average salary of their respective department, and the difference.
-- -----------------------------------------------------
SELECT 
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.salary,
    (SELECT ROUND(AVG(s.salary), 2) FROM Employees s WHERE s.dept_id = e.dept_id) AS dept_avg_salary,
    ROUND(e.salary - (SELECT AVG(s.salary) FROM Employees s WHERE s.dept_id = e.dept_id), 2) AS diff_from_avg
FROM Employees e
ORDER BY diff_from_avg DESC;

/* Expected Output:
+--------+---------------+-----------+-----------------+---------------+
| emp_id | employee_name | salary    | dept_avg_salary | diff_from_avg |
+--------+---------------+-----------+-----------------+---------------+
|      2 | Sunil Gavaskar| 145000.00 |        95400.00 |      49600.00 |
|    ... | ...           | ...       | ...             | ...           |
+--------+---------------+-----------+-----------------+---------------+
*/


-- -----------------------------------------------------
-- QUERY 10: Subquery in WHERE (using IN)
-- Description: Find all employees who have had at least one 'Approved' leave request.
-- -----------------------------------------------------
SELECT emp_id, CONCAT(first_name, ' ', last_name) AS employee_name, job_title
FROM Employees
WHERE emp_id IN (
    SELECT DISTINCT emp_id 
    FROM LeaveRequests 
    WHERE status = 'Approved'
)
ORDER BY emp_id;

/* Expected Output:
+--------+---------------+-------------------+
| emp_id | employee_name | job_title         |
+--------+---------------+-------------------+
|      3 | Amit Verma    | Software Engineer |
|      7 | Ishan Gupta   | UX Designer       |
|    ... | ...           | ...               |
+--------+---------------+-------------------+
*/


-- -----------------------------------------------------
-- QUERY 11: Subquery in FROM (Derived Table)
-- Description: Calculate the salary range (MAX - MIN) for each department, highlighting departments with ranges larger than 50,000.
-- -----------------------------------------------------
SELECT 
    d.dept_name,
    salary_stats.min_salary,
    salary_stats.max_salary,
    (salary_stats.max_salary - salary_stats.min_salary) AS salary_spread
FROM Departments d
INNER JOIN (
    SELECT dept_id, MIN(salary) AS min_salary, MAX(salary) AS max_salary
    FROM Employees
    GROUP BY dept_id
) AS salary_stats ON d.dept_id = salary_stats.dept_id
WHERE (salary_stats.max_salary - salary_stats.min_salary) > 50000.00
ORDER BY salary_spread DESC;

/* Expected Output:
+-------------+------------+------------+---------------+
| dept_name   | min_salary | max_salary | salary_spread |
+-------------+------------+------------+---------------+
| Engineering |   45000.00 |  145000.00 |     100000.00 |
| Operations  |   52000.00 |  128000.00 |      76000.00 |
+-------------+------------+------------+---------------+
*/


-- -----------------------------------------------------
-- QUERY 12: Nested Query with EXISTS
-- Description: List all departments that have at least one employee hired after January 1, 2024.
-- -----------------------------------------------------
SELECT d.dept_id, d.dept_name, d.location
FROM Departments d
WHERE EXISTS (
    SELECT 1 
    FROM Employees e 
    WHERE e.dept_id = d.dept_id 
      AND e.hire_date > '2024-01-01'
)
ORDER BY d.dept_id;

/* Expected Output:
+---------+-------------+------------------+
| dept_id | dept_name   | location         |
+---------+-------------+------------------+
|       2 | Engineering | Bengaluru, India |
|       5 | Sales       | Mumbai, India    |
+---------+-------------+------------------+
*/


-- -----------------------------------------------------
-- QUERY 13: CASE Statement (Explicitly Added)
-- Description: Categorize employees into salary brackets (High: > 100k, Medium: 60k-100k, Low: < 60k) and display their details.
-- -----------------------------------------------------
SELECT 
    emp_id,
    CONCAT(first_name, ' ', last_name) AS employee_name,
    job_title,
    salary,
    CASE 
        WHEN salary > 100000.00 THEN 'Tier 1 (High)'
        WHEN salary BETWEEN 60000.00 AND 100000.00 THEN 'Tier 2 (Medium)'
        ELSE 'Tier 3 (Low)'
    END AS salary_tier
FROM Employees
ORDER BY salary DESC;

/* Expected Output:
+--------+---------------+--------------------+-----------+-----------------+
| emp_id | employee_name | job_title          | salary    | salary_tier     |
+--------+---------------+--------------------+-----------+-----------------+
|      2 | Sunil Gavaskar| Senior Engineer    | 145000.00 | Tier 1 (High)   |
|     12 | Rohan Saxena  | Software Engineer  |  98000.00 | Tier 2 (Medium) |
|     45 | Umesh Yadav   | Support Specialist |  48000.00 | Tier 3 (Low)    |
+--------+---------------+--------------------+-----------+-----------------+
*/


-- -----------------------------------------------------
-- QUERY 14: TIMEDIFF() function (Explicitly Added)
-- Description: Calculate the exact hours worked in a day for each attendance log where the employee has checked out.
-- -----------------------------------------------------
SELECT 
    attendance_id,
    emp_id,
    work_date,
    check_in,
    check_out,
    TIMEDIFF(check_out, check_in) AS total_hours_worked
FROM Attendance
WHERE check_out IS NOT NULL AND check_out <> '00:00:00'
ORDER BY total_hours_worked DESC
LIMIT 10;

/* Expected Output:
+---------------+--------+------------+----------+-----------+--------------------+
| attendance_id | emp_id | work_date  | check_in | check_out | total_hours_worked |
+---------------+--------+------------+----------+-----------+--------------------+
|            12 |      3 | 2026-07-12 | 08:35:00 | 18:25:00  | 09:50:00           |
|            45 |      8 | 2026-07-12 | 08:40:00 | 18:00:00  | 09:20:00           |
+---------------+--------+------------+----------+-----------+--------------------+
*/


-- -----------------------------------------------------
-- QUERY 15: DATEDIFF() function
-- Description: Calculate the duration in days for each leave request and show the employee name and leave type.
-- -----------------------------------------------------
SELECT 
    lr.leave_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    lr.leave_type,
    lr.start_date,
    lr.end_date,
    (DATEDIFF(lr.end_date, lr.start_date) + 1) AS leave_duration_days
FROM LeaveRequests lr
INNER JOIN Employees e ON lr.emp_id = e.emp_id
ORDER BY leave_duration_days DESC;

/* Expected Output:
+----------+---------------+------------+------------+------------+---------------------+
| leave_id | employee_name | leave_type | start_date | end_date   | leave_duration_days |
+----------+---------------+------------+------------+------------+---------------------+
|        5 | Sachin T.     | Sick       | 2026-07-10 | 2026-07-15 |                   6 |
|       14 | Virat Kohli   | Casual     | 2026-07-01 | 2026-07-03 |                   3 |
+----------+---------------+------------+------------+------------+---------------------+
*/


-- -----------------------------------------------------
-- QUERY 16: IFNULL() function
-- Description: List employees' check-out times, showing 'Not Clocked Out' if check_out is NULL.
-- -----------------------------------------------------
SELECT 
    a.attendance_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    a.work_date,
    a.check_in,
    IFNULL(CAST(a.check_out AS CHAR), 'Not Clocked Out') AS check_out_status,
    a.status
FROM Attendance a
INNER JOIN Employees e ON a.emp_id = e.emp_id
ORDER BY a.work_date DESC, a.check_in DESC
LIMIT 10;

/* Expected Output:
+---------------+---------------+------------+----------+------------------+---------+
| attendance_id | employee_name | work_date  | check_in | check_out_status | status  |
+---------------+---------------+------------+----------+------------------+---------+
|            99 | Hardik Pandya | 2026-07-19 | 09:05:00 | Not Clocked Out  | Present |
|            98 | Rahul Dravid  | 2026-07-18 | 08:30:00 | 17:30:00         | Present |
+---------------+---------------+------------+----------+------------------+---------+
*/


-- -----------------------------------------------------
-- QUERY 17: CURDATE() function
-- Description: Fetch all attendance records registered on the current system date.
-- -----------------------------------------------------
SELECT 
    a.attendance_id,
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    a.check_in,
    a.status
FROM Attendance a
INNER JOIN Employees e ON a.emp_id = e.emp_id
WHERE a.work_date = CURDATE();

/* Expected Output:
+---------------+--------+---------------+----------+---------+
| attendance_id | emp_id | employee_name | check_in | status  |
+---------------+--------+---------------+----------+---------+
|           101 |      5 | Rohit Sharma  | 08:45:00 | Present |
|           102 |     12 | Rohan Saxena  | 09:30:00 | Late    |
+---------------+--------+---------------+----------+---------+
*/


-- -----------------------------------------------------
-- QUERY 18: NOW() function
-- Description: Find leave requests that were applied on or before the current date and time.
-- -----------------------------------------------------
SELECT 
    leave_id,
    emp_id,
    leave_type,
    status,
    applied_on,
    TIMEDIFF(NOW(), applied_on) AS time_since_application
FROM LeaveRequests
ORDER BY applied_on DESC
LIMIT 5;

/* Expected Output:
+----------+--------+------------+---------+---------------------+------------------------+
| leave_id | emp_id | leave_type | status  | applied_on          | time_since_application |
+----------+--------+------------+---------+---------------------+------------------------+
|       20 |     14 | Casual     | Pending | 2026-07-19 10:15:00 | 07:18:43               |
+----------+--------+------------+---------+---------------------+------------------------+
*/


-- -----------------------------------------------------
-- QUERY 19: YEAR() and MONTH() functions
-- Description: Extract the year and month from employee hire dates and count how many employees were hired each year.
-- -----------------------------------------------------
SELECT 
    YEAR(hire_date) AS hire_year,
    MONTHNAME(hire_date) AS hire_month,
    COUNT(emp_id) AS hires_count
FROM Employees
GROUP BY hire_year, hire_month
ORDER BY hire_year DESC, MONTH(hire_date) DESC
LIMIT 10;

/* Expected Output:
+-----------+------------+-------------+
| hire_year | hire_month | hires_count |
+-----------+------------+-------------+
|      2025 | June       |           4 |
|      2025 | May        |           3 |
+-----------+------------+-------------+
*/


-- -----------------------------------------------------
-- QUERY 20: Complex Joins (Multi-table Join)
-- Description: Retrieve employee name, department name, check-in time, check-out time, and status along with any active leave requests applied on that day.
-- -----------------------------------------------------
SELECT 
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name,
    a.work_date,
    a.check_in,
    a.check_out,
    a.status AS attendance_status,
    lr.leave_type,
    lr.status AS leave_status
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
INNER JOIN Attendance a ON e.emp_id = a.emp_id
LEFT JOIN LeaveRequests lr ON e.emp_id = lr.emp_id 
    AND a.work_date BETWEEN lr.start_date AND lr.end_date
ORDER BY a.work_date DESC, e.emp_id
LIMIT 10;

/* Expected Output:
+--------+---------------+-----------+------------+----------+-----------+-------------------+------------+--------------+
| emp_id | employee_name | dept_name | work_date  | check_in | check_out | attendance_status | leave_type | leave_status |
+--------+---------------+-----------+------------+----------+-----------+-------------------+------------+--------------+
|      3 | Amit Verma    | Eng       | 2026-07-15 | 00:00:00 | 00:00:00  | Absent            | Sick       | Approved     |
+--------+---------------+-----------+------------+----------+-----------+-------------------+------------+--------------+
*/


-- -----------------------------------------------------
-- QUERY 21: Aggregate with HAVING (Multi-Table)
-- Description: Identify employees who have been 'Late' more than 2 times, displaying their name, department, and the count of late days.
-- -----------------------------------------------------
SELECT 
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name,
    COUNT(a.attendance_id) AS late_occurrences
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
INNER JOIN Attendance a ON e.emp_id = a.emp_id
WHERE a.status = 'Late'
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
HAVING COUNT(a.attendance_id) > 2
ORDER BY late_occurrences DESC;

/* Expected Output:
+--------+---------------+-------------+------------------+
| emp_id | employee_name | dept_name   | late_occurrences |
+--------+---------------+-------------+------------------+
|      5 | Rohit Sharma  | Engineering |                3 |
+--------+---------------+-------------+------------------+
*/


-- -----------------------------------------------------
-- QUERY 22: Subquery with ALL
-- Description: Find employees who earn more than all employees in the Finance department (dept_id = 6).
-- -----------------------------------------------------
SELECT emp_id, CONCAT(first_name, ' ', last_name) AS employee_name, salary, dept_id
FROM Employees
WHERE salary > ALL (
    SELECT salary 
    FROM Employees 
    WHERE dept_id = 6
)
ORDER BY salary DESC;

/* Expected Output:
+--------+---------------+-----------+---------+
| emp_id | employee_name | salary    | dept_id |
+--------+---------------+-----------+---------+
|      2 | Sunil Gavaskar| 145000.00 |       2 |
+--------+---------------+-----------+---------+
*/


-- -----------------------------------------------------
-- QUERY 23: Subquery with ANY
-- Description: Find employees who have checked in earlier than any check-in time recorded on a specific date (e.g. '2026-07-13').
-- -----------------------------------------------------
SELECT DISTINCT e.emp_id, CONCAT(e.first_name, ' ', e.last_name) AS employee_name, a.check_in, a.work_date
FROM Employees e
INNER JOIN Attendance a ON e.emp_id = a.emp_id
WHERE a.check_in < ANY (
    SELECT check_in 
    FROM Attendance 
    WHERE work_date = '2026-07-13' AND status = 'Late'
)
ORDER BY a.check_in;

/* Expected Output:
+--------+---------------+----------+------------+
| emp_id | employee_name | check_in | work_date  |
+--------+---------------+----------+------------+
|      3 | Amit Verma    | 08:35:00 | 2026-07-14 |
+--------+---------------+----------+------------+
*/


-- -----------------------------------------------------
-- QUERY 24: Testing/Querying database Views (today_attendance)
-- Description: Query the `today_attendance` view to find all employees who are late today.
-- -----------------------------------------------------
SELECT emp_id, employee_name, dept_name, check_in, status 
FROM today_attendance
WHERE status = 'Late';

/* Expected Output:
+--------+---------------+-------------+----------+--------+
| emp_id | employee_name | dept_name   | check_in | status |
+--------+---------------+-------------+----------+--------+
|     12 | Rohan Saxena  | Engineering | 09:30:00 | Late   |
+--------+---------------+-------------+----------+--------+
*/


-- -----------------------------------------------------
-- QUERY 25: Querying database Views (employee_summary_view)
-- Description: Use the `employee_summary_view` to find employees with an attendance rate of less than 90%.
-- -----------------------------------------------------
SELECT emp_id, employee_name, job_title, total_logged_days, attendance_rate_pct
FROM employee_summary_view
WHERE attendance_rate_pct < 90.00
ORDER BY attendance_rate_pct ASC;

/* Expected Output:
+--------+---------------+-------------------+-------------------+---------------------+
| emp_id | employee_name | job_title         | total_logged_days | attendance_rate_pct |
+--------+---------------+-------------------+-------------------+---------------------+
|      8 | Kavya Nair    | Software Engineer |                 5 |               80.00 |
+--------+---------------+-------------------+-------------------+---------------------+
*/


-- -----------------------------------------------------
-- QUERY 26: Querying database Views (department_attendance)
-- Description: Fetch daily attendance percentages for the Engineering department from the `department_attendance` view.
-- -----------------------------------------------------
SELECT work_date, total_department_employees, present_count, daily_attendance_pct
FROM department_attendance
WHERE dept_name = 'Engineering'
ORDER BY work_date DESC;

/* Expected Output:
+------------+------------------------------+---------------+----------------------+
| work_date  | total_department_employees   | present_count | daily_attendance_pct |
+------------+------------------------------+---------------+----------------------+
| 2026-07-14 |                           12 |            11 |                91.67 |
+------------+------------------------------+---------------+----------------------+
*/


-- -----------------------------------------------------
-- QUERY 27: Finding Department-wise Highest Paid Employees (Nested Query)
-- Description: Display the employee who earns the maximum salary in each department.
-- -----------------------------------------------------
SELECT e.dept_id, d.dept_name, e.emp_id, CONCAT(e.first_name, ' ', e.last_name) AS employee_name, e.salary
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
WHERE e.salary = (
    SELECT MAX(salary) 
    FROM Employees s 
    WHERE s.dept_id = e.dept_id
)
ORDER BY e.dept_id;

/* Expected Output:
+---------+-----------------+--------+---------------+-----------+
| dept_id | dept_name       | emp_id | employee_name | salary    |
+---------+-----------------+--------+---------------+-----------+
|       1 | Human Resources |      1 | Aarav Sharma  |  82000.00 |
|       2 | Engineering     |      2 | Sunil Gavaskar| 145000.00 |
+---------+-----------------+--------+---------------+-----------+
*/


-- -----------------------------------------------------
-- QUERY 28: String Pattern Matching (LIKE)
-- Description: Find all employees whose emails contain 'corp.com' and whose first names start with the letter 'S'.
-- -----------------------------------------------------
SELECT emp_id, CONCAT(first_name, ' ', last_name) AS employee_name, email
FROM Employees
WHERE email LIKE 's%@corp.com'
ORDER BY employee_name;

/* Expected Output:
+--------+------------------+------------------------+
| emp_id | employee_name    | email                  |
+--------+------------------+------------------------+
|     23 | Sachin Tendulkar | sachin.tendulkar@corp.com|
|     16 | Sneha Kulkarni   | sneha.kulkarni@corp.com|
+--------+------------------+------------------------+
*/


-- -----------------------------------------------------
-- QUERY 29: Date calculation with DATE_SUB and CURDATE
-- Description: List employees who were hired in the last 2 years.
-- -----------------------------------------------------
SELECT emp_id, CONCAT(first_name, ' ', last_name) AS employee_name, hire_date, job_title
FROM Employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
ORDER BY hire_date DESC;

/* Expected Output:
+--------+---------------+------------+-------------------+
| emp_id | employee_name | hire_date  | job_title         |
+--------+---------------+------------+-------------------+
|     48 | Mayank A.     | 2025-05-10 | Software Engineer |
+--------+---------------+------------+-------------------+
*/


-- -----------------------------------------------------
-- QUERY 30: Complex Leave Aggregator Query
-- Description: Find employees who have spent more than 5 days on approved leaves.
-- -----------------------------------------------------
SELECT 
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name,
    SUM(DATEDIFF(lr.end_date, lr.start_date) + 1) AS total_leave_days_taken
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id
INNER JOIN LeaveRequests lr ON e.emp_id = lr.emp_id
WHERE lr.status = 'Approved'
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
HAVING total_leave_days_taken > 5
ORDER BY total_leave_days_taken DESC;

/* Expected Output:
+--------+---------------+-------------+-------------------------+
| emp_id | employee_name | dept_name   | total_leave_days_taken  |
+--------+---------------+-------------+-------------------------+
|      3 | Amit Verma    | Engineering |                       8 |
+--------+---------------+-------------+-------------------------+
*/
