/*
	8 Week SQL Challenge
	Case Study 1 - Danny's Diner
*/

	USE [Danny's Diner Case Study 1];
	GO 

--  Create and populate tables

	CREATE TABLE sales (
	  "customer_id" VARCHAR(1),
	  "order_date" DATE,
	  "product_id" INTEGER
	);

	INSERT INTO sales
	  ("customer_id", "order_date", "product_id")
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
	  "product_id" INTEGER,
	  "product_name" VARCHAR(5),
	  "price" INTEGER
	);

	INSERT INTO menu
	  ("product_id", "product_name", "price")
	VALUES
	  ('1', 'sushi', '10'),
	  ('2', 'curry', '15'),
	  ('3', 'ramen', '12');
  

	CREATE TABLE members (
	  "customer_id" VARCHAR(1),
	  "join_date" DATE
	);

	INSERT INTO members
	  ("customer_id", "join_date")
	VALUES
	  ('A', '2021-01-07'),
	  ('B', '2021-01-09');


	SELECT * FROM members;

	SELECT * FROM menu;

	SELECT * FROM sales;

--------------------------------------------------------------------------------------------

--  What is the total amount each customer spent at the restaurant?

	SELECT 
		DISTINCT(s.customer_id), 
		SUM(m.price) AS TotalAmountSpent
	FROM sales s
	join menu m
		ON m.product_id = s.product_id
	GROUP BY s.customer_id
	ORDER BY s.customer_id;


--------------------------------------------------------------------------------------------

-- 2) How many days has each customer visited the restaurant?

	SELECT 
		DISTINCT(customer_id), 
		COUNT(order_date) AS VisitCount
	FROM sales 
	GROUP BY customer_id
	ORDER BY customer_id;
--------------------------------------------------------------------------------------------
 
-- 3) What was the first item from the menu purchased by each customer?
	

	WITH CTE AS(
	SELECT 
		s.customer_id,
		s.order_date,
		m.product_id, 
		m.product_name
	FROM sales s
	INNER JOIN menu m
		ON s.product_id = m.product_id),

	CTE1 AS(
	SELECT
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS row_num,
		c.customer_id,
		c.order_date,
		c.product_id, 
		c.product_name
	FROM CTE c)

	SELECT
		c1.customer_id,
		c1.order_date,
		c1.product_id, 
		c1.product_name
	FROM CTE1 c1
	WHERE row_num = 1;

--------------------------------------------------------------------------------------------

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?
	
	SELECT 
		TOP 1 m.product_name , 
		COUNT(s.product_id) AS TimesPurchased
	FROM sales s
	join menu m
		ON m.product_id = s.product_id
	GROUP BY m.product_name
	ORDER BY TimesPurchased DESC ;

--------------------------------------------------------------------------------------------

-- 5) Which item was the most popular for each customer?

	WITH CTE AS(
	SELECT 
		s.customer_id, 
		m.product_name, 
		COUNT(m.product_id) AS No_of_Times_Bought
	FROM sales s
	JOIN menu m
		ON s.product_id = m.product_id
	GROUP BY customer_id, product_name), 

	CTE1 AS(
	SELECT
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY No_of_Times_Bought DESC) AS dense_rnk,
		c.customer_id,
		c.product_name,
		c.No_of_Times_Bought
	FROM CTE c)

	SELECT
		c1.customer_id,
		c1.product_name,
		c1.No_of_Times_Bought
	FROM CTE1 c1
	WHERE dense_rnk = 1;



--------------------------------------------------------------------------------------------

-- 6) Which item was purchased first by the customer after they became a member
	
WITH CTE AS(
	SELECT 
		s.customer_id, 
		s.order_date, 
		s.product_id,
		me.join_date
	FROM sales s
	JOIN members me
		ON s.customer_id = me.customer_id
	WHERE order_date > join_date),
	
	CTE1 AS(
	SELECT
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS dense_rnk,
		c.customer_id,
		c.order_date, 
		c.product_id
	FROM CTE c)

	SELECT
		c1.customer_id,
		c1.order_date,
		m.product_name
	FROM CTE1 c1 
	JOIN menu m
		ON c1.product_id = m.product_id
	WHERE dense_rnk = 1;

--------------------------------------------------------------------------------------------

-- 7) Which item was purchased just before the customer became a member?

	WITH CTE AS(
	SELECT 
		s.customer_id, 
		s.order_date, 
		s.product_id,
		me.join_date
	FROM sales s
	JOIN members me
		ON s.customer_id = me.customer_id
	WHERE order_date < join_date),
	
	CTE1 AS(
	SELECT
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS dense_rnk,
		c.customer_id,
		c.order_date, 
		c.product_id
	FROM CTE c)

	SELECT
		c1.customer_id,
		c1.order_date,
		m.product_name
	FROM CTE1 c1 
	JOIN menu m
		ON c1.product_id = m.product_id
	WHERE dense_rnk = 1;
--------------------------------------------------------------------------------------------

--8) What is the total items and amount spent for each member before they became a member?

	WITH CTE AS(
	SELECT 
		s.customer_id, 
		s.order_date, 
		s.product_id,
		me.join_date
	FROM sales s
	JOIN members me
		ON s.customer_id = me.customer_id
	WHERE order_date < join_date),
	
	CTE1 AS(
	SELECT
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS dense_rnk,
		c.customer_id,
		c.order_date, 
		c.product_id
	FROM CTE c)

	SELECT
		c1.customer_id,
		COUNT(m.product_id) AS Total_Items,
		SUM(m.price) AS Total_Spent
	FROM CTE1 c1 
	JOIN menu m
		ON c1.product_id = m.product_id
	GROUP BY c1.customer_id;
--------------------------------------------------------------------------------------------

-- 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
	

	WITH CTE AS(
	SELECT 
		s.customer_id,
		s.product_id,
		m.product_name,
		m.price
	FROM sales s
	JOIN menu m
		ON s.product_id = m.product_id),

	CTE1 AS(
	SELECT 
		c.customer_id,
		c.product_name,
		CASE 
			WHEN product_id='1' THEN (price*20) 
			ELSE price*10 
			END AS points
	FROM CTE c)

	SELECT 
		c1.customer_id,
		SUM(points) AS Points
	FROM CTE1 c1
	GROUP BY c1.customer_id
	ORDER BY c1.customer_id;



--------------------------------------------------------------------------------------------

-- 10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

	DECLARE @order_date datetime;
	
	WITH CTE AS(
	SELECT 
		s.customer_id,
		m.product_name,
		s.order_date,
		me.join_date,
		m.price
	FROM sales s
	JOIN menu m
		ON s.product_id = m.product_id
	JOIN members me
		ON s.customer_id = me.customer_id
	WHERE order_date <= '2021-01-31'),
	
	CTE1 AS(
	SELECT 
		c.customer_id,
		CASE
			WHEN order_date IN (join_date,join_date+6) THEN (price*20)
			WHEN product_name= 'sushi' THEN (price*20)
			ELSE (price*10) 
			END AS Points
	FROM CTE c)

	SELECT 
		c1.customer_id,
		SUM(points) AS Points
	FROM CTE1 c1
	GROUP BY c1.customer_id
	ORDER BY c1.customer_id;

