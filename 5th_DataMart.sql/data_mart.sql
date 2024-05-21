/* Data cleaning steps*/

CREATE TABLE clean_weekly_sales AS
SELECT
STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%Y-%m-01') AS transaction_month,
CASE
WHEN YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) = 2018 THEN 2018
WHEN YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) = 2019 THEN 2019
WHEN YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) = 2020 THEN 2020
END AS calendar_year,
CASE 
WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
ELSE 'unknown'
END AS age_band,
platform,
CASE
WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
WHEN LEFT(segment, 1) = 'F' THEN 'Families'
ELSE 'unknown'
END AS demographic,
COALESCE(NULLIF(segment, ''), 'unknown') AS segment,
region,
transactions,
sales,
ROUND(CAST(sales AS DECIMAL) / transactions, 2) AS avg_transaction
FROM weekly_sales;

SELECT *
FROM clean_weekly_sales;

/* Data Exploration
Q1. What day of the Week is used for each week_date value?*/
SELECT DISTINCT DATE_FORMAT(week_date, '%W') AS DAY
FROM clean_weekly_sales;

/*Q2. What range of week numbers are missing from the dataset?*/
WITH RECURSIVE week_number_cte AS (
SELECT 1 AS week_num
UNION ALL
SELECT week_num + 1
FROM week_number_cte
WHERE week_num < 52
)
SELECT DISTINCT w.week_num
FROM week_number_cte AS w
LEFT JOIN clean_weekly_sales AS s
ON w.week_num = s.week_number
WHERE s.week_number IS NULL
ORDER BY w.week_num;


/*Q3. How many total transactions were there for each yr in the
dataset?*/
select calendar_year, sum(transactions) as total_transactions
from clean_weekly_sales
group by calendar_year
order by calendar_year;

/*Q4. What is the total sales for each region for each number?
*/
select region, sum(sales) as total_sales
from clean_weekly_sales
where month_number=7
group by region
order by region;

/*Q5. What is the total count of transactions for each platform?*/
select platform, sum(transactions) as total_trans
from clean_weekly_sales
group by platform
order by platform;

/*Q6. What is the % of sales for retail vs shopify for each month?*/
WITH monthly_platform_sales AS (
SELECT 
calendar_year, 
month_number, 
platform, 
SUM(sales) AS monthly_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform
)
SELECT 
calendar_year, 
month_number, 
ROUND(
100 * SUM(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE 0 END) / NULLIF(SUM(monthly_sales), 0),
2
) AS retail_percentage,
ROUND(
100 * SUM(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE 0 END) / NULLIF(SUM(monthly_sales), 0),
2
) AS shopify_percentage
FROM monthly_platform_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;


/*Q7. What is the % of sales by demograpphic for each yr in dataset?
*/
WITH yearly_demographic_sales AS (
SELECT 
calendar_year, 
demographic,
SUM(sales) AS yearly_sales
FROM clean_weekly_sales
GROUP BY calendar_year, demographic
)
SELECT 
calendar_year,
demographic,
ROUND(100 * yearly_sales / SUM(yearly_sales) OVER (PARTITION BY calendar_year), 2) AS sales_percentage
FROM yearly_demographic_sales
ORDER BY calendar_year, demographic;

/*Q8. which age_band and demographic values contribute the most
to retail sales?*/
select 
age_band,
demographic,
sum(sales) as retail_sales
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by retail_sales desc;

/*Q9. Can we use the avg_trans column to find the avg transaction
size for each yr for retail vs shopify?*/
select
calendar_year,
platform,
avg(avg_transaction) as average_trans
from clean_weekly_sales
group by calendar_year, platform
order by calendar_year, platform;

/*Before and After analysis
Q1. What is the total sales for the 4weeks before and after
2020-06-15? What is the growth or reduction rate in actual values
and % of sales?*/
with cte as (
select
week_date,
week_number,
sum(sales) as total_sales
from clean_weekly_sales
where week_number between 21 and 28
and year(week_date) = 2020
group by week_date, week_number
),
cte2 as (
select
SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales ELSE 0 END) AS before_sales,
SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales ELSE 0 END) AS after_sales
from cte
)
select
after_sales - before_sales AS sales_va, 
ROUND(100 * (after_sales - before_sales) / NULLIF(before_sales, 0), 2) AS variance_percent
FROM CTE2;


/*Q2. What about the entire 12 weeks before and after?*/
WITH packaging_sales AS (
SELECT 
week_date, 
week_number, 
SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_date BETWEEN '2020-04-06' AND '2020-07-05' -- Include 12 weeks before and after
GROUP BY week_date, week_number
),
before_after_changes AS (
SELECT 
SUM(CASE 
WHEN week_date BETWEEN '2020-04-06' AND '2020-06-07' THEN total_sales ELSE 0 END) AS before_packaging_sales,
SUM(CASE 
WHEN week_date BETWEEN '2020-06-15' AND '2020-08-02' THEN total_sales ELSE 0 END) AS after_packaging_sales
FROM packaging_sales
)
SELECT 
after_packaging_sales - before_packaging_sales AS sales_variance, 
ROUND(
100 * (after_packaging_sales - before_packaging_sales) / NULLIF(before_packaging_sales, 0), 
2
) AS variance_percentage
FROM before_after_changes;


