# Walmart Catalog Health Audit

An independent portfolio project analyzing 30,000 Walmart.com listings
observed on December 18–19, 2019. The goal is to identify which departments
and categories should be reviewed first for listing availability issues.

## Key findings

- 2,072 listings were marked unavailable (6.91%).
- Sports & Outdoors had the most unavailable listings (669). Food had 460
  unavailable listings and a higher unavailable rate (11.11% versus 6.06%).
- Within Food, Milk & Cream and Canned Meat & Poultry accounted for 93
  of the 460 unavailable listings.
- 1,551 of 29,604 listings with two positive prices had a sale price below
  list price (5.24%). The audit also flagged 396 zero-price listings and
  2 listings priced above list.

## Workflow

Excel Power Query and PivotTables established the baseline. PostgreSQL
reproduced the KPIs and category rankings. A one-page Power BI report
brings the findings together with interactive filters.

## Scope

The data is a two-day catalog snapshot. It supports prioritizing a review
of affected listings. Measuring lost sales or confirming persistent
availability issues would require additional data.

## Project Files

- [Download the Excel audit workbook](https://github.com/AdiGit420/walmart-catalog-health-audit/releases/download/v1.0/Walmart_Catalog_Audit.xlsx)
- [Download the Power BI report](https://github.com/AdiGit420/walmart-catalog-health-audit/releases/download/v1.0/Walmart_Catalog_Health.pbix)
- [View the PostgreSQL audit queries](walmart_catalog_audit.sql)
