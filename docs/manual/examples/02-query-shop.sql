-- Read-only examples. Run after 01-create-shop.sql.
SELECT customer_id,name,city,active
FROM customers ORDER BY customer_id;

SELECT product_id,name,stock
FROM products WHERE stock < 15 ORDER BY stock,product_id;

SELECT customer_id,name FROM customers
WHERE city IS NULL ORDER BY customer_id;

SELECT COUNT(city) AS known_cities,COUNT(*) AS customers
FROM customers;

SELECT o.order_id,c.name,o.order_status
FROM orders o JOIN customers c ON c.customer_id=o.customer_id
ORDER BY o.order_id;

SELECT c.name,COUNT(o.order_id) AS order_count
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
GROUP BY c.name ORDER BY c.name;

SELECT c.name,SUM(i.quantity) AS units
FROM customers c
JOIN orders o ON o.customer_id=c.customer_id
JOIN order_items i ON i.order_id=o.order_id
GROUP BY c.name HAVING SUM(i.quantity)>=3
ORDER BY c.name;

SELECT product_id,name,stock FROM products
ORDER BY stock DESC,product_id LIMIT 2;

SELECT SUM(quantity) AS total_units FROM order_items;

-- Protocol v1 prints the stored DECIMAL coefficient: 7990 means 79.90.
SELECT product_id,price FROM products WHERE product_id=101;
