-- Generate synthetic complaints for past 90 days
INSERT INTO complaints (complaint_id, city_id, courier_id, order_id, category, complaint_date)
SELECT 
    CONCAT('CMP_', o.order_id) AS complaint_id,
    o.city_id,
    o.courier_id,
    o.order_id,
    CASE 
        WHEN RAND() < 0.4 THEN 'Late Delivery'
        WHEN RAND() < 0.7 THEN 'Wrong Item'
        ELSE 'Rude Behavior'
    END AS category,
    DATE_SUB(o.delivered_at, INTERVAL FLOOR(RAND()*2) DAY) AS complaint_date
FROM orders o
WHERE RAND() < 0.01; -- ~1% of orders generate complaints
