SELECT 
    o.city_id,
    c.city_name,
    o.address AS area,
    COUNT(*) AS total_orders,
    AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) AS avg_delivery_mins,
    COUNT(CASE WHEN o.cancelled = TRUE THEN 1 END) AS total_cancellations
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY o.city_id, o.address
ORDER BY total_cancellations DESC, avg_delivery_mins DESC
LIMIT 50;