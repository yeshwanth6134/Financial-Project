CREATE OR REPLACE TABLE Silver_Layer.clean_financial_data AS
SELECT
  CAST(Year AS INT64) AS Year,
  TRIM(Company) AS Company,
  TRIM(Category) AS Category,
  SAFE_CAST(`Market_Capin_B_USD` AS FLOAT64) AS Market_Cap_B_USD,
  SAFE_CAST(Revenue AS FLOAT64) AS Revenue,
  SAFE_CAST(`Gross_Profit` AS FLOAT64) AS Gross_Profit,
  SAFE_CAST(`Net_Income` AS FLOAT64) AS Net_Income,
  SAFE_CAST(`Earning_Per_Share` AS FLOAT64) AS EPS,
  SAFE_CAST(EBITDA AS FLOAT64) AS EBITDA,
  SAFE_CAST(`Share_Holder_Equity` AS FLOAT64) AS Shareholder_Equity,
  SAFE_CAST(`Cash_Flow_from_Operating` AS FLOAT64) AS CashFlow_Operating,
  SAFE_CAST(`Cash_Flow_from_Investing` AS FLOAT64) AS CashFlow_Investing,
  SAFE_CAST(`Cash_Flow_from_Financial_Activities` AS FLOAT64) AS CashFlow_Financing,
  SAFE_CAST(`Current_Ratio` AS FLOAT64) AS Current_Ratio,
  SAFE_CAST(`DebtEquity_Ratio` AS FLOAT64) AS Debt_Equity_Ratio,
  SAFE_CAST(ROE AS FLOAT64) AS ROE,
  SAFE_CAST(ROA AS FLOAT64) AS ROA,
  SAFE_CAST(ROI AS FLOAT64) AS ROI,
  SAFE_CAST(`Net_Profit_Margin` AS FLOAT64) AS Net_Profit_Margin,
  SAFE_CAST(`Free_Cash_Flow_per_Share` AS FLOAT64) AS Free_Cash_Flow_per_Share,
  SAFE_CAST(`Return_on_Tangible_Equity` AS FLOAT64) AS Return_on_Tangible_Equity,
  SAFE_CAST(`Number_of_Employees` AS INT64) AS Number_of_Employees,
  SAFE_CAST(`Inflation_Ratein_US` AS FLOAT64) AS Inflation_Rate_US
FROM even-blueprint-441418-p2.Bronze_Layer.Raw_Financial_Data
WHERE Revenue IS NOT NULL;
