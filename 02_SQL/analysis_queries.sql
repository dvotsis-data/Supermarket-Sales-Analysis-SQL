/* 
===============================================================================
PROJECT: HR Analytics - Employee Attrition Analysis
TOOLS: MySQL / Power BI
DESCRIPTION: Analyzing workforce data to identify turnover drivers
===============================================================================
*/

USE hrdb;

-- 1. DATA EXPLORATION
SELECT * FROM hr_data LIMIT 10;

-- 2. KEY METRICS: Total Employees & Attrition Rate
SELECT 
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate
FROM hr_data;

-- 3. ATTRITION BY AGE GROUP (Segmentation)
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 40 THEN '30-40'
        ELSE '40+'
    END AS Age_Group,
    COUNT(*) AS Total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Count
FROM hr_data
GROUP BY Age_Group;

-- 4. ATTRITION BY DEPARTMENT & JOB SATISFACTION
SELECT 
    Department,
    ROUND(AVG(JobSatisfaction), 2) AS Avg_Satisfaction,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Count
FROM hr_data
GROUP BY Department
ORDER BY Attrition_Count DESC;

-- 5. FINAL VIEW FOR POWER BI
CREATE OR REPLACE VIEW View_HR_Analysis AS
SELECT 
    EmployeeNumber, Age, Gender, Department, JobRole, MonthlyIncome,
    JobSatisfaction, Attrition,
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 40 THEN '30-40'
        ELSE '40+'
    END AS Age_Group,
    CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS Attrition_Flag
FROM hr_data;