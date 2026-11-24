-- Read-only advanced query practice on the shop dataset.
WITH units AS (
    SELECT order_id,SUM(quantity) AS unit_count
    FROM order_items GROUP BY order_id
)
SELECT o.order_id,c.name,u.unit_count
FROM orders o JOIN customers c ON c.customer_id=o.customer_id
JOIN units u ON u.order_id=o.order_id
ORDER BY o.order_id;

SELECT c.customer_id,c.name FROM customers c
LEFT JOIN orders o ON o.customer_id=c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

SELECT order_id,customer_id,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_id) AS customer_order
FROM orders ORDER BY customer_id,order_id;

SELECT name,CASE WHEN active THEN 'active' ELSE 'inactive' END AS state,
       COALESCE(city,'not recorded') AS recorded_city
FROM customers ORDER BY customer_id;

WITH RECURSIVE numbers(n) AS (
    SELECT 1
    UNION ALL
    SELECT n+1 FROM numbers WHERE n<5
)
SELECT n FROM numbers ORDER BY n;
