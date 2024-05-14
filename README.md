# Danny's Diner Project

## Introduction

Danny's Diner is a cozy Japanese restaurant that opened in early 2021, offering a variety of delicious dishes including sushi, curry, and ramen. As the owner, Danny is keen to utilize the data collected from the restaurant to enhance customer experience and improve business operations.

## Problem Statement

Danny wants to leverage the collected data to answer some key questions about his customers and their preferences. Specifically, he wants to understand customer visiting patterns, total expenditure, and favorite menu items. This will help him make informed decisions about expanding the existing customer loyalty program and delivering a more personalized experience to his customers.

## Datasets

Danny has provided three key datasets for analysis:

1. **Sales Data:** 
   
2. **Menu Data:** 
   
3. **Member Data:** 


## SQL Queries

```sql
/* Q1. Total amount spent by each customer */
SELECT 
    S.customer_id, 
    SUM(M.price) AS Total_sales
FROM 
    menu M
JOIN 
    sales S ON M.product_id = S.product_id
GROUP BY 
    S.customer_id;

/* Q2. How many days has each customer visited the restaurant */
SELECT 
    customer_id, 
    COUNT(DISTINCT(order_date)) AS visit_count
FROM 
    sales
GROUP BY 
    customer_id;

/* Q3. What was the first item from the menu purchased by each customer */
WITH Rank AS (
    SELECT 
        S.customer_id, 
        M.product_name, 
        S.order_date,
        DENSE_RANK() OVER (PARTITION BY S.customer_ID ORDER BY S.order_date) AS rank
    FROM 
        menu M
    JOIN 
        sales S ON M.product_id = S.product_id
)
SELECT 
    customer_id, 
    product_name
FROM 
    Rank
WHERE 
    rank = 1;

/* Q4. What is the most purchased item on the menu and how many times was it purchased by all customers */
SELECT 
    m.product_name, 
    COUNT(s.product_id) AS Times_purchased
FROM 
    menu m
JOIN 
    sales s ON m.product_id = s.product_id
GROUP BY 
    m.product_name
ORDER BY 
    COUNT(s.product_id) DESC;

/* Q5. Which item was the most popular for each customer */
WITH rank AS (
    SELECT 
        S.customer_ID,
        M.product_name, 
        COUNT(S.product_id) AS Count,
        DENSE_RANK() OVER (PARTITION BY S.customer_ID ORDER BY COUNT(S.product_id) DESC ) AS Rank
    FROM 
        menu M
    JOIN 
        sales S ON M.product_id = S.product_id
    GROUP BY 
        S.customer_id,S.product_id,M.product_name
)
SELECT 
    customer_id,
    product_name,
    Count
FROM 
    rank
WHERE 
    rank = 1;

/* Q6. Which item was purchased first by the customer after they became a member */
WITH Rank AS (
    SELECT  
        S.customer_id,
        M.product_name,
        S.order_date,
        DENSE_RANK() OVER (PARTITION BY S.Customer_id ORDER BY S.Order_date) AS Rank
    FROM 
        sales S
    JOIN 
        menu M ON m.product_id = s.product_id
    JOIN 
        members Mem ON Mem.customer_id = S.customer_id
    WHERE 
        S.order_date >= Mem.join_date  
)
SELECT 
    Customer_id, 
    Product_name, 
    Order_date
FROM 
    Rank
WHERE 
    Rank = 1;

/* Q7. Which item was purchased just before the customer became a member */
WITH Rank AS (
    SELECT  
        S.customer_id,
        M.product_name,
        S.order_date,
        DENSE_RANK() OVER (PARTITION BY S.Customer_id ORDER BY S.Order_date) AS Rank
    FROM 
        sales S
    JOIN 
        menu M ON m.product_id = s.product_id
    JOIN 
        members Mem ON Mem.customer_id = S.customer_id
    WHERE 
        S.order_date < Mem.join_date  
)
SELECT 
    customer_ID, 
    Product_name,
    Order_date
FROM 
    Rank
WHERE 
    Rank = 1;

/* Q8. What is the total items and amount spent for each member before they became a member */
SELECT 
    S.customer_id,
    COUNT(S.product_id ) AS Items,
    SUM(M.price) AS total_sales
FROM 
    sales S
JOIN 
    menu M ON m.product_id = s.product_id
JOIN 
    members Mem ON Mem.customer_id = S.customer_id
WHERE 
    S.order_date < Mem.join_date
GROUP BY 
    S.customer_id;

/* Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have */
WITH Points AS (
    SELECT 
        *,
        CASE 
            WHEN product_id = 1 THEN price*20
            ELSE price*10
        END AS Points
    FROM 
        menu
)
SELECT 
    S.customer_id, 
    SUM(P.points) AS Points
FROM 
    sales S
JOIN 
    Points P ON P.product_id = S.product_id
GROUP BY 
    S.customer_id;

/* Q10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January? */
WITH dates AS (
   SELECT 
       *, 
       DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date, 
       LAST_DAY('2021-01-31') AS last_date
   FROM 
       members 
)
SELECT 
    S.Customer_id, 
    SUM(
        CASE 
            WHEN M.product_ID = 1 THEN M.price * 20
            WHEN S.order_date BETWEEN D.join_date AND D.valid_date THEN M.price * 20
            ELSE M.price * 10
        END 
    ) AS Points
FROM 
    Dates D
JOIN 
    sales S ON D.customer_id = S.customer_id
JOIN 
    menu M ON M.product_id = S.product_id
WHERE 
    S.order_date < D.last_date
GROUP BY 
    S.customer_id;


