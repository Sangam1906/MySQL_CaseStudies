/* A. High level sales analysis
Q1. What was the total quantity sold for all products?*/
SELECT SUM(qty) AS total_quantity_sold
FROM sales;

/*Q2. What is the total generated revenue for all products
before discounts?*/
select sum(qty * price) as total_reve_befo_dis
from sales;

/*Q3. What was the total discount amount for all products?*/
select sum(discount) as tot_disc_amt_for_all_prod
from sales;

/*Q4.B. Transaction analysis
Q1. How many unique transactions were there?*/
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales;

/* Q2. What is the average unique products purchased in each transaction?
*/
SELECT AVG(avg_unique_products) AS average_unique_products_per_transaction
FROM (
  SELECT txn_id, COUNT(DISTINCT prod_id) AS avg_unique_products
  FROM balanced_tree.sales
  GROUP BY txn_id
) AS unique_products_per_transaction;

/*Q3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
*/
SELECT 
MAX(CASE WHEN cumulative_percentile <= 0.25 THEN revenue_per_transaction ELSE NULL END) AS p25_revenue,
MAX(CASE WHEN cumulative_percentile <= 0.50 THEN revenue_per_transaction ELSE NULL END) AS p50_revenue,
MAX(CASE WHEN cumulative_percentile <= 0.75 THEN revenue_per_transaction ELSE NULL END) AS p75_revenue
FROM (
SELECT 
revenue_per_transaction,
@running_total := @running_total + 1 AS row_num,
@running_total / @total_rows AS cumulative_percentile
FROM (
SELECT 
txn_id, 
SUM(qty * price) AS revenue_per_transaction
FROM sales
GROUP BY txn_id
ORDER BY revenue_per_transaction
) AS ordered_revenue,
(SELECT @running_total := 0, @total_rows := (SELECT COUNT(DISTINCT txn_id) FROM sales)) AS init
) AS cumulative_distribution;

/*Q4. What is the avg disc value per trans?*/
SELECT AVG(total_discount) AS avg_discount_per_transaction
FROM (
SELECT txn_id, SUM(discount) AS total_discount
FROM sales
GROUP BY txn_id
) AS discount_per_transaction;

/*Q5. What is the percentage split of all transactions for members vs non-members?
*/
SELECT 
SUM(CASE WHEN member = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS member_percentage,
SUM(CASE WHEN member = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS non_member_percentage
FROM sales;

/*Q6. What is the average revenue for member transactions and non-member transactions?
*/
SELECT
CASE
WHEN member = 't' THEN 'Member'
WHEN member = 'f' THEN 'Non-Member'
END AS member_status,
AVG(qty * price) AS avg_revenue
FROM balanced_tree.sales
GROUP BY member;

/* C. Peoduct analysis
Q1. What are the top 3 products by total revenue before discount?
*/
SELECT
pd.product_id,
pd.product_name,
SUM(s.price * s.qty) AS total_revenue_before_discount
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s ON pd.product_id = s.prod_id
GROUP BY pd.product_id, pd.product_name
ORDER BY total_revenue_before_discount DESC
LIMIT 3;

/*Q2. What is the total quantity, revenue and discount for each segment?
*/
SELECT
pd.segment_name,
SUM(s.qty) AS total_quantity,
SUM(s.price * s.qty) AS total_revenue,
SUM(s.qty * s.price * s.discount / 100) AS total_discount
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s ON pd.product_id = s.prod_id
GROUP BY pd.segment_name
ORDER BY total_revenue DESC;

/*Q4. What is the top selling product for each segment?
*/ 
WITH top_selling_products AS (
SELECT
  pd.segment_id,
  pd.segment_name,
  pd.product_id,
  pd.product_name,
  SUM(s.qty) AS total_quantity,
  ROW_NUMBER() OVER (PARTITION BY pd.segment_id ORDER BY SUM(s.qty) DESC) AS rank
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s ON pd.product_id = s.prod_id
GROUP BY pd.segment_id, pd.segment_name, pd.product_id, pd.product_name
)
SELECT
segment_id,
segment_name,
product_id,
product_name,
total_quantity
FROM top_selling_products
WHERE rank = 1;

/*Q4. What is the total quantity, revenue and discount for each category?
*/
SELECT
pd.category_id,
pd.category_name,
SUM(s.qty) AS total_quantity,
SUM(s.qty * s.price) AS total_revenue,
SUM(s.qty * s.price * s.discount / 100) AS total_discount
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s ON pd.product_id = s.prod_id
GROUP BY pd.category_id, pd.category_name;


/*Q5. What is the top selling product for each category?*/
WITH top_selling_cte AS (
SELECT 
pd.category_id,
pd.category_name,
pd.product_id,
pd.product_name,
SUM(s.qty) AS total_quantity,
RANK() OVER (
PARTITION BY pd.category_id 
ORDER BY SUM(s.qty) DESC) AS ranking
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s ON pd.product_id = s.prod_id
GROUP BY 
pd.category_id, pd.category_name, pd.product_id, pd.product_name
)

SELECT 
category_id,
category_name, 
product_id,
product_name,
total_quantity
FROM top_selling_cte
WHERE ranking = 1;

/*Q6. What is the percentage split of revenue by product for each segment?
*/
WITH segment_revenue AS (
SELECT 
  p.segment_id,
  p.segment_name,
  s.prod_id,
  p.product_name,
  SUM(s.price * s.qty) AS total_revenue
FROM balanced_tree.sales s
JOIN balanced_tree.product_details p ON s.prod_id = p.product_id
GROUP BY 
  p.segment_id, p.segment_name, s.prod_id, p.product_name
)

SELECT 
sr.segment_id,
sr.segment_name,
sr.prod_id,
sr.product_name,
sr.total_revenue,
ROUND(100 * sr.total_revenue / SUM(sr.total_revenue) OVER (PARTITION BY sr.segment_id), 2) AS revenue_percentage
FROM segment_revenue sr;

/*Q7. What is the percentage split of revenue by segment for each category?
*/
WITH category_segment_revenue AS (
SELECT 
p.category_id,
p.category_name,
p.segment_id,
p.segment_name,
SUM(s.price * s.qty) AS total_revenue
FROM balanced_tree.sales s
JOIN balanced_tree.product_details p ON s.prod_id = p.product_id
GROUP BY 
p.category_id, p.category_name, p.segment_id, p.segment_name
)

SELECT 
csr.category_id,
csr.category_name,
csr.segment_id,
csr.segment_name,
csr.total_revenue,
ROUND(100 * csr.total_revenue / SUM(csr.total_revenue) OVER (PARTITION BY csr.category_id), 2) AS revenue_percentage
FROM category_segment_revenue csr;
