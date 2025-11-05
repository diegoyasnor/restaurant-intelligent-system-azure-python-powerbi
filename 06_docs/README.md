# 📘 Project Documentation — Restaurant Intelligence

This document provides the complete overview of the **Restaurant Intelligence Project**, developed as a full data pipeline integrating **Azure SQL, Python Automation, Power BI**, and **Logic Apps**.

---

## 🧩 1. Project Overview
The goal of this project was to design a **data-driven ecosystem** to monitor restaurant performance and optimize business decisions through automation and analytics.

It includes:
- Data cleaning and modeling in **Azure SQL**
- Revenue and inventory automation using **Python and Logic Apps**
- Real-time dashboards in **Power BI**
- Email notifications for low stock and weekly revenue summaries

---

## ☁️ 2. Cloud Architecture

```text
        +---------------------------+
        |  Azure SQL Database       |
        |  (restaurant_dw schema)   |
        +-------------+-------------+
                      |
                      v
        +---------------------------+
        |  Azure Function (Python)  |
        |  Weekly Revenue Automation|
        +-------------+-------------+
                      |
                      v
        +---------------------------+
        |  Azure Logic Apps         |
        |  (Email Notifications)    |
        +-------------+-------------+
                      |
                      v
        +---------------------------+
        |  Power BI Dashboard       |
        |  Real-Time Visualization  |
        +---------------------------+

🧱 3. Data Engineering Steps

| Step | Process              | Description                                          |
| ---- | -------------------- | ---------------------------------------------------- |
| 01   | Schema Creation      | Created `stg` and `dw` schemas in Azure SQL          |
| 02   | Data Loading         | Loaded CSV data with wizard/import tools             |
| 03   | Data Cleaning        | Removed duplicates, fixed negative prices/quantities |
| 04   | DW Views             | Built star schema and analytical views               |
| 05   | Validation           | KPI comparison, total checks                         |
| 06   | Inventory Monitoring | Under-stock alerts using Logic App                   |
| 07   | Revenue Automation   | Python + Azure Function (weekly emails)              |

🧠 4. Key Insights and Results

Identified performance differences among locations

Automated weekly reporting for management

Reduced manual Excel reporting to zero

Built scalable model for any multi-location business

📬 5. Automation Summary

| Automation        | Tool               | Frequency         | Description                                           |
| ----------------- | ------------------ | ----------------- | ----------------------------------------------------- |
| Under-stock Alert | Logic App          | Daily             | Sends email if any product < reorder level            |
| Weekly Revenue    | Python + Logic App | Every Monday 9 AM | Sends summary table of all restaurants (weekly + MTD) |


📈 6. Power BI Integration

The dashboard connects live to Azure SQL using DirectQuery mode.
KPIs and insights include:

Revenue by City, Category, and Week

Top 10 Products

Low Stock Alerts

Weekly Trend Comparison

🧩 7. Technologies Used

| Category       | Tool / Service                           |
| -------------- | ---------------------------------------- |
| Database       | Azure SQL Database                       |
| Data Modeling  | SQL (schemas, views, KPIs)               |
| Automation     | Azure Logic App, Azure Function (Python) |
| Visualization  | Power BI                                 |
| Languages      | SQL, Python, DAX                         |
| Libraries      | Pandas, PyODBC, Numpy, Matplotlib        |
| Cloud Provider | Microsoft Azure                          |

📖 8. Learnings and Challenges

Learned to integrate cloud + code + automation tools cohesively

Debugging ODBC & authentication issues between Python and Azure

Building reusable Logic Apps with parameters and secure keys

Designing business-driven metrics and dashboards

🚀 9. Future Improvements

Add Data Factory pipelines for scheduled ETL

Deploy Power BI dashboard with automatic refresh

Add sentiment analysis from customer reviews (Python NLP)

Create cost optimization insights for inventory management


👨‍💻 Author

Diego Yasno
Data Analyst | Python & Azure Automation Enthusiast
📍 Boynton Beach, FL
📧 diegoyasnor@gmail.com

🔗 LinkedIn
 | GitHub

