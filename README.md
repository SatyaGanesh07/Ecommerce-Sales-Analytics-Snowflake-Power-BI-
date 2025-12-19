# Ecommerce Sales Analytics (Snowflake + Power BI ) 
### End-to-End Analytics Project | Snowflake + Power BI

**Enterprise-style BI solution demonstrating complete data pipeline:  
CSV → Snowflake Data Warehouse → Power BI Semantic Model → Interactive Dashboard**

--- 

#### 🔗 Live Dashboard
Explore the interactive dashboard here:
👉 [  View   ](https://app.powerbi.com/view?r=eyJrIjoiNDMzMDk5NjMtM2Y1ZC00MTU1LTkzNTQtMjEzNWJkYTM5ZjJmIiwidCI6ImRjODhkNWNiLWMxMjEtNDUzYi1hMGRiLTFmMzlmYjEyMjJiMyJ9)
***
## About This Project

This project is an **end-to-end ecommerce analytics solution** built using **Snowflake as the cloud data warehouse** and **Power BI for reporting and visualization**.

The objective was not only to create a dashboard, but to design an **industry-aligned BI workflow** — starting from raw CSV ingestion, applying data quality checks and transformations in Snowflake, building a star schema, and finally delivering business insights through Power BI.

Unlike a dashboard-only project, this solution explicitly separates:

* **Data engineering (Snowflake)**
* **Semantic modeling (Power BI)**
* **Business analytics & visualization**

The result is a scalable, auditable, and BI-ready analytics pipeline similar to real-world enterprise setups.

***

## Problem Statement

The e-commerce industry operates in a highly dynamic environment where sales trends, customer satisfaction, order volumes, and delivery performance fluctuate continuously. Without a centralized and reliable analytics system, organizations struggle to gain timely and accurate insights, leading to delayed or suboptimal strategic decisions.

E-commerce businesses generate large volumes of transactional data; however, when this data is fragmented, inconsistent, or poorly modeled, it becomes difficult to:
- Trust revenue numbers due to data inconsistencies  
- Analyze performance across customer gender, order channels, and geography  
- Measure delivery efficiency and its impact on customer satisfaction  
- Track growth trends weekly and monthly  

The core challenge addressed in this project was to design a scalable, trustworthy analytics foundation backed by a cloud data warehouse, and to deliver an executive-ready Power BI dashboard that enables data-driven decision-making across the organization.

***

## Objectives
- Build a **Snowflake-based data warehouse** from raw CSV data  
- Apply **data validation, cleansing, and transformation logic** in SQL  
- Design a **star schema (Fact + Dimensions)** optimized for BI reporting  
- Connect Power BI to Snowflake using **Import Mode**  
- Create **business KPIs using DAX**  
- Deliver a clean, interactive dashboard for decision-makers  

***
##  Architecture (End-to-End Flow)

```
CSV Files
   ↓
Snowflake (RAW → STAGING → CLEAN → DIM / FACT)
   ↓
Power BI (Import Mode)
   ↓
Business Dashboards & KPIs
```

![image alt](https://github.com/SatyaGanesh07/Ecommerce-Sales-Analytics-Snowflake-Power-BI-/blob/b0e6616868c4ab217cc84acae399324ef1c29f17/Snowflake%20to%20power%20bi.jpeg)

## End-to-End Methodology 
### Data Ingestion (CSV → Snowflake)
- Raw ecommerce CSV files loaded into Snowflake
- Source data preserved without modification

### Data Quality & Validation (Snowflake SQL)
- Duplicate transaction checks
- Revenue mismatch validation (`quantity × unit_price ≠ amount`)
- Invalid delivery days detection
- Rating range validation (1–5)

### Data Transformation & Cleansing
- Standardized text fields (gender, order mode, state, county)
- Derived metrics such as:
  - `days_to_deliver`
  - `order_value_band`
  - `delivery_category`
- Filtered invalid records (negative quantity, invalid dates)

### Dimensional Modeling (Star Schema)
- **Fact Table:** `fct_ecommerce`
- **Dimensions:**  
  - `dim_product`  
  - `dim_customer`  
  - `dim_location`

***

## Snowflake Architecture 

**Warehouse Design:**
- Database: `ecommerce_db`
- Schema: `analytics`
- Layers:
  - `raw_ecommerce` (raw ingestion)
  - `stg_ecommerce` (standardization)
  - `cln_ecommerce` (analytics-ready)
  - Dimensions & Fact tables

---
## Dashboard Features

- **KPI Cards:** Total orders, total quantity, total amount, average days to deliver, and average rating.
- **Sales Trends:** Line chart showing order and amount trends over 13 weeks.
- **Order Mode Breakdown:** Pie and bar charts illustrating sales by channel and customer gender.
- **Product Popularity:** Horizontal bar visual ranking products by total sales.
- **Geographic Distribution:** Map visualization showing sales volume by county.
- **Customer Satisfaction:** Bar chart on customer happiness segmented by gender.
- **Delivery Duration:** Column chart detailing distribution of delivery times.
- **Monthly Orders & Ratings:** Comparative chart of orders and rating trends across months.

***

## Dashboard Images 

![image alt](https://github.com/SatyaGanesh07/Ecommerce-13-Weeks-Sales-Analysis/blob/891d3e9d370486e1bee54358fc9bb2f400701179/Dashboards/Ecommerce%20sales%201.png)

![image alt](https://github.com/SatyaGanesh07/Ecommerce-13-Weeks-Sales-Analysis/blob/891d3e9d370486e1bee54358fc9bb2f400701179/Dashboards/Ecommerce%20Sales%203.png)
#####
![image alt](https://github.com/SatyaGanesh07/Ecommerce-Sales-Analytics-Snowflake-Power-BI-/blob/940140b0fecba6dc6da5e20c5a0a1f9ada1980d7/Power%20Bi%20Data%20Modeling.png)
*** 
##  Tools & Technologies

* **Data Warehouse:** Snowflake
* **BI Tool:** Power BI (Desktop & Service)
* **Data Mode:** Import
* **Languages:** SQL, DAX
* **Modeling:** Star Schema

## Skills Demonstrated

End-to-end BI project ownership

Snowflake SQL (ETL, validation, modeling)

Dimensional data modeling

Power BI semantic modeling

Advanced DAX for KPIs

Business-focused dashboard design
***

## Final Thoughts

This project demonstrates a real-world analytics workflow, not just dashboard creation.
It highlights the importance of data quality, structured modeling, and business-focused analysis when working with transactional data.

By using Snowflake for validation, transformation, and dimensional modeling, the project ensures that business metrics such as revenue, delivery performance, and customer satisfaction are trustworthy and reproducible.
Power BI then builds on this foundation to deliver clear, interactive insights that support operational and strategic decision-making.

Overall, this project reflects an analytics engineering mindset—combining SQL proficiency, data modeling discipline, and BI reporting skills—aligned with expectations for Data Analyst / BI Analyst roles in modern organizations.

***

## Contact

For any questions or suggestions, please open an issue or contact me via LinkedIn:  
[Satya Ganesh LinkedIn](https://www.linkedin.com/in/satya-ganesh-5a89b2283/)

[Satya Ganesh LinkedIn](https://www.linkedin.com/in/satya-ganesh-5a89b2283/)  

