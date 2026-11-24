-- MiniSQL User Manual: run once in a NEW, empty teaching database.
-- Schema changes are deliberately outside an explicit transaction.
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    city VARCHAR(60),
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    CHECK (stock >= 0)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_status VARCHAR(20) NOT NULL DEFAULT 'new'
);

CREATE TABLE order_items (
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

BEGIN;
INSERT INTO customers(customer_id,name,city,active) VALUES
    (1,'Ada','London',TRUE),
    (2,'Grace','New York',TRUE),
    (3,'Linus','Helsinki',TRUE),
    (4,'Margaret',NULL,FALSE);

INSERT INTO products(product_id,name,price,stock) VALUES
    (101,'Mechanical Keyboard',79.90,12),
    (102,'Optical Mouse',24.50,30),
    (103,'USB-C Cable',9.50,100),
    (104,'Monitor Stand',39.00,8),
    (105,'Notebook',4.50,50);

INSERT INTO orders(order_id,customer_id,order_status) VALUES
    (1001,1,'new'),(1002,2,'shipped'),
    (1003,1,'paid'),(1004,3,'new');

INSERT INTO order_items(order_id,product_id,quantity,unit_price) VALUES
    (1001,101,1,79.90),(1001,103,2,9.50),
    (1002,102,2,24.50),(1002,103,1,9.50),
    (1003,105,3,4.50),(1004,104,1,39.00);
COMMIT;

SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS order_count FROM orders;
SELECT COUNT(*) AS item_count FROM order_items;
