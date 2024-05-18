create database Data_bank;

create table regions(
region_id int,
region_name nvarchar(10)
);

insert into regions
(region_id, region_name)
values
('1', 'Africa'),
('2', 'America'),
('3', 'Asia'),
('4', 'Europe'),
('5', 'Oceania');

select * from regions;


create table customer_nodes(
customer_id INT,
region_id INT,
node_id INT,
start_date DATE,
end_date DATE
);

INSERT INTO customer_nodes
(customer_id, region_id, node_id, start_date, end_date)
VALUES
(1, 3, 4, '2020-01-02', '2020-01-03'),
(2, 3, 5, '2020-01-03', '2020-01-17'),
(3, 5, 4, '2020-01-27', '2020-02-18'),
(4, 5, 4, '2020-01-07', '2020-01-19'),
(5, 3, 3, '2020-01-15', '2020-01-23'),
(6, 1, 1, '2020-01-11', '2020-02-06'),
(7, 2, 5, '2020-01-20', '2020-02-04'),
(8, 1, 2, '2020-01-15', '2020-01-28'),
(9, 4, 5, '2020-01-21', '2020-01-25'),
(10, 3, 4, '2020-01-13', '2020-01-14');

select * from customer_nodes;

CREATE TABLE customer_transactions (
customer_id INT,
txn_date DATE,
txn_type VARCHAR(50),
txn_amount INT
);

INSERT INTO customer_transactions 
(customer_id, txn_date, txn_type, txn_amount)
VALUES
(429, '2020-01-21', 'deposit', 82),
(155, '2020-01-10', 'deposit', 712),
(398, '2020-01-01', 'deposit', 196),
(255, '2020-01-14', 'deposit', 563),
(185, '2020-01-29', 'deposit', 626),
(309, '2020-01-13', 'deposit', 995),
(312, '2020-01-20', 'deposit', 485),
(376, '2020-01-03', 'deposit', 706),
(188, '2020-01-13', 'deposit', 601),
(138, '2020-01-11', 'deposit', 520);

select * from customer_transactions;

/*A. Customer nodes exploration
Q1. How many unique nodes are there on the data bank system?*/
select count(distinct node_id) as Unique_nodes
from customer_nodes;

/*Q2. What is the number of nodes per region?*/
select c.region_id,
region_name,
count(node_id) as Numb_of_Nodes
from customer_nodes c
inner join regions r
on c.region_id = r.region_id
group by c.region_id , region_name
order by Numb_of_Nodes desc;


/*Q3. How many customers are allocated to each region?*/
select cn.region_id,
region_name,
count(distinct customer_id) as Numb_of_custo
from customer_nodes cn
inner join regions r
on cn.region_id = r.region_id
group by cn.region_id, region_name
order by Numb_of_custo desc;

/*Q4. How many days on avg are customers reallocared to a different
node?*/
SELECT AVG(DATEDIFF(end_date, start_date)) AS avg_num_of_days
FROM customer_nodes
WHERE end_date != '9999-12-31';

/*Q5. what is the median, 80th, and 95th percentile for this
same reallocation daya metric for each region?*/
WITH date_diff AS (
SELECT 
cn.customer_id,
cn.region_id,
r.region_name,
DATEDIFF(end_date, start_date) AS reallocation_days
FROM 
customer_nodes cn
INNER JOIN 
regions r ON cn.region_id = r.region_id
WHERE 
end_date != '9999-12-31'
)
SELECT 
region_id,
region_name,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY reallocation_days) OVER (PARTITION BY region_name) AS median,
PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY reallocation_days) OVER (PARTITION BY region_name) AS percentile_80,
PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY reallocation_days) OVER (PARTITION BY region_name) AS percentile_95
FROM 
date_diff
ORDER BY 
region_name;


/*B. Customer Transactions
Q1. What is the unique count and total amount for each transaction
type?*/
select txn_type,
count(*) as unique_count,
sum(txn_amount) as Total_amt
from customer_transactions
group by txn_type
order by txn_type;

/*Q2. What is the avg total historical deposit counts and amts
for all customers?*/
WITH deposit_summary AS
(
SELECT customer_id,
txn_type,
COUNT(*) AS deposit_count,
SUM(txn_amount) AS deposit_amount
FROM customer_transactions
GROUP BY customer_id, txn_type
)

SELECT txn_type,
AVG(deposit_count) AS avg_deposit_count,
AVG(deposit_amount) AS avg_deposit_amount
FROM deposit_summary
WHERE txn_type = 'deposit'
GROUP BY txn_type;

/*Q3. For each month - how many data bank customers make more
than 1 deposite and either one purchase or withdrawal in a
single month?*/
WITH customer_activity AS (
SELECT customer_id,
MONTH(txn_date) AS month_id,            -- Extracts the month number
MONTHNAME(txn_date) AS month_name,      -- Extracts the name of the month
COUNT(CASE WHEN txn_type = 'deposit' THEN 1 END) AS deposit_count,
COUNT(CASE WHEN txn_type = 'purchase' THEN 1 END) AS purchase_count,
COUNT(CASE WHEN txn_type = 'withdrawal' THEN 1 END) AS withdrawal_count
FROM customer_transactions
GROUP BY customer_id, MONTH(txn_date), MONTHNAME(txn_date)
)

SELECT month_id,
month_name,
COUNT(DISTINCT customer_id) AS active_customer_count
FROM customer_activity
WHERE deposit_count > 1
AND (purchase_count > 0 OR withdrawal_count > 0)
GROUP BY month_id, month_name;


/*Q4. What is the closing balance for each customer at the end 
of the month?*/
WITH cte AS (
SELECT customer_id,
DATE_FORMAT(txn_date, '%Y-%m-01') AS month_start,
SUM(IF(txn_type = 'deposit', txn_amount, -txn_amount)) AS total_amount
FROM customer_transactions
GROUP BY customer_id, DATE_FORMAT(txn_date, '%Y-%m-01')
)

SELECT cte.customer_id,
MONTH(cte.month_start) AS month,  -- Extract month number from the date
MONTHNAME(cte.month_start) AS month_name,  -- Extract the month name
SUM(cte.total_amount) OVER (PARTITION BY cte.customer_id ORDER BY cte.month_start) AS closing_balance
FROM cte;
