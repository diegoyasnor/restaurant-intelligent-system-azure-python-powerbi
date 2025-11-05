# ⚙️ Logic Apps — Automation Flows

This folder contains the JSON definitions of the Logic Apps used in the project.

## Flows
1) **Weekly revenue (weekly_revenue_logicapp.json)**
   - Trigger: Recurrence (Every Monday at 09:00, America/New_York)
   - Action: HTTP GET → `https://<function>.azurewebsites.net/api/weekly_revenue?code=...`
   - Email: Office 365 / Outlook.com / Gmail connector
     - Subject: `@{coalesce(outputs('GetWeekly')?['body']?['subject'], 'Weekly Revenue Report')}`
     - Body (HTML): `@{coalesce(outputs('GetWeekly')?['body']?['html'], '<p>(no html)</p>')}`
     - Attachment name: `@{concat('weekly_revenue_', outputs('GetWeekly')?['body']?['window']?['week_start'], '_', outputs('GetWeekly')?['body']?['window']?['week_end'], '.csv')}`
     - Attachment content: `@{base64ToBinary(outputs('GetWeekly')?['body']?['csv_base64'])}`

2) **Under stock daily alert (under_stock_daily_logicapp.json)**
   - Trigger: Daily at 09:00 (America/New_York)
   - Action: Query Azure SQL / Power BI dataset for below-reorder items
   - Email: sends an HTML table with products/stores impacted

> Notes:
> - Replace the Function URL and `?code=...` with your own.
> - For Office 365 connectors, ensure the account has a valid M365 license.
