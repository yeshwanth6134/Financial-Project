# =====================================================
# STREAMLIT DASHBOARD — OFFLINE (LOCAL CSV MODE)
# =====================================================

import streamlit as st
import pandas as pd
import plotly.express as px

# =====================================================
# CONFIGURATION
# =====================================================
st.set_page_config(page_title="Financial Reporting Dashboard", page_icon="💹", layout="wide")

# =====================================================
# LOAD DATA LOCALLY
# =====================================================
@st.cache_data
def load_data():
    # Load your local CSV file
    df = pd.read_csv("Data_Set.csv")

    # Clean column names (remove spaces, fix underscores)
    df.columns = [col.strip().replace(" ", "_") for col in df.columns]

    # Rename columns to expected names if needed
    df.rename(columns={
        "Market_Cap": "Market_Cap_B_USD",
        "Earning_Per_Share": "EPS",
        "Share_Holder_Equity": "Shareholder_Equity",
        "Cash_Flow_from_Operating": "CashFlow_Operating",
        "Cash_Flow_from_Investing": "CashFlow_Investing",
        "Cash_Flow_from_Financial_Activities": "CashFlow_Financing",
        "Inflation_Rate": "Inflation_Rate_US"
    }, inplace=True)

    # Drop rows missing critical financial values
    df = df.dropna(subset=["Revenue", "Net_Income"])

    # Compute derived metrics (simulate what Gold Layer views do)
    df["Gross_Margin_Percent"] = (df["Gross_Profit"] / df["Revenue"]) * 100
    df["Net_Profit_Margin_Percent"] = (df["Net_Income"] / df["Revenue"]) * 100
    df["Revenue_Growth_Percent"] = df.groupby("Company")["Revenue"].pct_change() * 100
    df["Revenue_per_Employee"] = df["Revenue"] / df["Number_of_Employees"]
    df["Net_Income_per_Employee"] = df["Net_Income"] / df["Number_of_Employees"]

    return df

df = load_data()

# =====================================================
# DASHBOARD HEADER
# =====================================================
st.title("💼 Financial Reporting Automation Dashboard")
#st.markdown("#### Data Source: Local CSV File — No BigQuery Connection Needed")

# =====================================================
# KPI SECTION
# =====================================================
st.subheader("📊 Key Financial Indicators")

total_companies = df["Company"].nunique()
total_market_cap = df["Market_Cap_B_USD"].sum()
total_revenue = df["Revenue"].sum()
avg_net_income = df["Net_Income"].mean()

col1, col2, col3, col4 = st.columns(4)
col1.metric("🏢 Total Companies", total_companies)
col2.metric("💰 Total Market Cap (B USD)", f"{total_market_cap:,.2f}")
col3.metric("📈 Total Revenue (USD)", f"{total_revenue:,.2f}")
col4.metric("🧾 Avg. Net Income (USD)", f"{avg_net_income:,.2f}")

st.markdown("---")

# =====================================================
# FILTER SECTION
# =====================================================
companies = sorted(df["Company"].unique())
categories = sorted(df["Category"].unique())

selected_company = st.selectbox("🏢 Select Company", options=companies)
selected_category = st.selectbox("🏷️ Select Category", options=categories)

df_filtered = df[
    (df["Company"] == selected_company) &
    (df["Category"] == selected_category)
]

# =====================================================
# REVENUE & PROFITABILITY METRICS
# =====================================================
st.subheader("💵 Revenue & Profitability Metrics")

fig1 = px.line(df_filtered, x="Year", y=["Revenue", "Net_Income"],
               title=f"Revenue vs Net Income ({selected_company})", markers=True)
st.plotly_chart(fig1, use_container_width=True)

col1, col2, col3 = st.columns(3)
if not df_filtered.empty:
    latest_row = df_filtered.iloc[-1]
    col1.metric("Revenue Growth %", f"{latest_row.get('Revenue_Growth_Percent', 0):.2f}%")
    col2.metric("Gross Margin %", f"{latest_row.get('Gross_Margin_Percent', 0):.2f}%")
    col3.metric("Net Profit Margin %", f"{latest_row.get('Net_Profit_Margin_Percent', 0):.2f}%")
else:
    st.warning("⚠️ No data available for the selected company/category combination.")
    col1.metric("Revenue Growth %", "N/A")
    col2.metric("Gross Margin %", "N/A")
    col3.metric("Net Profit Margin %", "N/A")

st.markdown("---")

# =====================================================
# REVENUE BY CATEGORY
# =====================================================
st.subheader("🏷️ Revenue by Category (Aggregated)")

df_cat = df.groupby("Category", as_index=False)["Revenue"].sum()
fig_cat = px.bar(df_cat, x="Category", y="Revenue", title="Revenue by Category")
st.plotly_chart(fig_cat, use_container_width=True)

st.markdown("---")

# =====================================================
# RETURN & RATIO ANALYSIS
# =====================================================
st.subheader("💹 Return and Ratio Metrics")

fig2 = px.bar(
    df[df["Company"] == selected_company],
    x="Year",
    y=["ROE", "ROA", "ROI"],
    barmode="group",
    title=f"ROE, ROA, ROI Trends ({selected_company})"
)
st.plotly_chart(fig2, use_container_width=True)

# =====================================================
# EFFICIENCY METRICS
# =====================================================
st.subheader("⚙️ Efficiency & Productivity Metrics")

fig3 = px.bar(
    df[df["Company"] == selected_company],
    x="Year",
    y=["Revenue_per_Employee", "Net_Income_per_Employee"],
    barmode="group",
    title=f"Employee Productivity ({selected_company})"
)
st.plotly_chart(fig3, use_container_width=True)

st.markdown("---")

# =====================================================
# SIMPLE REVENUE FORECAST (TREND-BASED)
# =====================================================
st.subheader("🔮 Predictive & Trend Analysis — Simple Forecast")

# Simple moving average for demonstration
df_forecast = df[df["Company"] == selected_company][["Year", "Revenue"]].copy()
df_forecast["Forecast_Year"] = df_forecast["Year"].max() + 1
df_forecast["predicted_Revenue"] = df_forecast["Revenue"].rolling(window=2).mean().iloc[-1]

fig4 = px.line(df_forecast, x="Year", y="Revenue", markers=True, title=f"Revenue Forecast ({selected_company})")
fig4.add_scatter(x=[df_forecast["Forecast_Year"].iloc[-1]], y=[df_forecast["predicted_Revenue"].iloc[-1]],
                 mode="markers+text", name="Predicted", text=["Forecast"], textposition="top center")
st.plotly_chart(fig4, use_container_width=True)

st.markdown("---")

# =====================================================
# INFLATION IMPACT
# =====================================================
st.subheader("🌍 Inflation Impact Analysis")

corr_rev = round(df["Inflation_Rate_US"].corr(df["Revenue"]), 2)
corr_net = round(df["Inflation_Rate_US"].corr(df["Net_Income"]), 2)

st.write("**Correlation between Inflation and Financial Performance**")
st.dataframe(pd.DataFrame({
    "Inflation_Revenue_Correlation": [corr_rev],
    "Inflation_Profit_Correlation": [corr_net]
}))

