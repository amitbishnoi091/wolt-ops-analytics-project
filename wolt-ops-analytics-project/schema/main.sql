-- =====================================================
-- 🚀 Wolt Ops — MySQL 8 Synthetic Data Generator
-- =====================================================

-- -------------------------
-- BLOCK 0: Setup / Database
-- -------------------------
CREATE DATABASE IF NOT EXISTS wolt_ops;
USE wolt_ops;

-- -------------------------
-- BLOCK 1: CREATE TABLES
-- -------------------------
DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100),
    country VARCHAR(50),
    timezone VARCHAR(50),
    population INT,
    sla_target_mins INT,
    market_tier VARCHAR(10),
    is_active BOOLEAN
);

DROP TABLE IF EXISTS neighborhoods;
CREATE TABLE neighborhoods (
    nb_id VARCHAR(30) PRIMARY KEY,
    city_id INT,
    name VARCHAR(100),
    avg_distance_modifier FLOAT
);

DROP TABLE IF EXISTS couriers;
CREATE TABLE couriers (
    courier_id VARCHAR(30) PRIMARY KEY,
    city_id INT,
    onboard_date DATE,
    activation_date DATE,
    status VARCHAR(20),
    vehicle_type VARCHAR(20),
    rating FLOAT,
    source VARCHAR(20)
);

DROP TABLE IF EXISTS courier_onboard;
CREATE TABLE courier_onboard (
    onboard_id VARCHAR(30) PRIMARY KEY,
    courier_id VARCHAR(30),
    city_id INT,
    activated_at DATETIME,
    source VARCHAR(20)
);

DROP TABLE IF EXISTS courier_shifts;
CREATE TABLE courier_shifts (
    shift_id VARCHAR(50) PRIMARY KEY,
    courier_id VARCHAR(30),
    city_id INT,
    date DATE,
    shift_start TIME,
    shift_end TIME,
    online_hours FLOAT,
    acceptance_rate FLOAT,
    completion_rate FLOAT,
    earnings_eur FLOAT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id VARCHAR(30) PRIMARY KEY,
    full_name VARCHAR(100),
    city_id INT,
    signup_date DATE,
    last_active_date DATE,
    lifetime_orders INT,
    avg_order_value FLOAT,
    cancellation_rate FLOAT,
    complaint_rate FLOAT,
    segment VARCHAR(20),
    is_prime BOOLEAN,
    phone VARCHAR(20),
    email VARCHAR(50)
);

DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants (
    restaurant_id VARCHAR(30) PRIMARY KEY,
    restaurant_name VARCHAR(100),
    city_id INT,
    cuisine_type VARCHAR(50),
    open_time TIME,
    close_time TIME,
    avg_prep_time INT,
    rating FLOAT,
    total_reviews INT,
    is_verified BOOLEAN,
    delivery_fee FLOAT,
    popularity_score INT
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(30),
    restaurant_id VARCHAR(30),
    city_id INT,
    order_datetime DATETIME,
    delivery_datetime DATETIME,
    order_value FLOAT,
    delivery_fee FLOAT,
    discount_applied FLOAT,
    order_status VARCHAR(20),
    payment_method VARCHAR(20),
    courier_id VARCHAR(30),
    estimated_sla_mins INT,
    actual_sla_mins INT,
    rating_given INT,
    is_prime BOOLEAN,
    address VARCHAR(200),
    reason_cancel VARCHAR(50),
    complaint_flag BOOLEAN
);

DROP TABLE IF EXISTS complaints;
CREATE TABLE complaints (
    complaint_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    city_id INT,
    courier_id VARCHAR(30),
    created_at DATETIME,
    category VARCHAR(50),
    notes TEXT
);

DROP TABLE IF EXISTS okrs;
CREATE TABLE okrs (
    okr_id VARCHAR(50) PRIMARY KEY,
    city_id INT,
    week_start DATE,
    target_avg_delivery_mins FLOAT,
    target_cancellation_rate FLOAT,
    notes TEXT
);

DROP TABLE IF EXISTS order_seed;
CREATE TABLE order_seed (
    customer_id VARCHAR(50),
    restaurant_id VARCHAR(50),
    city_id INT,
    is_prime BOOLEAN,
    avg_prep_time INT,
    popularity_score INT,
    sla_target_mins INT,
    rand_courier_id VARCHAR(50),
    rand_address VARCHAR(200),
    order_datetime DATETIME
);

-- =====================================================
-- BLOCK 2: Seed cities
-- =====================================================
TRUNCATE TABLE cities;
INSERT INTO cities (city_id, city_name, country, timezone, population, sla_target_mins, market_tier, is_active)
VALUES
(1,'Berlin','Germany','Europe/Berlin',3645000,30,'Tier-1',TRUE),
(2,'Hamburg','Germany','Europe/Berlin',1840000,30,'Tier-1',TRUE),
(3,'Munich','Germany','Europe/Berlin',1472000,28,'Tier-1',TRUE),
(4,'Cologne','Germany','Europe/Berlin',1086000,32,'Tier-2',TRUE),
(5,'Frankfurt','Germany','Europe/Berlin',753000,32,'Tier-2',TRUE),
(6,'Stuttgart','Germany','Europe/Berlin',634000,33,'Tier-2',TRUE),
(7,'Dusseldorf','Germany','Europe/Berlin',619000,34,'Tier-2',TRUE),
(8,'Dortmund','Germany','Europe/Berlin',588000,35,'Tier-2',TRUE),
(9,'Essen','Germany','Europe/Berlin',583000,35,'Tier-3',TRUE),
(10,'Leipzig','Germany','Europe/Berlin',587000,35,'Tier-3',TRUE),
(11,'Bremen','Germany','Europe/Berlin',569000,35,'Tier-3',TRUE),
(12,'Hannover','Germany','Europe/Berlin',536000,35,'Tier-3',TRUE);

-- =====================================================
-- BLOCK 3: Seed neighborhoods (~10 per city)
-- =====================================================
TRUNCATE TABLE neighborhoods;
INSERT INTO neighborhoods (nb_id, city_id, name, avg_distance_modifier)
SELECT
    CONCAT('NB_', c.city_id, '_', n) AS nb_id,
    c.city_id,
    CONCAT('NB_', c.city_id, '_', n) AS name,
    ROUND(0.8 + RAND()*1.8,2)
FROM cities c
JOIN (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
      UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) nums;

-- =====================================================
-- BLOCK 4: Seed couriers (~200 per city)
-- =====================================================
TRUNCATE TABLE couriers;
INSERT INTO couriers (courier_id, city_id, onboard_date, activation_date, status, vehicle_type, rating, source)
SELECT
    CONCAT('COU_', c.city_id, '_', LPAD(n,4,'0')) AS courier_id,
    c.city_id,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*730) DAY),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*60) DAY),
    ELT(FLOOR(RAND()*4)+1,'active','inactive','suspended','churned'),
    ELT(FLOOR(RAND()*4)+1,'bike','bicycle','scooter','car'),
    ROUND(2.6 + RAND()*2.2,2),
    ELT(FLOOR(RAND()*3)+1,'app','referral','campaign')
FROM cities c
JOIN (
    SELECT a.n + b.n*10 + c.n*100 + d.n*1000 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
    LIMIT 200
) nums;

-- =====================================================
-- BLOCK 5: Generate courier_onboard (~25% of couriers)
-- =====================================================
TRUNCATE TABLE courier_onboard;
INSERT INTO courier_onboard (onboard_id, courier_id, city_id, activated_at, source)
SELECT
    CONCAT('ONB_', courier_id),
    courier_id,
    city_id,
    DATE_ADD(onboard_date, INTERVAL FLOOR(RAND()*30) DAY),
    source
FROM couriers
WHERE RAND() < 0.25;

-- =====================================================
-- BLOCK 6: Generate courier_shifts (~8-20 per courier)
-- =====================================================
TRUNCATE TABLE courier_shifts;
INSERT INTO courier_shifts (shift_id, courier_id, city_id, date, shift_start, shift_end, online_hours, acceptance_rate, completion_rate, earnings_eur)
SELECT
    CONCAT('S_', courier_id, '_', LPAD(n,3,'0')) AS shift_id,
    courier_id,
    city_id,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*90) DAY) AS date,
    SEC_TO_TIME(FLOOR(RAND()*10)*3600) AS shift_start,
    SEC_TO_TIME((FLOOR(RAND()*10)+2 + FLOOR(RAND()*6))*3600) AS shift_end,
    ROUND(2 + RAND()*6,2) AS online_hours,
    ROUND(0.55 + RAND()*0.4,3) AS acceptance_rate,
    ROUND(0.6 + RAND()*0.35,3) AS completion_rate,
    ROUND(12 + RAND()*80,2) AS earnings_eur
FROM couriers
JOIN (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
      UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
      UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
      UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20) nums
WHERE n <= 20 AND RAND() < 0.7;

-- =====================================================
-- BLOCK 7: Generate customers (~300 per city)
-- =====================================================
TRUNCATE TABLE customers;
INSERT INTO customers (customer_id, full_name, city_id, signup_date, last_active_date, lifetime_orders, avg_order_value, cancellation_rate, complaint_rate, segment, is_prime, phone, email)
SELECT
    CONCAT('CUS_', city_id, '_', LPAD(n,5,'0')) AS customer_id,
    CONCAT(
        ELT(FLOOR(RAND()*12)+1,'Anna','Lukas','Sophia','Leon','Marie','Finn','Laura','Ben','Emma','Paul','Jonas','Mia'),
        ' ',
        ELT(FLOOR(RAND()*12)+1,'Mueller','Schmidt','Fischer','Weber','Meyer','Wagner','Becker','Hoffmann','Schaefer','Koch','Zimmer','Klein')
    ) AS full_name,
    city_id,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*2000) DAY) AS signup_date,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*400) DAY) AS last_active_date,
    FLOOR(RAND()*200) AS lifetime_orders,
    ROUND(8 + RAND()*40,2) AS avg_order_value,
    ROUND(0.01 + RAND()*0.12,3) AS cancellation_rate,
    ROUND(0.001 + RAND()*0.02,3) AS complaint_rate,
    ELT(FLOOR(RAND()*4)+1,'VIP','Regular','New','Dormant') AS segment,
    RAND()<0.12 AS is_prime,
    CONCAT('+49', FLOOR(100000000 + RAND()*900000000)) AS phone,
    CONCAT(LOWER(ELT(FLOOR(RAND()*12)+1,'anna','lukas','sophia','leon','marie','finn','laura','ben','emma','paul','jonas','mia')),
           FLOOR(RAND()*9999),'@mail.com') AS email
FROM cities c
JOIN (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
      UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
      UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
      UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
      UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25
      UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30
      UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35
      UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40
      UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45
      UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50
      UNION ALL SELECT 51 UNION ALL SELECT 52 UNION ALL SELECT 53 UNION ALL SELECT 54 UNION ALL SELECT 55
      UNION ALL SELECT 56 UNION ALL SELECT 57 UNION ALL SELECT 58 UNION ALL SELECT 59 UNION ALL SELECT 60
      UNION ALL SELECT 61 UNION ALL SELECT 62 UNION ALL SELECT 63 UNION ALL SELECT 64 UNION ALL SELECT 65
      UNION ALL SELECT 66 UNION ALL SELECT 67 UNION ALL SELECT 68 UNION ALL SELECT 69 UNION ALL SELECT 70
      UNION ALL SELECT 71 UNION ALL SELECT 72 UNION ALL SELECT 73 UNION ALL SELECT 74 UNION ALL SELECT 75
      UNION ALL SELECT 76 UNION ALL SELECT 77 UNION ALL SELECT 78 UNION ALL SELECT 79 UNION ALL SELECT 80
      UNION ALL SELECT 81 UNION ALL SELECT 82 UNION ALL SELECT 83 UNION ALL SELECT 84 UNION ALL SELECT 85
      UNION ALL SELECT 86 UNION ALL SELECT 87 UNION ALL SELECT 88 UNION ALL SELECT 89 UNION ALL SELECT 90
      UNION ALL SELECT 91 UNION ALL SELECT 92 UNION ALL SELECT 93 UNION ALL SELECT 94 UNION ALL SELECT 95
      UNION ALL SELECT 96 UNION ALL SELECT 97 UNION ALL SELECT 98 UNION ALL SELECT 99 UNION ALL SELECT 100
) nums
WHERE n <= 300;

-- =====================================================
-- BLOCK 8: Generate restaurants (~40 per city)
-- =====================================================
TRUNCATE TABLE restaurants;
INSERT INTO restaurants (restaurant_id, restaurant_name, city_id, cuisine_type, open_time, close_time, avg_prep_time, rating, total_reviews, is_verified, delivery_fee, popularity_score)
SELECT
    CONCAT('RST_', city_id, '_', LPAD(n,3,'0')) AS restaurant_id,
    CONCAT('R_', city_name, '_', n) AS restaurant_name,
    city_id,
    ELT(FLOOR(RAND()*8)+1,'Italian','German','Turkish','Indian','Chinese','Sushi','Fast Food','Cafe') AS cuisine_type,
    '10:00:00',
    '23:30:00',
    FLOOR(10 + RAND()*40) AS avg_prep_time,
    ROUND(3 + RAND()*2,2) AS rating,
    FLOOR(5 + RAND()*2000) AS total_reviews,
    RAND()<0.6 AS is_verified,
    ROUND(1 + RAND()*4,2) AS delivery_fee,
    FLOOR(10 + RAND()*490) AS popularity_score
FROM cities c
JOIN (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
      UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
      UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
      UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
      UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25
      UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30
      UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35
      UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40) nums;

-- =====================================================
-- BLOCK 9: Generate OKRs (12 weeks)
-- =====================================================
TRUNCATE TABLE okrs;
INSERT INTO okrs (okr_id, city_id, week_start, target_avg_delivery_mins, target_cancellation_rate, notes)
SELECT
    CONCAT('OKR_', city_id, '_', DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL w*7 DAY),'%Y%m%d')) AS okr_id,
    city_id,
    DATE_SUB(CURDATE(), INTERVAL w*7 DAY) AS week_start,
    CASE WHEN market_tier='Tier-1' THEN 30 ELSE 33 END AS target_avg_delivery_mins,
    0.025 AS target_cancellation_rate,
    'auto' AS notes
FROM cities c
JOIN (SELECT 0 w UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
      UNION ALL SELECT 10 UNION ALL SELECT 11) weeks;

-- =====================================================
-- BLOCK 10: Generate orders
-- =====================================================
-- order_seed should be populated beforehand based on customers, restaurants, couriers
-- (omitted here for brevity; logic same as earlier)

-- orders insert
-- complaints insert
-- views: city_daily_summary, customer_segments, courier_performance, top_restaurants
-- Same as your previous block, fully MySQL-compatible

-- =====================================================
-- 🚀 Wolt Ops — Full MySQL 8 Synthetic Data Generator
-- =====================================================

USE wolt_ops;

-- -------------------------
-- BLOCK 10: Generate order_seed (~5 orders per customer)
-- -------------------------
TRUNCATE TABLE order_seed;

-- Step 1: Sample customers
CREATE TEMPORARY TABLE tmp_customers AS
SELECT * 
FROM customers
ORDER BY RAND()
LIMIT 1000;

-- Step 2: Sample restaurants per city
CREATE TEMPORARY TABLE tmp_restaurants AS
SELECT r.*
FROM restaurants r
JOIN tmp_customers c ON r.city_id = c.city_id
ORDER BY RAND();

-- Step 3: Sample couriers per city
CREATE TEMPORARY TABLE tmp_couriers AS
SELECT co.*
FROM courier_shifts co
JOIN tmp_customers c ON co.city_id = c.city_id
ORDER BY RAND();

-- Step 4: Sample neighborhoods per city
CREATE TEMPORARY TABLE tmp_neighborhoods AS
SELECT nb.*
FROM neighborhoods nb
JOIN tmp_customers c ON nb.city_id = c.city_id
ORDER BY RAND();

-- Step 5: Insert into order_seed
INSERT INTO order_seed (customer_id, restaurant_id, city_id, is_prime, avg_prep_time, popularity_score, sla_target_mins, rand_courier_id, rand_address, order_datetime)
SELECT
    c.customer_id,
    r.restaurant_id,
    c.city_id,
    c.is_prime,
    r.avg_prep_time,
    r.popularity_score,
    ci.sla_target_mins,
    co.courier_id,
    CONCAT('Street ', FLOOR(RAND()*200+1), ', ', nb.name) AS rand_address,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*90) DAY) + INTERVAL FLOOR(RAND()*10) HOUR + INTERVAL FLOOR(RAND()*60) MINUTE
FROM tmp_customers c
JOIN tmp_restaurants r ON r.city_id = c.city_id
JOIN cities ci ON ci.city_id = c.city_id
JOIN tmp_couriers co ON co.city_id = c.city_id
JOIN tmp_neighborhoods nb ON nb.city_id = c.city_id
LIMIT 50000;



-- -------------------------
-- BLOCK 11: Generate orders
-- -------------------------
-- -------------------------
-- BLOCK 11: Generate orders safely (~1000-100k rows per run)
-- -------------------------
INSERT INTO orders (
    order_id, customer_id, restaurant_id, city_id, order_datetime, delivery_datetime,
    order_value, delivery_fee, discount_applied, order_status, payment_method,
    courier_id, estimated_sla_mins, actual_sla_mins, rating_given, is_prime,
    address, reason_cancel, complaint_flag
)
SELECT
    UUID() AS order_id,  -- guaranteed unique
    os.customer_id,
    os.restaurant_id,
    os.city_id,
    os.order_datetime,
    os.order_datetime + INTERVAL (os.avg_prep_time + FLOOR(RAND()*30)) MINUTE AS delivery_datetime,
    ROUND(8 + RAND()*40,2) AS order_value,
    ROUND(1 + RAND()*4,2) AS delivery_fee,
    ROUND(RAND()*5,2) AS discount_applied,
    ELT(FLOOR(RAND()*4)+1,'delivered','cancelled','failed','returned') AS order_status,
    ELT(FLOOR(RAND()*3)+1,'card','paypal','cash') AS payment_method,
    os.rand_courier_id AS courier_id,
    os.sla_target_mins AS estimated_sla_mins,
    os.sla_target_mins + FLOOR(RAND()*20-5) AS actual_sla_mins,
    FLOOR(RAND()*5)+1 AS rating_given,
    os.is_prime,
    os.rand_address AS address,
    IF(RAND()<0.05, ELT(FLOOR(RAND()*3)+1,'late','wrong_item','customer_cancel'), NULL) AS reason_cancel,
    RAND()<0.1 AS complaint_flag  -- 10% complaints for testing
FROM order_seed os;



-- -------------------------
-- BLOCK 12: Generate complaints from flagged orders
-- -------------------------
-- -------------------------
-- BLOCK 12: Generate complaints safely
-- -------------------------
INSERT INTO complaints (
    complaint_id, order_id, city_id, courier_id, created_at, category, notes
)
SELECT
    UUID() AS complaint_id,  -- guaranteed unique
    o.order_id,
    o.city_id,
    o.courier_id,
    o.delivery_datetime + INTERVAL FLOOR(RAND()*48) HOUR AS created_at,
    ELT(FLOOR(RAND()*3)+1,'late_delivery','missing_item','rude_courier') AS category,
    'Auto-generated complaint note'
FROM orders o
WHERE o.complaint_flag = TRUE;



-- =====================================================
-- BLOCK 13: Views for analytics
-- =====================================================

-- City Daily Summary
CREATE OR REPLACE VIEW city_daily_summary AS
SELECT
    city_id,
    DATE(order_datetime) AS order_date,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status='cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN complaint_flag=TRUE THEN 1 ELSE 0 END) AS complaints,
    ROUND(AVG(actual_sla_mins),2) AS avg_delivery_mins,
    ROUND(SUM(order_value),2) AS total_revenue
FROM orders
GROUP BY city_id, DATE(order_datetime);

-- Customer Segments
CREATE OR REPLACE VIEW customer_segments AS
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(lifetime_orders),2) AS avg_orders,
    ROUND(AVG(avg_order_value),2) AS avg_order_value
FROM customers
GROUP BY segment;

-- Courier Performance
CREATE OR REPLACE VIEW courier_performance AS
SELECT
    c.courier_id,
    c.city_id,
    COUNT(o.order_id) AS orders_handled,
    ROUND(AVG(o.actual_sla_mins),2) AS avg_delivery_time,  -- use orders table
    ROUND(AVG(s.earnings_eur),2) AS avg_shift_earnings
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.courier_id
LEFT JOIN courier_shifts s ON s.courier_id = c.courier_id
GROUP BY c.courier_id, c.city_id;


-- Top Restaurants by Revenue
CREATE OR REPLACE VIEW top_restaurants AS
SELECT
    restaurant_id,
    city_id,
    COUNT(order_id) AS orders_count,
    ROUND(SUM(order_value),2) AS total_revenue,
    ROUND(AVG(rating_given),2) AS avg_rating
FROM orders
GROUP BY restaurant_id, city_id
ORDER BY total_revenue DESC;

-- =====================================================
-- ✅ FULL SCRIPT COMPLETE
-- =====================================================
-- =====================================================
-- BLOCK 14: Generate Synthetic OKRs (~12 weeks per city)
-- =====================================================

TRUNCATE TABLE okrs;

INSERT INTO okrs (okr_id, city_id, week_start, target_avg_delivery_mins, target_cancellation_rate, notes)
SELECT
    CONCAT('OKR_', c.city_id, '_', DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL w*7 DAY),'%Y%m%d')) AS okr_id,
    c.city_id,
    DATE_SUB(CURDATE(), INTERVAL w*7 DAY) AS week_start,
    CASE 
        WHEN c.market_tier='Tier-1' THEN 30 + FLOOR(RAND()*5)
        WHEN c.market_tier='Tier-2' THEN 33 + FLOOR(RAND()*5)
        ELSE 35 + FLOOR(RAND()*5)
    END AS target_avg_delivery_mins,
    ROUND(0.02 + RAND()*0.03,3) AS target_cancellation_rate,
    'Auto-generated OKR' AS notes
FROM cities c
CROSS JOIN (
    SELECT 0 AS w UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
) weeks;

-- Optional: Link actual performance metrics to OKRs (for analysis)
-- Example view: city weekly performance vs OKR

CREATE OR REPLACE VIEW city_weekly_performance AS
SELECT
    o.city_id,
    DATE_ADD(DATE_SUB(DATE(o.order_datetime), INTERVAL (DAYOFWEEK(o.order_datetime)-2) DAY), INTERVAL 0 DAY) AS week_start,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.order_status='cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN o.complaint_flag=TRUE THEN 1 ELSE 0 END) AS complaints,
    ROUND(AVG(o.actual_sla_mins),2) AS avg_delivery_mins,
    ROUND(SUM(o.order_value),2) AS total_revenue,
    ok.target_avg_delivery_mins,
    ok.target_cancellation_rate
FROM orders o
LEFT JOIN okrs ok  
    ON o.city_id = ok.city_id  
    AND DATE_ADD(DATE_SUB(DATE(o.order_datetime), INTERVAL (DAYOFWEEK(o.order_datetime)-2) DAY), INTERVAL 0 DAY) = ok.week_start
GROUP BY o.city_id,
         DATE_ADD(DATE_SUB(DATE(o.order_datetime), INTERVAL (DAYOFWEEK(o.order_datetime)-2) DAY), INTERVAL 0 DAY),
         ok.target_avg_delivery_mins,
         ok.target_cancellation_rate;

USE wolt_ops;

SELECT 'cities' AS table_name, COUNT(*) AS row_count FROM cities;
SELECT 'neighborhoods', COUNT(*) FROM neighborhoods;
SELECT 'couriers', COUNT(*) FROM couriers;
SELECT 'courier_onboard', COUNT(*) FROM courier_onboard;
SELECT 'courier_shifts', COUNT(*) FROM courier_shifts;
SELECT 'customers', COUNT(*) FROM customers;
SELECT 'restaurants', COUNT(*) FROM restaurants;
SELECT 'orders', COUNT(*) FROM orders;
SELECT 'order_seed', COUNT(*) FROM order_seed;
SELECT 'complaints', COUNT(*) FROM complaints;
SELECT 'okrs', COUNT(*) FROM okrs;

SELECT COUNT(*) FROM city_daily_summary;
SELECT COUNT(*) FROM customer_segments;
SELECT COUNT(*) FROM courier_performance;
SELECT COUNT(*) FROM top_restaurants;
SELECT COUNT(*) FROM city_weekly_performance;
