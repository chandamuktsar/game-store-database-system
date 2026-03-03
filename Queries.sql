-- Active: 1760710186413@@127.0.0.1@3306@game_store
-- ==========================================================
USE Game_Store;
--- 1. What is the average price of all miniatures that are 32mm scale and made of metal?
CREATE VIEW v_product_average_price AS
SELECT 
    pc.name AS category_name,
    ad.attribute_name,
    pav.attribute_value,
    AVG(p.price) AS average_price
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
LEFT JOIN product_attribute_values pav ON p.product_id = pav.product_id
LEFT JOIN attribute_definitions ad ON pav.attribute_id = ad.attribute_id
GROUP BY pc.name, ad.attribute_name, pav.attribute_value;

-- Fetch the average price for miniatures that are 32mm and metal
SELECT average_price, category_name
FROM v_product_average_price
WHERE category_name = 'Miniatures'
  AND attribute_name = 'Scale'
  AND attribute_value = '32mm';

-- Optional: Find average price for metal dice (for cross-checking)
SELECT average_price, category_name
FROM v_product_average_price
WHERE category_name = 'Dice'
  AND attribute_name = 'Material'
  AND attribute_value = 'Metal';

-- Alternative method without using a view
SELECT AVG(p.price) AS average_price, c.name
FROM products p
JOIN product_categories c ON p.category_id = c.category_id
JOIN product_attribute_values pav1 ON p.product_id = pav1.product_id
JOIN attribute_definitions ad1 ON pav1.attribute_id = ad1.attribute_id
JOIN product_attribute_values pav2 ON p.product_id = pav2.product_id
JOIN attribute_definitions ad2 ON pav2.attribute_id = ad2.attribute_id
WHERE c.name = 'Miniatures'
  AND ad1.attribute_name = 'Scale' AND pav1.attribute_value = '32mm'
  AND ad2.attribute_name = 'Material' AND pav2.attribute_value = 'Metal';

--- 2 . Which customer has spent the most on board games in the last six months?
SELECT c.name, SUM(pu.total_price) AS total_spent
FROM purchases pu
JOIN products p ON pu.product_id = p.product_id
JOIN product_categories pc ON p.category_id = pc.category_id
JOIN customers c ON pu.customer_id = c.customer_id
WHERE pc.name = 'Board Games'
  AND DATEDIFF(CURDATE(), pu.purchase_date) <= 180   -- within 6 months
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 1;


-- 3a. Count tables that can seat 6+ players and have a screen
SELECT COUNT(DISTINCT gt.gametables_id) AS total_tables
FROM gametables gt
JOIN tablefeaturebridge tfb ON gt.gametables_id = tfb.gametables_id
JOIN table_features tf ON tfb.feature_id = tf.feature_id
WHERE gt.capacity >= 6 AND tf.feature_name = 'Screen';

-- 3b. Check availability next Tuesday (2025-11-18) from 12 PM–6 PM and estimated cost
SELECT 
    gt.gametables_id,
    gt.capacity,
    gt.rate_peak AS hourly_rate,
    (6 * gt.rate_peak) AS estimated_cost
FROM gametables gt
JOIN tablefeaturebridge tfb ON gt.gametables_id = tfb.gametables_id
JOIN table_features tf ON tfb.feature_id = tf.feature_id
WHERE 
    gt.capacity >= 6
    AND tf.feature_name = 'Screen'
    AND gt.status = 'Available'
    AND gt.gametables_id NOT IN (
        SELECT gametables_id
        FROM reservations
        WHERE start_time < '2025-11-18 18:00:00' 
          AND end_time > '2025-11-18 12:00:00'
    )
LIMIT 3;

--- 4. What was our busiest day for table rentals last month, measured 
-- by total number of table-hours booked?
DROP VIEW IF EXISTS v_reservation_summary;

CREATE VIEW v_reservation_summary AS
SELECT 
    DATE(r.start_time) AS reservation_date,
    COUNT(r.reservation_id) AS total_reservations,
    SUM(HOUR(r.end_time) - HOUR(r.start_time)) AS total_hours
FROM reservations r
GROUP BY DATE(r.start_time);

-- Find busiest day in last month based on total hours booked
SELECT reservation_date, total_hours
FROM v_reservation_summary
WHERE MONTH(reservation_date) = MONTH(CURDATE()) - 1 
ORDER BY total_hours DESC
LIMIT 1;

-- Alternate (manual range for October 2025)
SELECT DATE(start_time) AS reservation_day,
       SUM(HOUR(end_time) - HOUR(start_time)) AS total_table_hours
FROM reservations
WHERE start_time BETWEEN '2025-10-01' AND '2025-10-31'
GROUP BY reservation_day
ORDER BY total_table_hours DESC
LIMIT 1;

--- 5. Show all dice products that come in sets of 7 or more, ordered by price per die.
SELECT 
    p.product_id, 
    p.name AS product_name,
    pav.attribute_value AS number_of_dice,
    p.price,
    ROUND((p.price / pav.attribute_value),2) AS price_per_die
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
JOIN product_attribute_values pav ON p.product_id = pav.product_id
JOIN attribute_definitions ad ON pav.attribute_id = ad.attribute_id
WHERE pc.name = 'Dice'
  AND ad.attribute_name = 'Quantity'
  AND pav.attribute_value >= 7
ORDER BY price_per_die ASC;


--- 6.  Which product category generated the highest revenue in the last 12 months?
SELECT 
    pc.name AS category_name,
    SUM(pur.total_price) AS total_revenue
FROM purchases pur
JOIN products p ON pur.product_id = p.product_id
JOIN product_categories pc ON p.category_id = pc.category_id
WHERE DATEDIFF(CURDATE(), pur.purchase_date) <= 365  -- within 12 months
GROUP BY pc.name
ORDER BY total_revenue DESC
LIMIT 1;
 
--- 7 Find all table reservations that overlap with peak pricing hours and 
--calculate each of their total costs, including peak prices for the portions that are in peak hours.
SELECT 
    r.reservation_id,
    c.name AS customer_name,
    gt.gametables_id,
    (HOUR(r.end_time) - HOUR(r.start_time)) * gt.rate_peak * pt.multiplier AS total_cost
FROM reservations r
JOIN customers c ON r.customer_id = c.customer_id
JOIN gametables gt ON r.gametables_id = gt.gametables_id
JOIN pricing_tiers pt ON gt.tier_id = pt.tier_id
WHERE pt.description = 'Peak Hours'
  AND (
       HOUR(r.start_time) < 23
       AND HOUR(r.end_time) > 17
      );


--- 8 List all customers who have purchased a rulebook but have never booked a table
SELECT DISTINCT c.customer_id, c.name
FROM customers c
JOIN purchases p ON c.customer_id = p.customer_id
JOIN products pr ON p.product_id = pr.product_id
WHERE pr.product_type LIKE '%Rulebook%'
  AND c.customer_id NOT IN (SELECT customer_id FROM reservations);


 --- 9 a
 -- Top 3 customers by total spending
SELECT c.customer_id, c.name, SUM(p.total_price) AS total_spent
FROM customers c
JOIN purchases p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 3;
--- 9 b Top 3 customers by categories 
SELECT c.name, pc.name AS category, SUM(pu.total_price) AS spent
FROM Purchases pu
JOIN Products pr ON pu.product_id = pr.product_id
JOIN Product_categories pc ON pr.category_id = pc.category_id
JOIN Customers c ON pu.customer_id = c.customer_id
GROUP BY c.name, pc.name
ORDER BY c.name, spent DESC
LIMIT 9; 

--- 10. List all tables that had no reservations in the last 30 days.
SELECT gametables_id, capacity, status
FROM gametables
WHERE gametables_id NOT IN (
    SELECT gametables_id
    FROM reservations
    WHERE DATEDIFF(CURDATE(), start_time) <= 30
);

--- 11. Which category (or combination of categories) appears most often?  Show all of them, ordered by number of products.
SELECT pc.name AS category_name, COUNT(*) AS product_count
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
GROUP BY pc.name
ORDER BY product_count DESC;

--- 12.A group of 5 friends want to buy the board game “Betrayal at House on the Hill” 
--- and reserve a table to play it tomorrow.The players would like a table with drink holders. 
--- Find all tables that are available to be booked to meet their needs. 
---Keep in mind the average play time of the board game.

CREATE OR REPLACE VIEW v_table_availability AS
SELECT 
    gt.gametables_id,
    gt.capacity,
    gt.status,
    tf.feature_name
FROM gametables gt
LEFT JOIN tablefeaturebridge tfb ON gt.gametables_id = tfb.gametables_id
LEFT JOIN table_features tf ON tfb.feature_id = tf.feature_id;

-- Find tables with a screen and at least 6 seats
SELECT * FROM v_table_availability
WHERE capacity >= 6 AND feature_name = 'Screen' AND status = 'Available';



-- Find available tables with cup holders for 5 players (no overlapping bookings)
SELECT gt.gametables_id, gt.capacity, gt.status, tf.feature_name
FROM gametables gt
JOIN tablefeaturebridge tfb ON gt.gametables_id = tfb.gametables_id
JOIN table_features tf ON tfb.feature_id = tf.feature_id
WHERE gt.capacity >= 5
  AND gt.status = 'Available'
  AND tf.feature_name = 'Cup Holders'
  AND gt.gametables_id NOT IN (
      SELECT gametables_id
      FROM reservations
      WHERE start_time < '2025-11-15'
        AND end_time > '2025-11-15'
  );

















