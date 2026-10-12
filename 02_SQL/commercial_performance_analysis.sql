
-- ============================================================
-- SUPERMARKET SALES ANALYSIS
-- Commercial Performance & Sales Representative Analysis
-- ============================================================
-- Database: supermarketdb
-- Table: supermarket_sales
-- Period: 2021-2024
-- Records: 5,000
--
-- Key definitions:
-- Won Revenue       = Revenue from Won records only
-- Opportunity Value = Revenue from Opportunity records only
-- Lost Records      = Records with Stage = 'Lost'
--
-- Note:
-- Opportunity Value is not realized revenue.
-- Won record share should not be interpreted as a conversion rate.
-- ============================================================


-- ============================================================
-- 01. SALES STAGE OVERVIEW
-- ============================================================
-- Summarize record counts, revenue and target by sales stage.

SELECT
    Stage,
    COUNT(*) AS Total_Records,
    SUM(Revenue) AS Total_Revenue,
    SUM(Target) AS Total_Target
FROM supermarketdb.supermarket_sales
GROUP BY Stage
ORDER BY Stage;


-- ============================================================
-- 02. COMMERCIAL PERFORMANCE OVERVIEW
-- ============================================================
-- Calculate the main commercial KPIs used in Power BI.

SELECT
    SUM(
        CASE WHEN Stage = 'Won'
             THEN Revenue ELSE 0 END
    ) AS Won_Revenue,

    SUM(
        CASE WHEN Stage = 'Opportunity'
             THEN Revenue ELSE 0 END
    ) AS Opportunity_Value,

    SUM(
        CASE WHEN Stage = 'Won'
             THEN 1 ELSE 0 END
    ) AS Won_Records,

    SUM(
        CASE WHEN Stage = 'Opportunity'
             THEN 1 ELSE 0 END
    ) AS Opportunity_Records,

    SUM(
        CASE WHEN Stage = 'Lost'
             THEN 1 ELSE 0 END
    ) AS Lost_Records,

    COUNT(*) AS Total_Records

FROM supermarketdb.supermarket_sales;


-- ============================================================
-- 03. MONTHLY COMMERCIAL PERFORMANCE
-- ============================================================
-- Compare Won Revenue and Opportunity Value by month.

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_YearMonth,

    SUM(
        CASE WHEN Stage = 'Won'
             THEN Revenue ELSE 0 END
    ) AS Won_Revenue,

    SUM(
        CASE WHEN Stage = 'Opportunity'
             THEN Revenue ELSE 0 END
    ) AS Opportunity_Value,

    SUM(
        CASE WHEN Stage = 'Won'
             THEN 1 ELSE 0 END
    ) AS Won_Records

FROM supermarketdb.supermarket_sales

GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATE_FORMAT(Order_Date, '%Y-%m')

ORDER BY Sales_Year, Sales_Month;


-- ============================================================
-- 04. YEAR-OVER-YEAR WON REVENUE GROWTH
-- ============================================================
-- Compare each month with the same month of the previous year.
-- Uses CTEs and the LAG() window function.

WITH Monthly_Sales AS (
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,

        SUM(
            CASE WHEN Stage = 'Won'
                 THEN Revenue ELSE 0 END
        ) AS Won_Revenue

    FROM supermarketdb.supermarket_sales

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),

Sales_Comparison AS (
    SELECT
        Sales_Year,
        Sales_Month,
        Won_Revenue,

        LAG(Won_Revenue, 1) OVER (
            PARTITION BY Sales_Month
            ORDER BY Sales_Year
        ) AS Previous_Year_Revenue

    FROM Monthly_Sales
)

SELECT
    Sales_Year,
    Sales_Month,
    Won_Revenue,
    Previous_Year_Revenue,

    ROUND(
        (Won_Revenue - Previous_Year_Revenue)
        / NULLIF(Previous_Year_Revenue, 0) * 100,
        2
    ) AS YoY_Growth_Pct

FROM Sales_Comparison

ORDER BY Sales_Year, Sales_Month;


-- ============================================================
-- 05. SALES REPRESENTATIVE RANKING WITHIN EACH TEAM
-- ============================================================
-- Rank representatives by Won Revenue within each team.
-- Uses DENSE_RANK() with PARTITION BY Team.

WITH Rep_Performance AS (
    SELECT
        Team,
        Sales_Rep,

        SUM(
            CASE WHEN Stage = 'Won'
                 THEN Revenue ELSE 0 END
        ) AS Won_Revenue,

        SUM(
            CASE WHEN Stage = 'Opportunity'
                 THEN Revenue ELSE 0 END
        ) AS Opportunity_Value,

        SUM(
            CASE WHEN Stage = 'Won'
                 THEN Target ELSE 0 END
        ) AS Won_Target

    FROM supermarketdb.supermarket_sales

    GROUP BY Team, Sales_Rep
)

SELECT
    Team,
    Sales_Rep,
    Won_Revenue,
    Opportunity_Value,
    Won_Target,

    ROUND(
        Won_Revenue / NULLIF(Won_Target, 0) * 100,
        2
    ) AS Won_Revenue_vs_Target_Pct,

    DENSE_RANK() OVER (
        PARTITION BY Team
        ORDER BY Won_Revenue DESC
    ) AS Team_Rank

FROM Rep_Performance

ORDER BY Team, Team_Rank, Sales_Rep;


-- ============================================================
-- 06. OVERALL SALES REPRESENTATIVE RANKING
-- ============================================================
-- Rank representatives across all teams by Won Revenue.

WITH Rep_Performance AS (
    SELECT
        Sales_Rep,

        SUM(
            CASE WHEN Stage = 'Won'
                 THEN Revenue ELSE 0 END
        ) AS Won_Revenue,

        SUM(
            CASE WHEN Stage = 'Opportunity'
                 THEN Revenue ELSE 0 END
        ) AS Opportunity_Value

    FROM supermarketdb.supermarket_sales

    GROUP BY Sales_Rep
)

SELECT
    Sales_Rep,
    Won_Revenue,
    Opportunity_Value,

    DENSE_RANK() OVER (
        ORDER BY Won_Revenue DESC
    ) AS Overall_Rank

FROM Rep_Performance

ORDER BY Overall_Rank, Sales_Rep;


-- ============================================================
-- END OF SCRIPT
-- ============================================================
