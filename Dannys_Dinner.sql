create database danny_dinner;
create table sales(
customer_id nvarchar(1),
order_date Date,
product_id int
);

INSERT INTO sales
(customer_id , order_date , Product_id)
VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');

select * from sales;

create table menu(
product_id int,
product_name nvarchar(5),
price int
);

insert into menu
(product_id , product_name , price)
values
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

select * from menu;

create table members(
customer_id nvarchar(1),
join_date date
);

insert into members
(customer_id , join_date)
values
('A', '2021-01-07'),
('B', '2021-01-09');

select * from members;

/*Q1. toatal amount spend by each customer*/
SELECT S.customer_id, SUM(M.price) AS Total_sales
FROM menu M
JOIN sales S
ON M.product_id = S.product_id
GROUP BY S.customer_id;

/*Q2. How many days has each customer visited the restaurant*/
select customer_id, count(distinct(order_date))
from sales
group by customer_id;

/*Q3. what was the first item from the menu purchased by each cusrtomer*/
With Rank as
(
Select S.customer_id, 
       M.product_name, 
	     S.order_date,
	     DENSE_RANK() OVER (PARTITION BY S.Customer_ID Order by S.order_date) as rank
From Menu m
Join Sales s
On m.product_id = s.product_id
Group by S.customer_id, M.product_name,S.order_date
)
Select Customer_id, product_name
From Rank
Where rank = 1;

/*Q4. What is the most purchased item on the manu and how many
times was it purchased by all customers?*/
SELECT m.product_name, COUNT(s.product_id)as Times_pur
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY COUNT(s.product_id) DESC;

/*Q5. Which item was the most popular for each customer?*/
With rank as
(
Select S.customer_ID ,
       M.product_name, 
	   Count(S.product_id) as Count,
       Dense_rank()  Over (Partition by S.Customer_ID order by Count(S.product_id) DESC ) as Rank
From Menu m
Join Sales s
On m.product_id = s.product_id
Group by S.customer_id,S.product_id,M.product_name
)
Select Customer_id,Product_name,Count
From rank
Where rank = 1;


/*Q6.Which item was purchased first by the customer after they
became a member?*/
With Rank as
(
Select  S.customer_id,
        M.product_name,
        S.order_date,
			  Dense_rank() OVER (Partition by S.Customer_id Order by S.Order_date) as Rank
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date >= Mem.join_date  
)
Select Customer_id, Product_name, Order_date
From Rank
Where Rank = 1;

/*Q7. Which item was purchased just before the customer became a 
member?*/
With Rank as
(
Select  S.customer_id,
        M.product_name,
        S.Order_date,
			  Dense_rank() OVER (Partition by S.Customer_id Order by S.Order_date) as Rank
From Sales S
Join Menu M
On m.product_id = s.product_id
Join Members Mem
On Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date  
)
Select customer_ID, Product_name,Order_date
From Rank
Where Rank = 1;


/*Q8.What is the total items and amount spent for each member before
they became a member?*/
Select S.customer_id,count(S.product_id ) as Items ,Sum(M.price) as total_sales
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date
Group by S.customer_id;

/*Q9.If each $1 spent equates to 10 points and sushi has a
2x points multiplier — how many points would each customer have?*/
With Points as
(
Select *, Case When product_id = 1 THEN price*20
               Else price*10
			   End as Points
From Menu
)
Select S.customer_id, Sum(P.points) as Points
From Sales S
Join Points p
On p.product_id = S.product_id
Group by S.customer_id;

/*Q10. In the first week after a customer joins the program 
(including their join date) they earn 2x points on all items, 
not just sushi — how many points do customer A and B have 
at the end of January?*/
WITH dates AS 
(
   SELECT *, 
   DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date, 
   LAST_DAY('2021-01-31') AS last_date
   FROM members 
)
SELECT S.Customer_id, 
       SUM(
           CASE 
               WHEN M.product_ID = 1 THEN M.price * 20
               WHEN S.order_date BETWEEN D.join_date AND D.valid_date THEN M.price * 20
               ELSE M.price * 10
           END 
       ) AS Points
FROM Dates D
JOIN Sales S ON D.customer_id = S.customer_id
JOIN Menu M ON M.product_id = S.product_id
WHERE S.order_date < D.last_date
GROUP BY S.customer_id;







