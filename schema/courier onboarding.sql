-- Generate synthetic courier onboarding data
INSERT INTO courier_onboard (activated_at, courier_id, city_id)
SELECT 
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*90) DAY),
    courier_id,
    city_id
FROM couriers
WHERE status = 'active';
