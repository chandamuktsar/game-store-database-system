-- Active: 1760710186413@@127.0.0.1@3306@game_store


DROP DATABASE IF EXISTS game_store;
CREATE DATABASE IF NOT EXISTS game_store;
USE game_store;

-- ==========================================================
-- TABLE CREATION
-- ==========================================================

CREATE TABLE product_categories (
    category_id SMALLINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TINYTEXT
);
SELECT * FROM product_categories;


CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id SMALLINT NOT NULL,
    product_type VARCHAR(50),
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    description TINYTEXT,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);
SELECT * FROM products;


CREATE TABLE attribute_definitions (
    attribute_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id SMALLINT NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    data_type VARCHAR(30) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);
SELECT * FROM attribute_definitions;


CREATE TABLE product_attribute_values (
    product_id INT NOT NULL,
    attribute_id INT NOT NULL,
    attribute_value VARCHAR(255),
    PRIMARY KEY (product_id, attribute_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (attribute_id) REFERENCES attribute_definitions(attribute_id)
);
SELECT * FROM product_attribute_values;


CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    loyalty_points INT,
    member_since DATE
);
SELECT * FROM customers;


CREATE TABLE rental_records (
    rental_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rental_date DATETIME NOT NULL,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    rental_fee DECIMAL(10,2),
    late_fee DECIMAL(10,2),
    rental_status VARCHAR(20),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
SELECT * FROM rental_records;


CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity SMALLINT NOT NULL,
    purchase_date DATETIME NOT NULL,
    total_price DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
SELECT * FROM purchases;


CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    purchase_id INT NOT NULL,
    payment_method VARCHAR(50),
    payment_date DATETIME,
    amount DECIMAL(10,2),
    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id)
);
SELECT * FROM payments;


CREATE TABLE pricing_tiers (
    tier_id INT PRIMARY KEY AUTO_INCREMENT,
    description TEXT,
    multiplier FLOAT,
    applicable_hours VARCHAR(50)
);
SELECT * FROM pricing_tiers;


CREATE TABLE gametables (
    gametables_id INT PRIMARY KEY AUTO_INCREMENT,
    capacity TINYINT,
    rate DECIMAL(8,2),
    rate_peak DECIMAL(8,2),
    status VARCHAR(30),
    tier_id INT,
    FOREIGN KEY (tier_id) REFERENCES pricing_tiers(tier_id)
);
SELECT * FROM gametables;


CREATE TABLE table_features (
    feature_id INT PRIMARY KEY AUTO_INCREMENT,
    feature_name VARCHAR(50),
    feature_description TINYTEXT,
    additional_price FLOAT
);
SELECT * FROM table_features;


CREATE TABLE tablefeaturebridge (
    gametables_id INT NOT NULL,
    feature_id INT NOT NULL,
    PRIMARY KEY (gametables_id, feature_id),
    FOREIGN KEY (gametables_id) REFERENCES gametables(gametables_id),
    FOREIGN KEY (feature_id) REFERENCES table_features(feature_id)
);
SELECT * FROM tablefeaturebridge;


CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    gametables_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    payment_status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (gametables_id) REFERENCES gametables(gametables_id)
);
SELECT * FROM reservations;


CREATE TABLE staff_members (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(50),
    email VARCHAR(50),
    role VARCHAR(50),
    phone CHAR(20),
    gender VARCHAR(20)
);
SELECT * FROM staff_members;


CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT,
    event_name VARCHAR(100),
    event_date DATETIME,
    customer_id INT,
    FOREIGN KEY (staff_id) REFERENCES staff_members(staff_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
SELECT * FROM events;


-- ==========================================================
-- INSERTING DUMMY DATA
-- ==========================================================

INSERT INTO product_categories (name, description) VALUES
('Board Games', 'Strategy and party board games'),
('Dice', 'Various sets for tabletop gaming'),
('Miniatures', 'Collectible and RPG miniatures'),
('Rulebooks', 'Game rule references and expansions');

INSERT INTO products (category_id, product_type, name, price, stock_quantity, description) VALUES
(1, 'Board Game', 'Catan', 49.99, 10, 'Classic trading and building board game'),
(1, 'Board Game', 'Betrayal at House on the Hill', 39.99, 8, 'Haunted mansion exploration game'),
(2, 'Dice', 'Metal Dice Set', 19.99, 25, 'Set of metal RPG dice'),
(3, 'Miniature', 'Dragon Figure 32mm', 24.99, 12, '32mm metal dragon figure'),
(4, 'Rulebook', 'D&D 5E Core Rules', 59.99, 5, 'Core rulebook for Dungeons & Dragons');

INSERT INTO attribute_definitions (category_id, attribute_name, data_type) VALUES
(2, 'Material', 'TEXT'),
(2, 'Quantity', 'INTEGER'),
(3, 'Scale', 'TEXT'),
(3, 'Material', 'TEXT'),
(1, 'Min Players', 'INTEGER'),
(1, 'Max Players', 'INTEGER');

INSERT INTO product_attribute_values (product_id, attribute_id, attribute_value) VALUES
(3, 1, 'Metal'),
(3, 2, '7'),
(4, 3, '32mm'),
(4, 4, 'Metal'),
(1, 5, '3'),
(1, 6, '6'),
(2, 5, '3'),
(2, 6, '5');

INSERT INTO customers (name, email, phone, loyalty_points, member_since) VALUES
('Alice Green', 'alice@gmail.com', '6471112222', 120, '2022-08-01'),
('Bob Smith', 'bob@yahoo.com', '6473334444', 200, '2023-03-12'),
('Charlie Brown', 'charlie@hotmail.com', '6475556666', 50, '2024-01-20'),
('David King', 'david@gmail.com', '6478889999', 30, '2025-09-01');

INSERT INTO rental_records (product_id, customer_id, rental_date, due_date, return_date, rental_fee, late_fee, rental_status) VALUES
(1, 1, '2025-11-01 10:00:00', '2025-11-03 10:00:00', '2025-11-03 09:30:00', 10.00, 0.00, 'Returned'),
(2, 2, '2025-11-02 14:00:00', '2025-11-04 14:00:00', NULL, 12.00, 0.00, 'Active');

INSERT INTO purchases (customer_id, product_id, quantity, purchase_date, total_price) VALUES
(1, 5, 1, '2025-10-10 11:00:00', 59.99),
(2, 1, 1, '2025-10-12 15:00:00', 49.99),
(4, 5, 1, '2025-10-20 14:00:00', 59.99),
(1, 1, 1, '2025-10-10 11:00:00', 49.99), 
(1, 3, 2, '2025-10-11 12:00:00', 39.98), 
(1, 5, 1, '2025-10-12 14:30:00', 59.99),   
(2, 1, 2, '2025-10-13 15:00:00', 99.98),
(2, 4, 1, '2025-10-14 16:00:00', 24.99),   
(2, 5, 1, '2025-10-15 17:00:00', 59.99),   
(3, 3, 3, '2025-10-16 18:00:00', 59.97),
(3, 5, 2, '2025-10-17 19:00:00', 119.98), 
(4, 4, 2, '2025-10-18 10:00:00', 49.98),   
(4, 2, 1, '2025-10-20 14:00:00', 39.99);

INSERT INTO payments (purchase_id, payment_method, payment_date, amount) VALUES
(1, 'Credit Card', '2025-10-10 11:05:00', 49.99),
(2, 'Credit Card', '2025-10-11 12:10:00', 39.98),
(3, 'Debit Card',  '2025-10-12 14:35:00', 59.99),
(4, 'Cash',        '2025-10-13 15:10:00', 99.98),
(5, 'Credit Card', '2025-10-14 16:05:00', 24.99),
(6, 'Credit Card', '2025-10-15 17:05:00', 59.99),
(7, 'Debit Card',  '2025-10-16 18:10:00', 59.97),
(8, 'Credit Card', '2025-10-17 19:05:00', 119.98),
(9, 'Cash',        '2025-10-18 10:05:00', 49.98),
(10, 'Credit Card','2025-10-20 14:05:00', 39.99);

INSERT INTO pricing_tiers (description, multiplier, applicable_hours) VALUES
('Off-Peak', 1.0, '09:00-17:00'),
('Peak Hours', 1.25, '17:00-23:00');

INSERT INTO gametables (capacity, rate, rate_peak, status, tier_id) VALUES
(4, 10.00, 15.00, 'Available', 1),
(6, 15.00, 20.00, 'Available', 2),
(8, 20.00, 25.00, 'Available', 2),
(6, 18.00, 25.00, 'Available', 2),
(8 ,12.00, 18.00, 'Available', 1);

INSERT INTO table_features (feature_name, feature_description, additional_price) VALUES
('Screen', 'Built-in digital screen for RPGs', 5.00),
('LED Lighting', 'Mood lighting for immersive gameplay', 3.00),
('Cup Holders', 'Holders for drinks', 2.00);

INSERT INTO tablefeaturebridge (gametables_id, feature_id) VALUES
(1, 3),
(2, 1),
(2, 2),
(3, 1),
(4, 3),
(5, 1);

INSERT INTO reservations (customer_id, gametables_id, start_time, end_time, payment_status) VALUES
(1, 1, '2025-11-05 12:00:00', '2025-11-05 15:00:00', 'Paid'),
(2, 2, '2025-11-06 18:00:00', '2025-11-06 21:00:00', 'Pending'),
(3, 3, '2025-10-22 14:00:00', '2025-10-22 20:00:00', 'Paid'),
(2, 4, '2025-11-13 18:00:00', '2025-11-13 21:00:00', 'Pending');

INSERT INTO staff_members (full_name, email, role, phone, gender) VALUES
('Jamie Torres', 'jamie@store.com', 'Manager', '6477778888', 'Male'),
('Sophia Lee', 'sophia@store.com', 'Event Coordinator', '6479990000', 'Female');

INSERT INTO events (staff_id, event_name, event_date, customer_id) VALUES
(2, 'Board Game Night', '2025-11-10 18:00:00', 1),
(1, 'Holiday Tournament', '2025-12-20 14:00:00', 2);
