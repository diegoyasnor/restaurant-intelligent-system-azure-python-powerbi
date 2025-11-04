# 🍽️ Restaurant Intelligent System – Azure + Python + Power BI

**End-to-end automation system** for multi-restaurant analytics  
✅ Built using **Azure SQL**, **Python (Azure Functions)**, **Logic Apps**, and **Power BI**

---

## 🚀 Overview
This project integrates **data engineering, analytics, and automation** to manage restaurant performance and operations in real time.

**Main features:**
- Weekly revenue email automation (HTML + CSV via email)
- Daily under-stock alert (Logic App, no-code)
- Power BI dashboard connected live to Azure SQL
- Data cleaning, correlation, and visualization in Python (Jupyter)

---

## 🧱 Architecture

**Flow:**
CSV → Azure SQL (star schema) → Power BI → Logic Apps / Azure Function → Email report

![Architecture](docs/architecture.png)

---

## 📊 Modules

### 1️⃣ Data Cleaning & Exploration (Python)
- Libraries: `pandas`, `numpy`, `matplotlib`, `seaborn`
- Tasks: remove duplicates, handle missing data, validate primary keys, detect outliers
- Analyses: monthly sales, top-10 products, category performance (dry goods, beverages, dairy, etc.)
- Correlation analysis: Pearson & Spearman

---

### 2️⃣ Data Modeling & Architecture (Azure SQL)
**Structured in multiple stages for scalability and clarity:**

| Step | Description |
|------|--------------|
| **01 – Schemas creation** | Created schemas: `stg` (staging), `dw` (data warehouse), `report` (presentation). |
| **02 – stg_load** | Imported raw CSVs (dim_product, dim_store, fact_sales) into staging tables. |
| **03 – cleaning_data** | Applied cleaning rules: removed nulls, negative quantities/prices, duplicates. |
| **04 – dw_views** | Built star-schema views (`dw.dim_product`, `dw.dim_store`, `dw.fact_sales`, `dw.v_fact_sales_star`). |
| **05 – validation_kpis** | Validated row counts, joins, and revenue consistency (fact vs aggregated). |
| **06 – inventory** | Developed tables for inventory and reorder-level logic. |
| **07 – dw_inventory_views** | Created reporting-friendly views for stock level analysis. |
| **08 – inventory_checks** | Added SQL scripts for automated stock validation and under-stock detection. |

**Indexes:**
- `IX_sales_store_date`
- `IX_sales_product_date`

---

### 3️⃣ Visualization & Dashboards (Power BI)
- Connected directly to Azure SQL.
- Data model: star schema (Product, Store, Sales).
- Created DAX measures for KPIs:
  - Total Revenue  
  - Top Products  
  - Revenue by Store / Category  
  - Reorder Alerts (under stock)
- Designed executive dashboard with filters by city, category, and period.

---

### 4️⃣ Automation without code (Logic Apps)
- Daily alert for restaurants below reorder level.
- Connected to Power BI dataset & Azure SQL.
- Automatic email to management every morning.

---

### 5️⃣ Automation with code (Python + Azure Function)
- Weekly revenue report every Monday (9:00 AM ET).
- Generates HTML table + CSV attached.
- Accumulates data weekly, resets monthly.
- Triggered via Logic App HTTP GET.

