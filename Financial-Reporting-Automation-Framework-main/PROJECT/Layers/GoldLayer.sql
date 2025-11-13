CREATE OR REPLACE TABLE even-blueprint-441418-p2.Gold_Layer.dim_company AS
SELECT DISTINCT
  ROW_NUMBER() OVER() AS Company_ID,
  TRIM(Company) AS Company_Name,
  TRIM(Category) AS Category_Name
FROM even-blueprint-441418-p2.Silver_Layer.clean_financial_data;





CREATE OR REPLACE TABLE even-blueprint-441418-p2.Gold_Layer.dim_time AS
SELECT DISTINCT
  ROW_NUMBER() OVER() AS Year_ID,
  SAFE_CAST(Year AS INT64) AS Year,
  CASE 
    WHEN Year < 2020 THEN 'Pre-COVID'
    WHEN Year BETWEEN 2020 AND 2022 THEN 'Pandemic Period'
    ELSE 'Post-COVID'
  END AS Period_Label
FROM even-blueprint-441418-p2.Silver_Layer.clean_financial_data
ORDER BY Year;



CREATE OR REPLACE TABLE even-blueprint-441418-p2.Gold_Layer.dim_category AS
SELECT DISTINCT
  ROW_NUMBER() OVER() AS Category_ID,
  TRIM(Category) AS Category_Name
FROM even-blueprint-441418-p2.Silver_Layer.clean_financial_data;









CREATE OR REPLACE TABLE even-blueprint-441418-p2.Gold_Layer.fact_financial_performance AS
SELECT
  ROW_NUMBER() OVER() AS Fact_ID,
  c.Company_ID,
  t.Year_ID,
  cat.Category_ID,
  
  SAFE_CAST(f.Market_Cap_B_USD AS FLOAT64) AS Market_Cap_B_USD,
  SAFE_CAST(f.Revenue AS FLOAT64) AS Revenue,
  SAFE_CAST(f.Gross_Profit AS FLOAT64) AS Gross_Profit,
  SAFE_CAST(f.Net_Income AS FLOAT64) AS Net_Income,
  SAFE_CAST(f.EPS AS FLOAT64) AS Earnings_Per_Share,
  SAFE_CAST(f.EBITDA AS FLOAT64) AS EBITDA,
  SAFE_CAST(f.Shareholder_Equity AS FLOAT64) AS Shareholder_Equity,
  SAFE_CAST(f.CashFlow_Operating AS FLOAT64) AS CashFlow_Operating,
  SAFE_CAST(f.CashFlow_Investing AS FLOAT64) AS CashFlow_Investing,
  SAFE_CAST(f.CashFlow_Financing AS FLOAT64) AS CashFlow_Financing,
  SAFE_CAST(f.Current_Ratio AS FLOAT64) AS Current_Ratio,
  SAFE_CAST(f.Debt_Equity_Ratio AS FLOAT64) AS Debt_Equity_Ratio,
  SAFE_CAST(f.ROE AS FLOAT64) AS ROE,
  SAFE_CAST(f.ROA AS FLOAT64) AS ROA,
  SAFE_CAST(f.ROI AS FLOAT64) AS ROI,
  SAFE_CAST(f.Net_Profit_Margin AS FLOAT64) AS Net_Profit_Margin,
  SAFE_CAST(f.Free_Cash_Flow_per_Share AS FLOAT64) AS Free_Cash_Flow_per_Share,
  SAFE_CAST(f.Return_on_Tangible_Equity AS FLOAT64) AS Return_on_Tangible_Equity,
  SAFE_CAST(f.Number_of_Employees AS INT64) AS Number_of_Employees,
  SAFE_CAST(f.Inflation_Rate_US AS FLOAT64) AS Inflation_Rate_US
FROM even-blueprint-441418-p2.Silver_Layer.clean_financial_data f
JOIN even-blueprint-441418-p2.Gold_Layer.dim_company c ON f.Company = c.Company_Name
JOIN even-blueprint-441418-p2.Gold_Layer.dim_category cat ON f.Category = cat.Category_Name
JOIN even-blueprint-441418-p2.Gold_Layer.dim_time t ON f.Year = t.Year;


CREATE OR REPLACE VIEW `even-blueprint-441418-p2.Gold_Layer.vw_kpi_summary` AS
SELECT
  COUNT(DISTINCT Company_ID) AS Total_Companies,
  ROUND(SUM(Market_Cap_B_USD), 2) AS Total_Market_Cap,
  ROUND(SUM(Revenue), 2) AS Total_Revenue,
  ROUND(AVG(Net_Income), 2) AS Average_Net_Income
FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance`;



CREATE OR REPLACE VIEW `even-blueprint-441418-p2.Gold_Layer.vw_revenue_profitability` AS
SELECT
  c.Company_Name AS Company,
  cat.Category_Name AS Category,
  t.Year,
  f.Revenue,
  f.Gross_Profit,
  f.Net_Income,
  ROUND((f.Gross_Profit / NULLIF(f.Revenue, 0)) * 100, 2) AS Gross_Margin_Percent,
  ROUND((f.Net_Income / NULLIF(f.Revenue, 0)) * 100, 2) AS Net_Profit_Margin_Percent,
  ROUND(
    (f.Revenue - LAG(f.Revenue) OVER (PARTITION BY c.Company_Name ORDER BY t.Year)) /
    NULLIF(LAG(f.Revenue) OVER (PARTITION BY c.Company_Name ORDER BY t.Year), 0) * 100,
  2) AS Revenue_Growth_Percent
FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance` f
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_company` c ON f.Company_ID = c.Company_ID
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_category` cat ON f.Category_ID = cat.Category_ID
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_time` t ON f.Year_ID = t.Year_ID;



CREATE OR REPLACE VIEW `even-blueprint-441418-p2.Gold_Layer.vw_return_ratios` AS
SELECT
  c.Company_Name AS Company,
  t.Year,
  f.ROE,
  f.ROA,
  f.ROI,
  f.Debt_Equity_Ratio,
  f.Current_Ratio,
  f.Return_on_Tangible_Equity
FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance` f
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_company` c ON f.Company_ID = c.Company_ID
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_time` t ON f.Year_ID = t.Year_ID;



CREATE OR REPLACE VIEW `even-blueprint-441418-p2.Gold_Layer.vw_efficiency` AS
SELECT
  c.Company_Name AS Company,
  cat.Category_Name AS Category,
  t.Year,
  ROUND(f.Revenue / NULLIF(f.Number_of_Employees, 0), 2) AS Revenue_per_Employee,
  ROUND(f.Net_Income / NULLIF(f.Number_of_Employees, 0), 2) AS Net_Income_per_Employee
FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance` f
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_company` c ON f.Company_ID = c.Company_ID
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_category` cat ON f.Category_ID = cat.Category_ID
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_time` t ON f.Year_ID = t.Year_ID;





CREATE OR REPLACE MODEL `even-blueprint-441418-p2.Gold_Layer.revenue_forecast_model`
OPTIONS(
  model_type = 'linear_reg',
  input_label_cols = ['Revenue']
) AS
SELECT
  c.Company_Name AS Company,
  t.Year,
  f.Revenue,  
  f.Market_Cap_B_USD,
  f.Inflation_Rate_US,
  f.EBITDA,
  f.ROI
FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance` f
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_company` c ON f.Company_ID = c.Company_ID
JOIN `even-blueprint-441418-p2.Gold_Layer.dim_time` t ON f.Year_ID = t.Year_ID;




CREATE OR REPLACE VIEW `even-blueprint-441418-p2.Gold_Layer.vw_inflation_impact` AS
SELECT
  ROUND(CORR(Inflation_Rate_US, Revenue), 2) AS Inflation_Revenue_Correlation,
  ROUND(CORR(Inflation_Rate_US, Net_Income), 2) AS Inflation_Profit_Correlation
FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance`;




CREATE OR REPLACE VIEW `even-blueprint-441418-p2.Gold_Layer.vw_revenue_forecast` AS
SELECT
  Company,
  Year + 1 AS Forecast_Year,
  predicted_Revenue
FROM ML.PREDICT(
  MODEL `even-blueprint-441418-p2.Gold_Layer.revenue_forecast_model`,
  (
    SELECT
      c.Company_Name AS Company,
      t.Year,
      f.Market_Cap_B_USD,
      f.Inflation_Rate_US,
      f.EBITDA,
      f.ROI
    FROM `even-blueprint-441418-p2.Gold_Layer.fact_financial_performance` f
    JOIN `even-blueprint-441418-p2.Gold_Layer.dim_company` c ON f.Company_ID = c.Company_ID
    JOIN `even-blueprint-441418-p2.Gold_Layer.dim_time` t ON f.Year_ID = t.Year_ID
  )
);



