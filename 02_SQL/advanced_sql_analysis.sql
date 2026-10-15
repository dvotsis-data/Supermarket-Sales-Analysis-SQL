
-- ============================================================
-- SUPERMARKET SALES ANALYSIS
-- Advanced SQL & Additional Business Analysis
-- ============================================================
-- Database: supermarketdb
-- Table: supermarket_sales
-- Period: 2021-2024
--
-- Won Revenue = Revenue where Stage = 'Won'
-- Opportunity Value is not realized revenue.
-- ============================================================


-- ============================================================
-- 01. REVENUE BY PRODUCT CATEGORY
-- ============================================================

SELECT
    Product_Category,
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Stage = 'Won'
        THEN Revenue ELSE 0 END) AS Won_Revenue
FROM supermarketdb.supermarket_sales
GROUP BY Product_Category
ORDER BY Won_Revenue DESC;


-- ============================================================
-- 02. SALES PERFORMANCE BY COUNTRY
-- ============================================================

SELECT
    Country,
    SUM(CASE WHEN Stage = 'Won'
        THEN Revenue ELSE 0 END) AS Won_Revenue,
    SUM(CASE WHEN Stage = 'Opportunity'
        THEN Revenue ELSE 0 END) AS Opportunity_Value,
    SUM(CASE WHEN Stage = 'Won'
        THEN Units_Sold ELSE 0 END) AS Won_Units
FROM supermarketdb.supermarket_sales
GROUP BY Country
ORDER BY Won_Revenue DESC;


-- ============================================================
-- 03. SALES REPRESENTATIVES BELOW TARGET
-- ============================================================
-- Compare Won Revenue with targets attached to Won records.

WITH Rep_Targets AS (
    SELECT
        Sales_Rep,
        SUM(CASE WHEN Stage = 'Won'
            THEN Revenue ELSE 0 END) AS Won_Revenue,
        SUM(CASE WHEN Stage = 'Won'
            THEN Target ELSE 0 END) AS Won_Target
    FROM supermarketdb.supermarket_sales
    GROUP BY Sales_Rep
)
SELECT
    Sales_Rep,
    Won_Revenue,
    Won_Target,
    ROUND(
        Won_Revenue / NULLIF(Won_Target, 0) * 100,
        2
    ) AS Target_Achievement_Pct
FROM Rep_Targets
WHERE Won_Target > 0
  AND Won_Revenue < Won_Target
ORDER BY Target_Achievement_Pct ASC;


-- ============================================================
-- 04. MONTHLY RUNNING TOTAL OF WON REVENUE
-- ============================================================
-- Aggregate monthly revenue before calculating running totals.

WITH Monthly_Revenue AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m') AS Year_Month,
        SUM(CASE WHEN Stage = 'Won'
            THEN Revenue ELSE 0 END) AS Won_Revenue
    FROM supermarketdb.supermarket_sales
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)
SELECT
    Year_Month,
    Won_Revenue,
    SUM(Won_Revenue) OVER (
        ORDER BY Year_Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Cumulative_Won_Revenue
FROM Monthly_Revenue
ORDER BY Year_Month;


-- ============================================================
-- 05. TOP SALES REPRESENTATIVE BY COUNTRY
-- ============================================================
-- RANK() retains ties for first place.

WITH Country_Rep_Revenue AS (
    SELECT
        Country,
        Sales_Rep,
        SUM(CASE WHEN Stage = 'Won'
            THEN Revenue ELSE 0 END) AS Won_Revenue
    FROM supermarketdb.supermarket_sales
    GROUP BY Country, Sales_Rep
),
Ranked_Reps AS (
    SELECT
        Country,
        Sales_Rep,
        Won_Revenue,
        RANK() OVER (
            PARTITION BY Country
            ORDER BY Won_Revenue DESC
        ) AS Country_Rank
    FROM Country_Rep_Revenue
)
SELECT
    Country,
    Sales_Rep,
    Won_Revenue,
    Country_Rank
FROM Ranked_Reps
WHERE Country_Rank = 1
ORDER BY Country, Sales_Rep;


-- ============================================================
-- 06. ABC ANALYSIS BY PRODUCT CATEGORY
-- ============================================================
-- Rank categories by realized Won Revenue.
-- A: categories up to the 80% cumulative threshold,
--    including the category that crosses the threshold.
-- B: subsequent categories up to 95%.
-- C: remaining categories.
-- This is a documented threshold-crossing convention.

WITH Category_Revenue AS (
    SELECT
        Product_Category,
        SUM(CASE WHEN Stage = 'Won'
            THEN Revenue ELSE 0 END) AS Won_Revenue
    FROM supermarketdb.supermarket_sales
    GROUP BY Product_Category
),
Cumulative_Revenue AS (
    SELECT
        Product_Category,
        Won_Revenue,
        SUM(Won_Revenue) OVER (
            ORDER BY Won_Revenue DESC, Product_Category
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Running_Revenue,
        SUM(Won_Revenue) OVER () AS Total_Revenue
    FROM Category_Revenue
),
ABC_Percentages AS (
    SELECT
        Product_Category,
        Won_Revenue,
        ROUND(
            Running_Revenue /
            NULLIF(Total_Revenue, 0) * 100,
            2
        ) AS Cumulative_Pct,
        (Running_Revenue - Won_Revenue) /
            NULLIF(Total_Revenue, 0) * 100
            AS Previous_Cumulative_Pct
    FROM Cumulative_Revenue
)
SELECT
    Product_Category,
    Won_Revenue,
    Cumulative_Pct,
    CASE
        WHEN Previous_Cumulative_Pct < 80 THEN 'A'
        WHEN Previous_Cumulative_Pct < 95 THEN 'B'
        ELSE 'C'
    END AS ABC_Class
FROM ABC_Percentages
ORDER BY Won_Revenue DESC, Product_Category;


-- ============================================================
-- 07. SALES DEAL SIZE SEGMENTATION
-- ============================================================
-- Thresholds are illustrative, not statistically optimized.

SELECT
    Order_ID,
    Stage,
    Revenue,
    CASE
        WHEN Revenue > 50000 THEN 'High Value'
        WHEN Revenue >= 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Deal_Size_Category
FROM supermarketdb.supermarket_sales
WHERE Stage = 'Won'
ORDER BY Revenue DESC;


-- ============================================================
-- 08. VIEW FOR ADDITIONAL SALES ANALYSIS
-- ============================================================
-- A reusable view with descriptive fields and Won Revenue.
-- Does not assume an unsupported profit margin.

CREATE OR REPLACE VIEW
    supermarketdb.view_advanced_sales_analysis AS
SELECT
    Order_ID,
    Order_Date,
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    Product_Category,
    Country,
    Sales_Rep,
    Team,
    Stage,
    Revenue,
    Target,
    Units_Sold,
    CASE WHEN Stage = 'Won'
        THEN Revenue ELSE 0 END AS Won_Revenue,
    CASE WHEN Stage = 'Opportunity'
        THEN Revenue ELSE 0 END AS Opportunity_Value,
    CASE WHEN Stage = 'Won'
        THEN Units_Sold ELSE 0 END AS Won_Units
FROM supermarketdb.supermarket_sales;


-- ============================================================
-- 09. VIEW VALIDATION
-- ============================================================

SELECT *
FROM supermarketdb.view_advanced_sales_analysis
LIMIT 10;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
