-- ============================================================
-- File: employee_retention_analysis.sql
-- Purpose: Understand employee turnover trends and identify root causes
-- Author: Emmanuel Sekyere
-- Database: NextGen (PostgreSQL)
-- ============================================================

-- 1. Who are the top 5 highest-serving (longest-tenured) employees?
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

-- 2. What is the turnover rate for each department?
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

-- 3. Which employees are at risk of leaving based on their performance?
-- (Definition: active employees with performance score below 3.0 and/or attendance below 85%)
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

-- 4. What are the main reasons employees are leaving the company?
SELECT
    t.reason,
    COUNT(*)                                              AS number_of_employees,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)     AS pct_of_total_leavers
FROM turnover t
GROUP BY t.reason
ORDER BY number_of_employees DESC;
