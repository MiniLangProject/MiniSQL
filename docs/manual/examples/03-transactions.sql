-- Reversible experiments; the final teaching dataset is unchanged.
BEGIN;
UPDATE products SET stock=stock-1 WHERE product_id=101;
SELECT stock AS after_first_update FROM products WHERE product_id=101;
SAVEPOINT before_second;
UPDATE products SET stock=stock-2 WHERE product_id=101;
SELECT stock AS after_second_update FROM products WHERE product_id=101;
ROLLBACK TO before_second;
SELECT stock AS after_savepoint_rollback FROM products WHERE product_id=101;
RELEASE before_second;
ROLLBACK;
SELECT stock AS after_full_rollback FROM products WHERE product_id=101;

BEGIN;
INSERT INTO customers(customer_id,name,city) VALUES(99,'Practice','Oslo')
RETURNING customer_id,name;
UPDATE customers SET city='Bergen' WHERE customer_id=99
RETURNING customer_id,city;
DELETE FROM customers WHERE customer_id=99 RETURNING customer_id;
ROLLBACK;
SELECT COUNT(*) AS practice_rows FROM customers WHERE customer_id=99;
