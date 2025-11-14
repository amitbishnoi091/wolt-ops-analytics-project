SELECT
c.city_name,
DATE(o.created_at) AS day,
AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) AS avg_delivery_time,
COUNT(DISTINCT o.courier_id) AS active_couriers
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name, day
HAVING avg_delivery_time > 35 OR active_couriers < 50
ORDER BY day, c.city_name;