-- ============================================================
-- File: salary_analysis.sql
-- Purpose: Analyse salary distribution and ensure fair compensation
-- Author: Emmanuel Sekyere
-- Database: NextGen (PostgreSQL)
-- ============================================================

-- 1. What is the total salary expense for the company?
SELECT
    ROUND(SUM(salary), 2) AS total_salary_expense
FROM employees;

-- 2. What is the average salary by job title?
SELECT
    job_title,
    COUNT(*)               AS headcount,
    ROUND(AVG(salary), 2)  AS avg_salary
FROM employees
GROUP BY job_title
ORDER BY avg_salary DESC;

-- 3. How many employees earn above 80,000?
SELECT
    COUNT(*) AS employees_above_80k
FROM employees
WHERE salary > 80000;

-- 4. How does performance correlate with salary across departments?
SELECT
    d.department_name,
    ROUND(AVG(e.performance_score), 2)                                  AS avg_performance,
    ROUND(AVG(e.salary), 2)                                             AS avg_salary,
    ROUND(
        (AVG(e.performance_score * e.salary) - AVG(e.performance_score) * AVG(e.salary))
        / NULLIF(
            (SQRT(AVG(e.performance_score * e.performance_score) - AVG(e.performance_score) * AVG(e.performance_score))
             * SQRT(AVG(e.salary * e.salary) - AVG(e.salary) * AVG(e.salary))), 0
        ), 3
    )                                                                    AS performance_salary_correlation
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY performance_salary_correlation DESC;
