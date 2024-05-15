/*create database pizza_runner;*/
/*create table runners(
runner_id int,
registration_date date
);
insert into runners
(runner_id , registration_date)
values
(1, '2021-01-01'),
(2,'2021-01-03'),
(3, '2021-01-08'),
(4, '2021-01-15');
select*FROM runners;*/

/*create table customers_orders(
order_id int,
customer_id int,
pizza_id int,
exclusions nvarchar(4),
extras nvarchar(4),
order_time timestamp
);

INSERT INTO customers_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49')
  ;
select * from customers_orders;*/

/*create table runners_order(
order_id int,
runner_id int,
pickup_time nvarchar(19),
distance nvarchar(7),
duration nvarchar(10),
cancellation nvarchar(23)
);

INSERT INTO runners_order
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
  select * from runners_order;*/
  
  /*create table pizza_names(
  pizza_id int,
  pizza_name text
  );
insert into pizza_names
(pizza_id, pizza_name)
values
(1, 'Meatlovers'),
(2, 'Vegetarian');

select * from pizza_names;*/

/*CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');*/
  
  /*CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');*/
  
  /*Now lets data cleans and transform*/
  
  /*create table if not exists customer_orders_tempp as
  select
  order_id,
  customer_id,
  pizza_id,
  case 
     when exclusions is NULL or exclusions LIKE 'null' THEN ''
     else exclusions
  end as exclusions,
  case
     when extras is NULL or extras LIKE 'null' then ''
     else extras
  end as extras,
  order_time
  from customers_orders;
  
  select * from customer_orders_tempp;*/
  

/*CREATE TABLE runner_orders_temp AS(
	SELECT order_id
	   , runner_id
	   , CASE 
	   	   WHEN pickup_time IS null OR pickup_time LIKE 'null' THEN null
	       ELSE pickup_time
	     END pickup_time
	   , CASE 
	   	   WHEN distance IS null OR distance LIKE 'null' THEN null
	       WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	       ELSE distance
	     END distance
	   , CASE 
	   	  WHEN duration IS null OR duration LIKE 'null' THEN null
	      WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	      WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	      WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	      ELSE duration 
	     END duration
	   , CASE 
	   	   WHEN cancellation IS null OR cancellation LIKE 'null'
		   THEN ''
	       ELSE cancellation
	     END cancellation
	FROM runners_orders
	);
ALTER TABLE runner_orders_temp
    MODIFY pickup_time TIMESTAMP,
    MODIFY distance DECIMAL(10,2), -- You can adjust the precision and scale as needed
    MODIFY duration INT;

select * from 	runner_orders_temp;	*/

/*QUESTIONS
SECTION A
Q1. How many pizzas were orderd?*/
select count(order_id) as pizza_orders
from customer_orders_tempp;


/*Q2. How many unique customer orders were made?*/
select count(distinct order_id) as unique_orders
from customer_orders_tempp;


/*Q3. How many successful orders were deliverd by each runner?*/
select runner_id, count(order_id) as orders_delivered
from runner_orders_temp
where cancellation=''
group by runner_id;


/*Q4. How many of each type of pizza was delivered?*/
select pizza_name, count(C.pizza_id) as delivered_order_count
from customer_orders_tempp C
join runner_orders_temp R on C.order_id = R.order_id
join pizza_names PN on C.pizza_id = PN.pizza_id
where cancellation=''
group by pizza_name;


/*Q5. How many veg and meat were orderd by each customer?*/
select C.customer_id, PN.pizza_name, count(PN.pizza_id) as count_ord
from customer_orders_tempp C
Join pizza_names PN on C.pizza_id = PN.pizza_id
group by C.customer_id, PN.pizza_id
order by C.customer_id;


/*Q6. What was the maximum number of pizzas deliverd in a single order?
*/
with CTE as
(select C.order_id, count(C.pizza_id) as orders_delivered
from customer_orders_tempp C
join runner_orders_temp R on C.order_id = R.order_id
where r.cancellation = ''
group by C.order_id)
select max(orders_delivered) as max_deliver_pizza
from CTE;


/*Q7. For each customer, how many deliverd pizzas had at least
1 change and how many had no changes?*/
with CTE as
(select C.customer_id,
sum(case when C.exclusions<>  '' or C.extras<>  '' Then 1 else 0 end) AS has_atleast_1_changes,
SUM(CASE WHEN C.exclusions=''AND C.extras=''THEN 1 ELSE 0 END) AS no_changes
FROM customer_orders_tempp C 
JOIN runner_orders_temp R ON C.order_id=R.order_id
WHERE R.cancellation=''
GROUP BY C.customer_id)
SELECT SUM(has_atleast_1_changes) AS has_atleast_1_changes,
    SUM(no_changes) AS no_changes
FROM CTE;


/*Q8. How many pizzas were delivered that had both exclusions and extras?*/
select sum(case when C.exclusions<> '' and C.extras<>'' Then 1 else 0 end) as Pizza_with_exclusions_extras
from customer_orders_tempp C
join runner_orders_temp R on C.order_id = R.order_id
where R.cancellation = '';


/*Q9. What was the total volume of pizzas ordered for each hr of the day?*/
SELECT
    HOUR(order_time) AS hours,
    COUNT(order_id) AS "pizza ordered"
FROM
    customer_orders_tempp
GROUP BY
    hours
ORDER BY
    hours;


/*Q10. What was the volume of orders for each day of the week?*/
SELECT 
    DAYNAME(order_time) AS day, 
    COUNT(order_id) AS ordered_pizza 
FROM 
    customer_orders_tempp 
GROUP BY 
    day;
    
    
/*SECTION B
Q1. How many runners signed up for each 1 week period?(i.e. week starts 2021-01-01)
*/
SELECT WEEK(registration_date) AS weeks,
       COUNT(runner_id) AS signed_runner_week
FROM runners
GROUP BY 1
ORDER BY 1;

/*Q2. What was the average time in minutes it took for each 
runner to arrive at the Pizza Runner HQ to pick up the order?
*/
WITH CTE AS (
    SELECT 
        c.order_id, 
        c.order_time, 
        r.pickup_time, 
        TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS Subst
    FROM 
        runner_orders_temp R
        JOIN customer_orders_tempp C USING (order_id)
    WHERE 
        cancellation = ''
    GROUP BY 
        c.order_id, c.order_time, r.pickup_time
)
SELECT 
    AVG(Subst) AS pickup_avg
FROM 
    CTE
WHERE 
    Subst > 1;
    
/*Q3. Is there any relationship between the number of pizzas 
and how long the order takes to prepare?*/
WITH CTE AS (
    SELECT 
        c.order_id, 
        COUNT(c.order_id) AS pizza_order, 
        c.order_time, 
        r.pickup_time,
        TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS min
    FROM 
        customer_orders_tempp C
        JOIN runner_orders_temp R USING(order_id)
    WHERE 
        cancellation = ''
    GROUP BY 
        c.order_id, c.order_time, r.pickup_time
)

SELECT 
    pizza_order, 
    ROUND(AVG(min), 2) AS avg_prep_time_minutes
FROM 
    CTE
WHERE 
    min > 1
GROUP BY 
    pizza_order;


/*Q4. What was the avg distance travelled for each customer?*/
select customer_id, round(avg(distance),2) as average
from customer_orders_tempp C
join runner_orders_temp R ON C.order_id = R.order_id
where cancellation = ''
group by customer_id;


/*Q5. What was the diff bw the longest and shortest delivery times
for all orders?*/
select max(duration) as long_delivey, min(duration) as shortest_delivery
, max(duration) - min(duration) as difference
from runner_orders_temp;


/*Q6. Whatv was the avg speed for each runner for each delivery
and do you notice any trend for these values?*/
WITH CTE AS (
    SELECT 
        R.runner_id, 
        C.customer_id, 
        C.order_id, 
        COUNT(C.order_id) AS pizza_cnt,
        R.distance,
        ROUND(CAST(R.duration AS DECIMAL) / 60, 2) AS hr_duration
    FROM 
        runner_orders_temp AS R
        JOIN customer_orders_tempp AS C ON R.order_id = C.order_id
    WHERE 
        R.cancellation = ''
    GROUP BY 
        R.runner_id, C.customer_id, C.order_id, R.distance, R.duration, C.order_time
    ORDER BY 
        C.order_id
)

SELECT 
    runner_id, 
    order_id, 
    distance, 
    hr_duration,
    ROUND(distance / hr_duration, 2) AS avg_speed
FROM 
    CTE
GROUP BY 
    runner_id, order_id, distance, hr_duration
ORDER BY 
    runner_id;


/*Q7. What is the successful delivery % for each number?*/
WITH CTE AS (
    SELECT 
        runner_id, 
        CAST(COUNT(order_id) AS DECIMAL) AS totl_orders,
        COUNT(CASE WHEN cancellation = '' THEN order_id END) AS com_orders
    FROM 
        runner_orders_temp
    GROUP BY 
        runner_id
)

SELECT 
    runner_id,
    ROUND((com_orders / totl_orders) * 100) AS completed
FROM 
    CTE;
    
/*Q8. What are the standard ingredients for each pizza?*/
WITH CTE AS (
    SELECT 
        pizza_id,
        CAST(SUBSTRING_INDEX(toppings, ', ', 1) AS UNSIGNED) AS topping_id
    FROM 
        pizza_recipes
    UNION ALL
    SELECT 
        pizza_id,
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ', ', n.digit + 1), ', ', -1) AS UNSIGNED) AS topping_id
    FROM 
        pizza_recipes
    JOIN (SELECT 0 AS digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS n
    ON LENGTH(REPLACE(toppings, ', ', '')) <= LENGTH(toppings) - n.digit
),
topping_name AS (
    SELECT 
        C.pizza_id, 
        C.topping_id, 
        P.topping_name
    FROM 
        CTE C
        JOIN pizza_toppings P ON C.topping_id = P.topping_id
    ORDER BY 
        pizza_id, topping_id
)
  
SELECT 
    pizza_name, 
    GROUP_CONCAT(topping_name SEPARATOR ', ') AS stndrd_ingredients
FROM 
    topping_name
JOIN 
    pizza_names USING(pizza_id)
GROUP BY 
    pizza_name;

/*Q9. What was the most commonly added extra?*/
WITH CTE AS (
    SELECT
        *,
        SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n.n), ',', -1) AS topping_id
    FROM
        customer_orders_tempp
    JOIN 
        (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
        ON LENGTH(REPLACE(extras, ',' , '')) <= LENGTH(extras) - n.n + 1
    WHERE 
        extras != ''
)

SELECT 
    topping_id, 
    topping_name, 
    COUNT(topping_id) AS extra_count
FROM 
    CTE
JOIN 
    pizza_toppings
USING
    (topping_id)
GROUP BY 
    topping_id, topping_name
ORDER BY 
    extra_count DESC
LIMIT 1;


/*Q10. What was the most common exclusion?*/
SELECT 
    topping_id, 
    topping_name, 
    COUNT(topping_id) AS exclusions_cnt
FROM (
    SELECT 
        *,
        SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n.n), ',', -1) AS topping_id
    FROM 
        customer_orders_tempp
    JOIN 
        (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
        ON LENGTH(REPLACE(exclusions, ',' , '')) <= LENGTH(exclusions) - n.n + 1
    WHERE 
        exclusions != ''
) split_exclusions
JOIN 
    pizza_toppings
USING
    (topping_id)
GROUP BY 
    topping_id, topping_name
ORDER BY 
    exclusions_cnt DESC
LIMIT 1;


