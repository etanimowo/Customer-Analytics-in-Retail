-- First l need to creat the customers table:

create table customers (
    customer_id INT,
    first_name VARCHAR (100),
    last_name VARCHAR (100),
    email VARCHAR(100),
    join_date DATE
);

--Next, l need to import the customers csv file from my harddrive with tbe below query

COPY customers(customer_id, first_name, last_name, email, join_date)
FROM 'c:\uk september 2023\10Alytics\postgresql\SQL Project\March 2025\Join\customers.csv'
DELIMITER ','   -- ensures values are separated correctly.
CSV HEADER;   --tells PostgreSQL to ignore the first row (column names).

-- Next l need to test or confirm if al the data have been uploaded unto the table successfully

SELECT * FROM customers;

--Note: it worked successfully.





-- Second l need to creat the orders table:

create table orders (
    order_id INT Primary Key,
    customer_id INT,
    order_date DATE,
    product_id INT,
	quantity INT,
	total_amount INT
);

--Next, l need to import the orders csv file from my harddrive with tbe below query

COPY orders(order_id, customer_id, order_date, product_id, quantity,total_amount)
FROM 'c:\uk september 2023\10Alytics\postgresql\SQL Project\March 2025\Join\orders.csv'
DELIMITER ','   -- ensures values are separated correctly.
CSV HEADER;   --tells PostgreSQL to ignore the first row (column names).

-- Next l need to test or confirm if al the data have been uploaded unto the table successfully

SELECT * FROM orders;

--Note: it worked successfully.



-- Third l need to creat the products table:

create table products (
    product_id INT,
    product_name VARCHAR (50),
    category VARCHAR (50),
    price INT
);

--Next, l need to import the products csv file from my harddrive with tbe below query

COPY products(product_id, product_name, category, price)
FROM 'c:\uk september 2023\10Alytics\postgresql\SQL Project\March 2025\Join\products.csv'
DELIMITER ','   -- ensures values are separated correctly.
CSV HEADER;   --tells PostgreSQL to ignore the first row (column names).

-- Next l need to test or confirm if al the data have been uploaded unto the table successfully

SELECT * FROM products;

--Note: it worked successfully.



-- Lastly l need to creat the payments table:

create table payments (
    payment_id INT,
    order_id INT,
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50)
);

--Next, l need to import the payments csv file from my harddrive with tbe below query

COPY payments(payment_id, order_id, payment_date, payment_method, payment_status)
FROM 'c:\uk september 2023\10Alytics\postgresql\SQL Project\March 2025\Join\payments.csv'
DELIMITER ','   -- ensures values are separated correctly.
CSV HEADER;   --tells PostgreSQL to ignore the first row (column names).

-- Next l need to test or confirm if al the data have been uploaded unto the table successfully

SELECT * FROM payments;

--Note: it worked successfully.


--Business Questions:

--Q1:  Find the order details (order_id, order_date, product_name, quantity) for each customer 
-- who has placed an order.

-- To find order details for each customer, lets find out the correct table to use:
select * from customers;  -- wrong table, it does not contains the order details
select * from orders; -- correct table, it contains order_id, order_date and quantity
select * from payments; -- wrong table, it does not contains product_name
select * from products -- correct table, it contains product_name

--therefore, orders and products tables are needed to answer above question.

select orders.order_id, orders.order_date, products.product_name, orders.quantity
from orders
inner join products on products.product_id = orders.product_id
order by order_id desc;



--Q2:  List all customers and the details of their orders, including customers who have not placed 
-- any orders.

-- To list all customers and the details of their orders,lets find out the correct table to use:
select * from customers;  -- yes, correct table, it contains the customers details
select * from orders; -- yes, correct table, it contains order_id, order_date and quantity
select * from payments; -- wrong table, not needed
select * from products -- wrong table, not needed

--therefore, customers and orders tables are needed to answer above question.

select customers.customer_id, concat(customers.first_name, ' ', customers.last_name) as customer_name, 
orders.order_id, orders.order_date, orders.quantity
from customers
left join orders on customers.customer_id = orders.customer_id
order by customer_id

--Or

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;



--Q3:  Find the total amount spent by each customer on their orders, including the product names 
-- they bought.

-- To find the tota amount spent by each customer on their orders, lets find out the correct table to use:
select * from customers;  -- yes, correct table, needed for customers details
select * from orders; -- yes, correct table, needed for total_amount spent
select * from payments; -- wrong table, not needed
select * from products -- correct table, needed to show product name

--therefore, customers and orders tables are needed to answer above question.

select customers.customer_id, concat(customers.first_name, ' ', customers.last_name),
products.product_name, sum(orders.total_amount) as total_amount
from orders
join customers on customers.customer_id = orders.customer_id
join products on products.product_id = orders.product_id
group by customers.customer_id, customers.first_name, customers.last_name, products.product_name;

--Or

SELECT 
    c.first_name,
    c.last_name,
    p.product_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN products p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, p.product_name, c.first_name, c.last_name;



--Q4:  Convert the order_date from TEXT to DATE and list all orders placed in March 2023.

-- lets find out the correct tables to use:

select * from orders;  -- the only table needed

select orders.order_id, orders.customer_id, cast(orders.order_date as date) as order_date
from orders
where order_date between '2023-03-01' and '2023-03-31';

--Or 

SELECT 
    order_id,
    customer_id,
    CAST(order_date AS DATE) AS order_date
FROM orders
WHERE CAST(order_date AS DATE) BETWEEN '2023-03-01' AND '2023-03-31';



--Q5:  Concatenate the customer’s first name and last name, casting the result to VARCHAR.

select * from customers;

select customers.customer_id, concat(cast(customers.first_name as VARCHAR), ' ',
cast(customers.last_name as VARCHAR)) as customer_name

from customers
order by customers.customer_id;

--Or

SELECT 
    customer_id,
    CAST(first_name AS VARCHAR) || ' ' || CAST(last_name AS VARCHAR) AS full_name
FROM customers;



--Q6:  Display the first name and last name of all customers, and if the last name is missing, 
-- show "Unknown" instead. 

select * from customers;

select customers.first_name, coalesce(customers.last_name, 'unknown') as last_name
from customers;

--Or 

SELECT 
    first_name,
    COALESCE(last_name, 'Unknown') AS last_name
FROM customers;


--Q7:  Show the total amount spent by each customer. If a customer has no orders, display 0 
-- instead of NULL. 

select * from customers;
select * from orders;

select customers.first_name, customers.last_name, coalesce(sum(orders.total_amount), 0) as total_spent
from customers
left join orders on customers.customer_id = orders.customer_id
group by customers.first_name, customers.last_name;

--Or

SELECT 
    c.first_name,
    c.last_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;


--Q8:  Show the order status (Pending, Completed, Failed) based on the payment_status for each order.

select * from orders;
select * from payments;

select orders.order_id,
    case 
        when payments.payment_status = 'Completed' then 'Completed'
        when payments.payment_status = 'Pending' then 'Pending'
        when payments.payment_status = 'Failed' then 'Failed'
        else 'Unknown'
    end as order_status
from orders 
join payments on orders.order_id = payments.order_id;


--Q9:  For each order, apply a 10% discount if the product belongs to the "Electronics" category, and 
-- no discount for others.

select orders.order_id, products.product_name, products.category, orders.total_amount,
case
	when products.category ='Electronics' then orders.total_amount * 0.90
	else orders.total_amount
end as discounted_price
from orders
join products on products.product_id = orders.product_id;

--Or

SELECT 
    o.order_id,
    p.product_name,
    p.category,
    o.total_amount,
    CASE 
        WHEN p.category = 'Electronics' THEN o.total_amount * 0.90
        ELSE o.total_amount
    END AS discounted_price
FROM orders o
JOIN products p
    ON o.product_id = p.product_id;


--Q10: Classify customers based on their total spending into different categories:
--	"High spender" for customers who spent more than $500,
--	"Average spender" for those who spent between $200 and $500,
--	"Low spender" for those who spent less than $200.

select customers.first_name, customers.last_name, sum(orders.total_amount) as total_spent,
case
	when sum(orders.total_amount) > 500 then 'High spender'
	when sum(orders.total_amount) between 200 and 500 then 'Average spender'
	else 'Low spender'
end as spending_category
from customers
join orders on orders.customer_id = customers.customer_id
group by customers.first_name, customers.last_name;

--Or

SELECT 
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) > 500 THEN 'High spender'
        WHEN SUM(o.total_amount) BETWEEN 200 AND 500 THEN 'Average spender'
        ELSE 'Low spender'
    END AS spending_category
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.first_name, c.last_name;



--Q11: a) Find Customers with Multiple Orders:
-- Show all customers who have placed more than one order, including the count of orders they placed.

select customers.first_name, customers.last_name, 
count(orders.order_id) as total_orders
from customers
join orders on orders.customer_id = customers.customer_id
group by customers.first_name, customers.last_name
having count(orders.order_id) > 1;

--Or 

SELECT 
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1;


--Q12: b) Total Spend per Category:
-- Find the total amount spent per product category, only for categories where the total spending is 
-- over $500.

select products.category, sum(orders.total_amount) as total_spent
from orders
join products on products.product_id = orders.product_id
group by products.category
having sum(orders.total_amount) >500;

--Or

SELECT 
    p.category,
    SUM(o.total_amount) AS total_spent
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
HAVING SUM(o.total_amount) > 500;


--Q13: a) Find Customers’ First and Last Orders:
-- Find the first and last orders placed by each customer, including the order date.

select customers.first_name, customers.last_name, 
min(orders.order_date) as first_order, max(orders.order_date) as last_order
from customers
join orders on orders.customer_id = customers.customer_id
group by customers.first_name, customers.last_name;

--Or

SELECT 
    c.first_name,
    c.last_name,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.first_name, c.last_name;


--Q14: b) Top 3 Customers by Spending:
-- Find the top 3 customers who spent the most, including their total spending.

select customers.first_name, customers.last_name, 
sum(orders.total_amount) as total_spent
from customers
join orders on orders.customer_id = customers.customer_id
group by customers.first_name, customers.last_name
order by total_spent desc
limit 3;

--Or

SELECT 
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 3;

