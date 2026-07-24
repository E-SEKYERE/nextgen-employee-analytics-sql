# 📊 NextGen Corp. Employee Success Analytics — SQL Capstone Project

![Turnover by Department](screenshots/turnover_by_department.png)

## 📌 Project Summary
NextGen Corp. is a growing technology company facing rising concerns around employee turnover, inconsistent performance tracking, and salary disparities across departments. This project uses SQL (PostgreSQL) to analyse employee, performance, attendance, turnover, and salary data to help the HR department identify retention risks, evaluate performance trends, and ensure fair, data-driven compensation.

## 🛠️ Tools Used
- **PostgreSQL** — database restoration and querying
- **SQL** — data extraction, aggregation, and analysis

## 📂 Data Description
The database contains six tables:
- **Employees** — name, job title, hire date, salary, performance score, attendance rate, department
- **Departments** — department list (Engineering, Sales, HR, Marketing, Finance)
- **Performance** — monthly performance scores per employee
- **Attendance** — daily present/absent records
- **Turnover** — employees who left, with reason for leaving
- **Salaries** — historical salary changes per employee

## 1️⃣ Employee Retention Analysis
**Goal:** Understand turnover trends and identify root causes of high turnover.

```sql
-- Top 5 highest-serving (longest-tenured) employees
SELECT
    e.employee_id,
    e.name,
    d.department_name,
    e.hire_date,
    ROUND((CURRENT_DATE - e.hire_date) / 365.25, 1) AS years_of_service
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY e.hire_date ASC
LIMIT 5;

<img width="1483" height="509" alt="image" src="https://github.com/user-attachments/assets/f636012d-8a57-4359-9a3f-95766b0c5097" />

-- Turnover rate for each department
SELECT
    d.department_name,
    COUNT(DISTINCT e.employee_id)                                   AS total_employees,
    COUNT(DISTINCT t.employee_id)                                   AS employees_left,
    ROUND(
        100.0 * COUNT(DISTINCT t.employee_id)
        / NULLIF(COUNT(DISTINCT e.employee_id), 0), 1
    )                                                                AS turnover_rate_pct
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN turnover t ON e.employee_id = t.employee_id
GROUP BY d.department_name
ORDER BY turnover_rate_pct DESC;

-- Employees at risk of leaving (low performance and/or low attendance)
SELECT
    e.employee_id,
    e.name,
    d.department_name,
    e.performance_score,
    e.attendance_rate
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.is_active = 1
  AND (e.performance_score < 3.0 OR e.attendance_rate < 85)
ORDER BY e.performance_score ASC;

-- Main reasons employees are leaving
SELECT
    t.reason,
    COUNT(*)                                              AS number_of_employees,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)     AS pct_of_total_leavers
FROM turnover t
GROUP BY t.reason
ORDER BY number_of_employees DESC;
```

![Top 5 Longest-Serving Employees](screenshots/top5_tenure.png)

**Key insights:**
- [Finding 1 — e.g. which department has the highest turnover rate and by how much]
- [Finding 2 — e.g. common reason(s) employees are leaving]
- [Finding 3 — e.g. pattern linking low performance/attendance to at-risk employees]

---

## 2️⃣ Performance Analysis
**Goal:** Evaluate performance across departments and identify areas for improvement.

```sql
-- Number of employees who left the company
SELECT COUNT(*) AS employees_left
FROM turnover;

-- Employees with a performance score of 5.0 / below 3.5
SELECT
    SUM(CASE WHEN performance_score = 5.0 THEN 1 ELSE 0 END) AS score_of_5,
    SUM(CASE WHEN performance_score < 3.5 THEN 1 ELSE 0 END) AS score_below_3_5
FROM employees;

-- Department with the most employees scoring 5.0 / below 3.5
SELECT
    d.department_name,
    SUM(CASE WHEN e.performance_score = 5.0 THEN 1 ELSE 0 END) AS top_performers,
    SUM(CASE WHEN e.performance_score < 3.5 THEN 1 ELSE 0 END) AS low_performers
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY low_performers DESC, top_performers DESC;

-- Average performance score by department
SELECT
    d.department_name,
    ROUND(AVG(e.performance_score), 2) AS avg_performance_score,
    COUNT(e.employee_id)               AS headcount
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_performance_score DESC;
```

![Average Performance Score by Department](screenshots/performance_distribution.png)

**Key insights:**
- [Finding 1 — e.g. department with strongest/weakest average performance]
- [Finding 2 — e.g. concentration of low performers in a specific department]
- [Finding 3 — recommendation for HR]

---

## 3️⃣ Salary Analysis
**Goal:** Analyse salary distribution and ensure fair compensation based on performance and departmental benchmarks.

```sql
-- Total salary expense for the company
SELECT
    ROUND(SUM(salary), 2) AS total_salary_expense
FROM employees;

-- Average salary by job title
SELECT
    job_title,
    COUNT(*)               AS headcount,
    ROUND(AVG(salary), 2)  AS avg_salary
FROM employees
GROUP BY job_title
ORDER BY avg_salary DESC;

-- Employees earning above 80,000
SELECT
    COUNT(*) AS employees_above_80k
FROM employees
WHERE salary > 80000;

-- Correlation between performance and salary across departments
SELECT
    d.department_name,
    ROUND(AVG(e.performance_score), 2) AS avg_performance,
    ROUND(AVG(e.salary), 2)            AS avg_salary,
    ROUND(
        (AVG(e.performance_score * e.salary) - AVG(e.performance_score) * AVG(e.salary))
        / NULLIF(
            (SQRT(AVG(e.performance_score * e.performance_score) - AVG(e.performance_score) * AVG(e.performance_score))
             * SQRT(AVG(e.salary * e.salary) - AVG(e.salary) * AVG(e.salary))), 0
        ), 3
    ) AS performance_salary_correlation
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY performance_salary_correlation DESC;
```

![Average Salary vs Performance by Department](screenshots/salary_vs_performance.png)

**Key insights:**
- [Finding 1 — e.g. total salary expense figure]
- [Finding 2 — e.g. whether high performers are consistently paid more]
- [Finding 3 — e.g. any departments where pay doesn't track performance]

---

## 🚀 How to Use
1. Download the NextGen database file and restore it into PostgreSQL:
   ```
   createdb NextGen
   pg_restore -d NextGen path/to/database_file
   ```
2. Run the queries in the `sql/` folder against the `NextGen` database:
   - `sql/employee_retention_analysis.sql`
   - `sql/performance_analysis.sql`
   - `sql/salary_analysis.sql`
3. Review the accompanying presentation (`NextGen_Capstone_Presentation.pdf`) for the full write-up of insights and recommendations.

## ✅ Conclusion & Recommendations
[Summarise the 2–3 most important, actionable recommendations for NextGen Corp.'s HR department based on the retention, performance, and salary findings above.]

---
*Built by Emmanuel Sekyere*
