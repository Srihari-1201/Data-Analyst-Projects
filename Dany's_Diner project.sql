CREATE DATABASE dannys_diner;

USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
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
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  /* 1. What is the total amount each customer spent at the restaurant? */
  USE dannys_diner;
  SHOW tables;
  SELECT  s.customer_id , sum(m.price) FROM sales s JOIN menu m ON s.product_id = m.product_id GROUP BY 1 ;
  /* Customer A spent more money */
  
  /* 2.How many days has each customer visited the restaurant? */
  SELECT customer_id, count(DISTINCT order_date) FROM sales GROUP BY 1;

/* 3.What was the first item from the menu purchased by each customer?*/
SELECT * FROM menu;
SELECT s.customer_id ,min(s.order_date) AS first_item_purchased , m.product_name  FROM sales s JOIN menu m ON s.product_id = m.product_id
 GROUP BY 1,3 ;
 
 /* 4.What is the most purchased item on the menu and how many times was it purchased by all customers?*/
SELECT product_name, count(order_date) AS maximum_pruchase    
FROM sales s JOIN menu m ON s.product_id = m.product_id GROUP BY 1  ORDER BY count(order_date) DESC;

/* 5.Which item was the most popular for each customer?*/
SELECT s.customer_id , product_name , count(order_date) AS purchase_count, row_number() OVER (PARTITION BY s.customer_id ORDER BY count(order_date) DESC ) AS most_popular 
FROM sales s JOIN menu m ON s.product_id = m.product_id GROUP BY s.customer_id , product_name ;

/* 6. Which item was purchased first by the customer after they became a member ? */
SELECT s.customer_id,order_date, product_name,join_date,row_number() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rnk FROM sales s
JOIN members me ON s.customer_id = me.customer_id
JOIN menu m ON s.product_id = m.product_id WHERE order_date >= join_date;

/* 7.Which item was purchased just before the customer became a member?*/
WITH t1 AS (
   SELECT s.customer_id,order_date, product_name,join_date,
   row_number() OVER (PARTITION BY s.customer_id ORDER BY order_date DESC) AS rnk FROM sales s
   JOIN members me ON s.customer_id = me.customer_id
   JOIN menu m ON s.product_id = m.product_id WHERE order_date <= join_date
)
SELECT * FROM t1 WHERE rnk = 1;

/* 8.What is the total items and amount spent for each member before they became a member? */
SELECT s.customer_id, count(product_name) AS Total_items, sum(price) AS Toatl
    FROM sales s
   JOIN members me ON s.customer_id = me.customer_id
   JOIN menu m ON s.product_id = m.product_id WHERE order_date < join_date GROUP BY 1;
   
/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */
SELECT
customer_id,
sum(CASE 
WHEN product_name = 'sushi' THEN price *10 *2
ELSE  price * 10
END) AS points
FROM menu m JOIN sales s ON s.product_id = m.product_id  GROUP BY customer_id;

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 not just sushi - how many points do customer A and B have at the end of January? */
 
 /*11. Join all things*/
 SELECT s.customer_id,order_date,product_name,price, CASE 
 WHEN join_date IS NULL THEN 'N' 
 WHEN order_date < join_date THEN 'N' 
 ELSE 'Y' END AS member FROM sales s JOIN menu m ON s.product_id = m.product_id
 LEFT JOIN members me ON me.customer_id = s.customer_id;
 
 /* Ranking for customer*/
  SELECT s.customer_id,order_date,product_name,price, CASE 
 WHEN join_date IS NULL THEN 'N' 
 WHEN order_date < join_date THEN 'N' 
 ELSE 'Y' END AS member, CASE
 WHEN join_date IS NULL THEN 'NULL' 
 WHEN order_date < join_date THEN 'NULL'
 ELSE dense_rank() OVER(PARTITION BY s.customer_id ORDER BY order_date) END AS rnk
 FROM sales s JOIN menu m ON s.product_id = m.product_id
 LEFT JOIN members me ON me.customer_id = s.customer_id;
 




  
  
  
  
  