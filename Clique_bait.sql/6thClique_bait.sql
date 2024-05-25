create database Clique_bait;

CREATE TABLE clique_bait.event_identifier (
  event_type INTEGER,
  event_name VARCHAR(13)
);

CREATE TABLE clique_bait.campaign_identifier (
  campaign_id INTEGER,
  products VARCHAR(3),
  campaign_name VARCHAR(33),
  start_date TIMESTAMP,
  end_date TIMESTAMP
);

SELECT @@sql_mode;
SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

CREATE TABLE clique_bait.page_hierarchy (
  page_id INTEGER,
  page_name VARCHAR(14),
  product_category VARCHAR(9),
  product_id INTEGER
);

CREATE TABLE clique_bait.users (
  user_id INTEGER,
  cookie_id VARCHAR(6),
  start_date TIMESTAMP
);

CREATE TABLE clique_bait.events (
  visit_id VARCHAR(6),
  cookie_id VARCHAR(6),
  page_id INTEGER,
  event_type INTEGER,
  sequence_number INTEGER,
  event_time TIMESTAMP
);

insert into clique_bait.event_identifier
(event_type, event_name)
values
(1, 'Page View'),
(2, 'Add to Cart'),
(3, 'Purchase'),
(4, 'Ad Impression'),
(5, 'Ad Click');

insert into clique_bait.campaign_identifier
(campaign_id, products, campaign_name, start_date, end_date)
values
(1, '1-3', 'BOGOF - Fishing For Compliments', '2020-01-01 00:00:00', '2020-01-14 00:00:00'),
(2, '4-5', '25% Off - Living The Lux Life', '2020-01-15 00:00:00', '2020-01-28 00:00:00'),
(3, '6-8', 'Half Off - Treat Your Shellf(ish)', '2020-02-01 00:00:00', '2020-03-31 00:00:00');

INSERT INTO clique_bait.page_hierarchy
(page_id, page_name, product_category, product_id) 
VALUES
(1, 'Home Page', NULL, NULL),
(2, 'All Products', NULL, NULL),
(3, 'Salmon', 'Fish', 1),
(4, 'Kingfish', 'Fish', 2),
(5, 'Tuna', 'Fish', 3),
(6, 'Russian Caviar', 'Luxury', 4),
(7, 'Black Truffle', 'Luxury', 5),
(8, 'Abalone', 'Shellfish', 6),
(9, 'Lobster', 'Shellfish', 7),
(10, 'Crab', 'Shellfish', 8),
(11, 'Oyster', 'Shellfish', 9),
(12, 'Checkout', NULL, NULL),
(13, 'Confirmation', NULL, NULL);


INSERT INTO clique_bait.users
(user_id, cookie_id, start_date) 
VALUES
(397, '3759ff', '2020-03-30 00:00:00'),
(215, '863329', '2020-01-26 00:00:00'),
(191, 'eefca9', '2020-03-15 00:00:00'),
(89, '764796', '2020-01-07 00:00:00'),
(127, '17ccc5', '2020-01-22 00:00:00'),
(81, 'b0b666', '2020-03-01 00:00:00'),
(260, 'a4f236', '2020-01-08 00:00:00'),
(203, 'd1182f', '2020-04-18 00:00:00'),
(23, '12dbc8', '2020-01-18 00:00:00'),
(375, 'f61d69', '2020-01-03 00:00:00');


INSERT INTO clique_bait.events 
(visit_id, cookie_id, page_id, event_type, sequence_number, event_time) 
VALUES
('719fd3', '3d83d3', 5, 1, 4, '2020-03-02 00:29:09.975502'),
('fb1eb1', 'c5ff25', 5, 2, 8, '2020-01-22 07:59:16.761931'),
('23fe81', '1e8c2d', 10, 1, 9, '2020-03-21 13:14:11.745667'),
('ad91aa', '648115', 6, 1, 3, '2020-04-27 16:28:09.824606'),
('5576d7', 'ac418c', 6, 1, 4, '2020-01-18 04:55:10.149236'),
('48308b', 'c686c1', 8, 1, 5, '2020-01-29 06:10:38.702163'),
('46b17d', '78f9b3', 7, 1, 12, '2020-02-16 09:45:31.926407'),
('9fd196', 'ccf057', 4, 1, 5, '2020-02-14 08:29:12.922164'),
('edf853', 'f85454', 1, 1, 1, '2020-02-22 12:59:07.652207'),
('3c6716', '02e74f', 3, 2, 5, '2020-01-31 17:56:20.777383');


/*SOLUTIONS
A. Digital Analysis
Q1. How many  users are there?*/
select count(user_id) as User_cnt
from users;

/*Q2. How many cookies does each user have on average?*/
select round(avg(cookie_count)) as avg_cookie_per_user
from(
select user_id, count(distinct cookie_id) as cookie_count
from users
group by user_id
) as user_cookies;

/*What is the unique number of visits by all users per month?*/
select * from events;
select extract(year from event_time) as year,
extract(month from event_time) as month,
count(distinct visit_id) as unique_visits
from events
group by year, month
order by year, month;

/*Q4. What is the number of events for each event type?*/
select event_type, count(*) as event_count
from events
group by event_type
order by event_type;

/*Q5. What is the % of visits which have a purchase event?*/
select (count(distinct case when event_type = 1  
then visit_id end)* 100.0 / count(distinct visit_id)) as 
purchase_perce
from events;


/*Q6. What is the % of visits which view the checkout page but
do not have a purchase event?*/
WITH CTE AS (
  SELECT 
      visit_id,
      MAX(CASE WHEN event_type = 1 AND page_id = 10 THEN 1 ELSE 0 END) AS checkout_viewed,
      MAX(CASE WHEN event_type = 2 and page_id = 1 then 1 ELSE 0 END) AS purchase_made
  FROM events
  GROUP BY visit_id
)

SELECT 
  ROUND(100 * (1 - (SUM(purchase_made) / SUM(checkout_viewed))), 2) AS percentagewithout_purchase
FROM CTE;

select * from events;


/*Q7. What are the top 3 pages by number of views?*/
select page_id, count(*) as page_views
from events
where event_type = 1
group by page_id
order by page_views desc
limit 3;


/*Q8. What is the number of views and cart adds for each product category?*/
select ph.product_category,
sum(case when e.event_type = 1 then 1 else 0 end) as num_views,
sum(case when e.event_type = 2 then 1 else 0 end) as num_cart_adds
from page_hierarchy ph
left join events e on ph.page_id = e.page_id
group by ph.product_category
order by ph.product_category;


/*Q9. What are the top 3 products by purchases?*/
select ph.page_name as product_name,
sum(case when e.event_type = 2 then 1 else 0 end) as num_purchases
from page_hierarchy ph
left join events e on ph.page_id = e.page_id
where ph.page_name is not null
group by ph.page_name
order by num_purchases desc
limit 3;


/*B.Product funnel analysis
Using a single SQL query - create a new output table which has the following details:
How many times was each product viewed?
How many times was each product added to cart?
How many times was each product added to a cart but not purchased (abandoned)?
How many times was each product purchased?*/
WITH ProdView AS (
SELECT 
e.visit_id,
ph.product_id,
ph.page_name AS product_name,
ph.product_category,
COUNT(CASE WHEN e.event_type = 1 THEN 1 ELSE NULL END) AS views
FROM events AS e
JOIN page_hierarchy AS ph ON e.page_id = ph.page_id
WHERE product_id IS NOT NULL
GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
ProdCart AS (
SELECT 
e.visit_id,
ph.product_id,
COUNT(CASE WHEN e.event_type = 2 THEN 1 ELSE NULL END) AS cart_adds
FROM events AS e
JOIN page_hierarchy AS ph ON e.page_id = ph.page_id
WHERE product_id IS NOT NULL
GROUP BY e.visit_id, ph.product_id
),
PurchaseEvents AS (
SELECT DISTINCT visit_id
FROM events
WHERE event_type = 1
),
ProductStats AS (
SELECT 
pvc.visit_id, 
pvc.product_id, 
pvc.product_name, 
pvc.product_category, 
pvc.views, 
pcc.cart_adds,
CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchases
FROM ProdView AS pvc
JOIN ProdCart AS pcc ON pvc.visit_id = pcc.visit_id AND pvc.product_id = pcc.product_id
LEFT JOIN PurchaseEvents AS pe ON pvc.visit_id = pe.visit_id
)
SELECT 
product_name, 
product_category, 
SUM(views) AS total_views,
SUM(cart_adds) AS total_cart_adds, 
SUM(CASE WHEN cart_adds > 0 AND purchases = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_adds = 1 AND purchases = 1 THEN 1 ELSE 0 END) AS purchases
FROM ProductStats
GROUP BY product_name, product_category
ORDER BY product_name;

/*create another table which further aggregates the data for the above
points but this time for eacch product category instead of 
individual products*/
WITH ProductPageEvents AS (
SELECT 
e.visit_id,
ph.product_id,
ph.page_name AS product_name,
ph.product_category,
COUNT(CASE WHEN e.event_type = 1 THEN 1 ELSE NULL END) AS page_view,
COUNT(CASE WHEN e.event_type = 2 THEN 1 ELSE NULL END) AS cart_add
FROM events AS e
JOIN page_hierarchy AS ph ON e.page_id = ph.page_id
WHERE product_id IS NOT NULL
GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
PurchaseEvents AS (
SELECT DISTINCT visit_id
FROM events
WHERE event_type = 3
),
CombinedTable AS (
SELECT 
ppe.visit_id, 
ppe.product_id, 
ppe.product_name, 
ppe.product_category, 
ppe.page_view, 
ppe.cart_add,
CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM ProductPageEvents AS ppe
LEFT JOIN PurchaseEvents AS pe ON ppe.visit_id = pe.visit_id
),
ProductInfo AS (
SELECT 
product_name, 
product_category, 
SUM(page_view) AS views,
SUM(cart_add) AS cart_adds, 
SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM CombinedTable
GROUP BY product_id, product_name, product_category
),
CategoryStats AS (
SELECT
product_category,
SUM(views) AS total_category_views,
SUM(cart_adds) AS total_category_cart_adds,
SUM(abandoned) AS total_category_abandoned,
SUM(purchases) AS total_category_purchases
FROM ProductInfo
GROUP BY product_category
)
SELECT
product_category,
total_category_views,
total_category_cart_adds,
total_category_abandoned,
total_category_purchases
FROM CategoryStats;
