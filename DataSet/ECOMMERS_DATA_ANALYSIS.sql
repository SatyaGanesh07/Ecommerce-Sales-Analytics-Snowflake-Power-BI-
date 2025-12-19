--------------------------------- Project Name: ECOMMERCE DATA ANALYTICS -----------------------------

-------- DataBase & Shema ------------

USE WAREHOUSE ecommerce_wh;
CREATE OR REPLACE DATABASE ecommerce_db;
CREATE OR REPLACE SCHEMA ecommerce_db.analytics;

USE DATABASE ecommerce_db;
USE SCHEMA analytics;


--------------- Raw Table ------------------- 

CREATE OR REPLACE TABLE raw_ecommerce (
    tx_id STRING,
    product STRING, 
    quantity NUMBER,
    unit_price NUMBER,
    amount NUMBER,
    order_date DATE,
    ship_date DATE,
    customer_gender STRING,
    order_mode STRING,
    rating NUMBER,
    state STRING,
    county STRING,
    days_to_deliver NUMBER,
    weeknum NUMBER,
    gender_value STRING
);

select * from raw_ecommerce ;

--------- Staging Table ----------------

CREATE OR REPLACE VIEW stg_ecommerce AS
SELECT
    tx_id,
    TRIM(product) AS product,
    quantity,
    unit_price,
    amount,
    order_date,
    ship_date,
    UPPER(TRIM(customer_gender)) AS customer_gender,
    UPPER(TRIM(order_mode)) AS order_mode,
    rating,
    INITCAP(TRIM(state)) AS state,
    INITCAP(TRIM(county)) AS county,
    days_to_deliver,
    weeknum,
    gender_value         
FROM raw_ecommerce;
 
select * from stg_ecommerce ;

----------------— Data Quality Checking ----------------------

--Identify potential issues that could spoil business decisions

-- Check for NULL values across all columns
SELECT
    COUNT_IF(tx_id IS NULL)               AS tx_id_nulls,
    COUNT_IF(product IS NULL)             AS product_nulls,
    COUNT_IF(quantity IS NULL)            AS quantity_nulls,
    COUNT_IF(unit_price IS NULL)          AS unit_price_nulls,
    COUNT_IF(amount IS NULL)              AS amount_nulls,
    COUNT_IF(order_date IS NULL)          AS order_date_nulls,
    COUNT_IF(ship_date IS NULL)           AS ship_date_nulls,
    COUNT_IF(customer_gender IS NULL)     AS customer_gender_nulls, -- got the 135 nulls
    COUNT_IF(order_mode IS NULL)          AS order_mode_nulls,
    COUNT_IF(rating IS NULL)            AS rating_c_nulls,
    COUNT_IF(state IS NULL)               AS state_nulls,
    COUNT_IF(county IS NULL)              AS county_nulls,
    COUNT_IF(days_to_deliver IS NULL)     AS days_to_deliver_nulls,
    COUNT_IF(weeknum IS NULL)             AS weeknum_nulls,
    COUNT_IF(gender_value IS NULL)        AS gender_value_nulls
FROM stg_ecommerce;

-- Check for duplicate transactions to prevent double-counting revenue
SELECT tx_id, COUNT(*) AS dup_count
FROM stg_ecommerce
GROUP BY tx_id
HAVING COUNT(*) > 1; -- No duplicates should exist

-- Check for empty strings or whitespace-only values
SELECT
    COUNT_IF(TRIM(product) = '' OR product IS NULL)           AS product_empty,
    COUNT_IF(TRIM(customer_gender) = '' OR customer_gender IS NULL) AS gender_empty,
    COUNT_IF(TRIM(order_mode) = '' OR order_mode IS NULL)     AS order_mode_empty,
    COUNT_IF(TRIM(state) = '' OR state IS NULL)               AS state_empty,
    COUNT_IF(TRIM(county) = '' OR county IS NULL)             AS county_empty,
    COUNT_IF(TRIM(gender_value) = '' OR gender_value IS NULL) AS gender_value_empty
FROM stg_ecommerce;

-- Check for invalid numeric values
SELECT
    COUNT_IF(quantity <= 0)        AS invalid_quantity,
    COUNT_IF(unit_price <= 0)      AS invalid_unit_price,
    COUNT_IF(amount <= 0)          AS invalid_amount,
    COUNT_IF(days_to_deliver < 0)  AS invalid_delivery_days,
    COUNT_IF(rating < 1 OR rating > 5) AS invalid_rating
FROM stg_ecommerce;

-- Verify that 'amount' matches 'quantity * unit_price' to ensure revenue accuracy
SELECT COUNT(*) AS amount_mismatch
FROM stg_ecommerce
WHERE amount <> quantity * unit_price; -- got the 1415 mismatch values 

-- Ensure shipping dates are not before order dates
SELECT COUNT(*) AS invalid_delivery
FROM stg_ecommerce
WHERE ship_date >= order_date;

-- Verify that customer ratings fall within valid range (1-5)
SELECT COUNT(*) AS invalid_ratings
FROM stg_ecommerce
WHERE rating NOT BETWEEN 1 AND 5;

-------------------- Clean Table -------------------------

CREATE OR REPLACE TABLE cln_ecommerce AS
SELECT
    tx_id,
    product,
    state,
    county,
    COALESCE(customer_gender, 'O') AS customer_gender,
    gender_value,
    order_mode,
    rating,
    order_date,
    ship_date,
    quantity,
    weeknum,
    unit_price,
    quantity * unit_price AS amount, -- fixing mis
    DATEDIFF('day', order_date, ship_date) AS days_to_deliver
FROM stg_ecommerce
WHERE
    quantity > 0
    AND unit_price > 0
    AND ship_date >= order_date;
select * from cln_ecommerce ;

------------ Dimention Tables ------------------

-- Product dimension: mapping product names to surrogate keys
CREATE OR REPLACE TABLE dim_product (
    product_id NUMBER,
    product_name STRING
);

INSERT INTO dim_product
SELECT
    ROW_NUMBER() OVER (ORDER BY product) AS product_id,
    product
FROM (SELECT DISTINCT product FROM cln_ecommerce);

-- Location dimension: mapping state + county combinations to surrogate keys
CREATE OR REPLACE TABLE dim_location (
    location_id NUMBER,
    state STRING,
    county STRING
);

INSERT INTO dim_location
SELECT
    ROW_NUMBER() OVER (ORDER BY state, county) AS location_id,
    state,
    county
FROM (SELECT DISTINCT state, county FROM cln_ecommerce);

-- Customer dimension: currently only stores gender
CREATE OR REPLACE TABLE dim_customer (
    customer_id NUMBER,
    customer_gender STRING
);

INSERT INTO dim_customer
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_gender) AS customer_id,
    customer_gender
FROM (SELECT DISTINCT customer_gender FROM cln_ecommerce);


----------------------- Fact Table --------------------

CREATE OR REPLACE TABLE fct_ecommerce AS
WITH stats AS (
    SELECT
        AVG(unit_price) AS avg_price,
        STDDEV(unit_price) AS std_price
    FROM cln_ecommerce
)
SELECT
    cn.tx_id,
    dp.product_id,
    dl.location_id,
    dc.customer_id,
    cn.order_mode,
    cn.rating,
    cn.quantity,
    cn.unit_price,
    cn.amount,
    cn.order_date,
    cn.ship_date,
    cn.days_to_deliver,

    -- Order value band
    CASE
        WHEN cn.amount < 100 THEN 'Low'
        WHEN cn.amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END AS order_value_band,

    -- Delivery category
    CASE
        WHEN cn.days_to_deliver <= 2 THEN 'Fast'
        WHEN cn.days_to_deliver <= 5 THEN 'Standard'
        ELSE 'Delayed'
    END AS delivery_category,

    -- Outlier flag (3-sigma rule)
    CASE
        WHEN cn.unit_price > s.avg_price + 3 * s.std_price THEN 'Yes'
        ELSE 'No'
    END AS unit_price_outlier
FROM cln_ecommerce cn
JOIN dim_product dp
    ON cn.product = dp.product_name
JOIN dim_location dl
    ON cn.state = dl.state
   AND cn.county = dl.county
JOIN dim_customer dc
    ON cn.customer_gender = dc.customer_gender
CROSS JOIN stats s;


-------------- Business Queries -------------------------

-- Q1: Total Revenue, Orders, AOV, Units Sold
SELECT
    SUM(amount) AS total_revenue,
    COUNT(tx_id) AS total_orders,
    ROUND(SUM(amount) / NULLIF(COUNT(tx_id), 0), 2) AS avg_order_value,
    SUM(quantity) AS total_units_sold
FROM fct_ecommerce;


-- Q2: Revenue & Orders by Customer Gender
SELECT
    dc.customer_gender,
    SUM(f.amount) AS revenue,
    COUNT(f.tx_id) AS orders
FROM fct_ecommerce f
JOIN dim_customer dc
    ON f.customer_id = dc.customer_id
GROUP BY dc.customer_gender;


-- Q3: Revenue & Orders by Order Mode
SELECT
    order_mode,
    SUM(amount) AS revenue,
    COUNT(tx_id) AS orders
FROM fct_ecommerce
GROUP BY order_mode;


-- Q4: Average Delivery Time by Delivery Category
SELECT
    delivery_category,
    ROUND(AVG(days_to_deliver), 2) AS avg_delivery_days,
    SUM(amount) AS revenue
FROM fct_ecommerce
GROUP BY delivery_category;


-- Q5: Top 10 Products by Revenue
SELECT
    dp.product_name,
    SUM(f.amount) AS revenue,
    SUM(f.quantity) AS units_sold
FROM fct_ecommerce f
JOIN dim_product dp
    ON f.product_id = dp.product_id
GROUP BY dp.product_name
ORDER BY revenue DESC
LIMIT 10;


-- Q6: Week-over-Week Revenue Growth (using order_date)
SELECT
    YEAR(order_date) AS year,
    WEEKOFYEAR(order_date) AS week_of_year,
    SUM(amount) AS revenue,
    LAG(SUM(amount)) OVER (
        ORDER BY YEAR(order_date), WEEKOFYEAR(order_date)
    ) AS prev_week_revenue,
    ROUND(
        (SUM(amount) -
         LAG(SUM(amount)) OVER (ORDER BY YEAR(order_date), WEEKOFYEAR(order_date)))
        / NULLIF(
            LAG(SUM(amount)) OVER (ORDER BY YEAR(order_date), WEEKOFYEAR(order_date)),
            0
        ) * 100,
        2
    ) AS wow_growth_pct
FROM fct_ecommerce
GROUP BY YEAR(order_date), WEEKOFYEAR(order_date)
ORDER BY year, week_of_year;


-- Q7: Revenue Share by Product
SELECT
    dp.product_name,
    SUM(f.amount) AS revenue,
    ROUND(
        SUM(f.amount) / SUM(SUM(f.amount)) OVER () * 100,
        2
    ) AS revenue_share_pct
FROM fct_ecommerce f
JOIN dim_product dp
    ON f.product_id = dp.product_id
GROUP BY dp.product_name
ORDER BY revenue DESC;


-- Q8: Effect of Delivery Speed on Ratings
SELECT
    delivery_category,
    COUNT(*) AS orders,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(amount) AS revenue
FROM fct_ecommerce
GROUP BY delivery_category;


-- Q9: Revenue & Orders by State
SELECT
    dl.state,
    SUM(f.amount) AS revenue,
    COUNT(f.tx_id) AS orders
FROM fct_ecommerce f
JOIN dim_location dl
    ON f.location_id = dl.location_id
GROUP BY dl.state
ORDER BY revenue DESC;


-- Q10: Month-over-Month Revenue Growth (using order_date)
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS year_month,
    SUM(amount) AS revenue,
    LAG(SUM(amount)) OVER (
        ORDER BY TO_CHAR(order_date, 'YYYY-MM')
    ) AS prev_month_revenue,
    ROUND(
        (SUM(amount) -
         LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(order_date, 'YYYY-MM')))
        / NULLIF(
            LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(order_date, 'YYYY-MM')),
            0
        ) * 100,
        2
    ) AS mom_growth_pct
FROM fct_ecommerce
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY year_month;


-- Q11: Bottom 10 Products by Revenue
SELECT
    dp.product_name,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.amount) AS total_revenue
FROM fct_ecommerce f
JOIN dim_product dp
    ON f.product_id = dp.product_id
GROUP BY dp.product_name
ORDER BY total_revenue ASC
LIMIT 10;
