# 🛒 Supermarket Sales & Performance Analysis (Advanced SQL)

## 📌 Project Overview
This project provides an end-to-end data analysis of supermarket sales, moving from raw data to actionable business insights. Using **Advanced SQL** techniques and **Power BI**, I analyzed sales performance, identified top-performing regions, and calculated complex business metrics like Year-Over-Year (YoY) growth and ABC classification.

## 🎯 Objectives
*   Analyze revenue distribution across product categories and countries.
*   Evaluate Sales Representative performance against set targets.
*   Perform time-series analysis to identify seasonality and growth trends.
*   Apply advanced statistical methods like the **Pareto Principle (ABC Analysis)**.

## 🛠 Tools & Technologies
- **Database:** MySQL (Advanced Querying)
- **Visualization:** Power BI Desktop
- **Analytics Techniques:** Window Functions, CTEs, KPI Tracking

## 📉 Data Analysis (Advanced SQL Logic)

### 1. ABC Analysis (Pareto Principle)
I categorized product categories based on their contribution to total revenue (Top 80%, Next 15%, Bottom 5%):
```sql
SELECT Product_Category, Total_Revenue,
CASE 
    WHEN Cumulative_Pct <= 80 THEN 'A (Top 80%)'
    WHEN Cumulative_Pct <= 95 THEN 'B (Next 15%)'
    ELSE 'C (Bottom 5%)'
END AS Product_Rank
FROM ABC_Subquery;
```

2. Year-Over-Year (YoY) Growth
Calculated annual revenue growth by comparing current vs. previous year using the LAG() window function:
```sql
SELECT Sales_Year, Current_Year_Revenue,
ROUND(((Current_Year_Revenue - Previous_Year_Revenue) / Previous_Year_Revenue) * 100, 2) AS YoY_Growth_Pct
FROM Yearly_Calculations;
```
### SQL Query Result Preview
![SQL YoY Analysis](../04_Screenshots/sql_advanced_yoy_growth.png)

## 📈 Interactive Dashboard View
![Supermarket Dashboard](../04_Screenshots/Supermarket_Sales_Performance_Dashboard.png)
## 🚀 Key Insights
Top Categories: Identified which products drive 80% of total revenue.
Regional Performance: Ranked top sales representatives within each country using RANK() OVER.
Profitability: Calculated estimated profit margins and identified reps who consistently underperform against targets.
## 📁 Project Structure
* 01_Data/: Raw sales datasets and cleaned final data.
* 02_SQL/: Advanced SQL scripts including Window Functions & Views.
* 03_PowerBI/: Power BI report documentation (PDF).
* 04_Screenshots/: SQL query results and Dashboard visuals.
* 05_README/: Project documentation.