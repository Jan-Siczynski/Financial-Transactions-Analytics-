# 💳 Financial Transactions Analytics

A SQL portfolio project analyzing real-world banking data from a financial institution, covering customer behavior, fraud detection, credit risk, and payment patterns.

---

## 📌 Project Overview

This project explores a comprehensive financial dataset spanning the 2010s decade. The goal is to answer key business questions relevant to banking analytics — from identifying peak transaction periods to evaluating credit risk and fraud exposure.

The project demonstrates proficiency in advanced SQL techniques including **JOINs**, **CTEs**, **CASE WHEN**, **Window Functions**, and **type casting** on a real-world PostgreSQL database.

---

## 🗃️ Dataset

**Source:** [Kaggle — Financial Transactions Dataset (CaixaBank)](https://www.kaggle.com/datasets/computingvictor/transactions-fraud-datasets)

**Created by:** CaixaBank Tech for the 2024 AI Hackathon

**Size:** ~365 MB | Time period: 2010s decade

### Tables

| Table | Description |
|-------|-------------|
| `transactions_data` | Transaction records including amounts, dates, merchant info, and payment method |
| `users_data` | Customer demographics, income, debt, and credit score |
| `cards_data` | Card details including brand, type, and credit limits |
| `fraud_labels` | Binary fraud classification per transaction (Yes/No) |
| `mcc_codes` | Merchant Category Codes — maps MCC codes to business category names |

---

## ❓ Business Questions

| # | Question | SQL Techniques |
|---|----------|---------------|
| Q1 | Which month generates the highest transaction volume? | `EXTRACT`, `GROUP BY` |
| Q2 | Which merchant categories generate the highest total revenue? | `JOIN`, `GROUP BY` |
| Q3 | Does a lower credit score correlate with higher fraud rate? | `CASE WHEN`, `JOIN` |
| Q4 | Does credit score influence the assigned credit limit? | `CASE WHEN`, `JOIN`, `HAVING` |
| Q5 | Which 100 customers have the highest debt-to-income ratio? | `CTE`, `NULLIF` |
| Q6 | What is the share of each payment method in total transactions? | `CASE WHEN`, Window Function |
| Q7 | What is the total credit limit by card brand and type? | `GROUP BY` |
| Q8 | How is customer debt distributed across 4 US geographic regions? | `CTE`, `CASE WHEN`, `JOIN` |
| Q9 | Does years until retirement influence average transaction amount? | `CTE`, `CASE WHEN`, `JOIN` |
| Q10 | What % of annual income did customers spend in 2010? | `CTE`, `RANK()`, `JOIN` |

---

## 🛠️ Technologies

- **Database:** PostgreSQL 16
- **IDE:** DataGrip
- **Visualization:** Power BI Desktop
- **Data Conversion:** Python (JSON → CSV for fraud labels)

---

## 📁 Project Structure

```
├── /sql
│   └── queries.sql          # All 10 SQL queries with comments
├── /images
│   └── dashboard.png        # Power BI dashboard screenshots
├── /data
│   └── source.md            # Dataset source and description
└── README.md
```

---

## 🚀 How to Run

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/computingvictor/transactions-fraud-datasets)
2. Convert `train_fraud_labels.json` to CSV using the Python script:
```python
import json, csv

with open('train_fraud_labels.json', 'r') as f:
    data = json.load(f)

with open('fraud_labels.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['transaction_id', 'fraud'])
    for transaction_id, label in data['target'].items():
        writer.writerow([transaction_id, label])
```
3. Import all CSV files into PostgreSQL using DataGrip
4. Run queries from `/sql/queries.sql`
5. Connect Power BI to PostgreSQL and build visualizations

---

## 📊 Power BI Dashboard

> *Screenshots will be added after dashboard completion*

---

## 👤 Author

**Jan Siczyński**
- GitHub: [Jan-Siczynski](https://github.com/Jan-Siczynski)
- LinkedIn: [jan-siczyński](https://www.linkedin.com/in/jan-siczyński-1b245a387/)

