CREATE SCHEMA IF NOT EXISTS even-blueprint-441418-p2.Bronze_Layer
OPTIONS(location = "US");

CREATE OR REPLACE TABLE even-blueprint-441418-p2.Bronze_Layer.Raw_Financial_Data (
  Year STRING,
  Company STRING,
  Category STRING,
  Market_Capin_B_USD STRING,
  Revenue STRING,
  Gross_Profit STRING,
  Net_Income STRING,
  Earning_Per_Share STRING,
  EBITDA STRING,
  Share_Holder_Equity STRING,
  Cash_Flow_from_Operating STRING,
  Cash_Flow_from_Investing STRING,
  Cash_Flow_from_Financial_Activities STRING,
  Current_Ratio STRING,
  DebtEquity_Ratio STRING,
  ROE STRING,
  ROA STRING,
  ROI STRING,
  Net_Profit_Margin STRING,
  Free_Cash_Flow_per_Share STRING,
  Return_on_Tangible_Equity STRING,
  Number_of_Employees STRING,
  Inflation_Ratein_US STRING
);

LOAD DATA INTO even-blueprint-441418-p2.Bronze_Layer.Raw_Financial_Data
FROM FILES (
  format = 'CSV',
  uris = ['gs://your-bucket/path/to/financial_data.csv']
);

SELECT
  COUNT(*) AS raw_rows,
  COUNT(DISTINCT Company) AS distinct_companies
FROM even-blueprint-441418-p2.Bronze_Layer.Raw_Financial_Data;
