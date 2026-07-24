-- ============================================================
-- File: performance_analysis.sql
-- Purpose: Evaluate employee performance across departments
-- Author: Emmanuel Sekyere
-- Database: NextGen (PostgreSQL)
-- ============================================================

-- 1. How many employees have left the company?
SELECT COUNT(*) AS employees_left
FROM turnover;

-- 2. How many employees have a performance score of 5.0 / below 3.5?
SELECT
    SUM(CASE WHEN performance_score = 5.0 THEN 1 ELSE 0 END) AS score_of_5,
    SUM(CASE WHEN performance_score < 3.5 THEN 1 ELSE 0 END) AS score_below_3_5
FROM employees;

-- 3. Which department has the most employees with a performance of 5.0 / below 3.5?
SELECT
    d.department_name,
    SUM(CASE WHEN e.performance_score = 5.0 THEN 1 ELSE 0 END) AS top_performers,
    SUM(CASE WHEN e.performance_score < 3.5 THEN 1 ELSE 0 END) AS low_performers
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY low_performers DESC, top_performers DESC;

-- 4. What is the average performance score by department?
SELECT
    d.department_name,
    ROUND(AVG(e.performance_score), 2) AS avg_performance_score,
    COUNT(e.employee_id)               AS headcount
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_performance_score DESC;
