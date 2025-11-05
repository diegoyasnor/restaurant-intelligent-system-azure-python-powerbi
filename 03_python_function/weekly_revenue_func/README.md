# 🐍 Azure Function: Weekly Revenue Automation

This folder contains the Python **Azure Function** responsible for generating and exposing the **weekly revenue report** for all restaurants.  
It connects directly to the **Azure SQL Database**, calculates weekly and monthly accumulated revenue, and returns the data in JSON and CSV formats through an HTTP endpoint consumed by **Azure Logic Apps**.

---

## ⚙️ Function Overview

| File | Description |
|------|--------------|
| **function_app.py** | Main application logic using the Azure Functions Python SDK. |
| **function.json** | Defines HTTP trigger bindings and routes (`/api/weekly_revenue`). |
| **host.json** | Configuration file for runtime and logging settings. |
| **requirements.txt** | Python dependencies (`azure-functions`, `pyodbc`, `pandas`, `datetime`, etc.). |

---

## 🚀 Local Testing

### 1️⃣ Install dependencies
```bash
pip install -r requirements.txt
