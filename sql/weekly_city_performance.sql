SELECT
c.city_name,
YEARWEEK(o.created_at, 1) AS week,
AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) AS avg_delivery_mins,
COUNT(CASE WHEN o.cancelled = TRUE THEN 1 END)/COUNT(*) AS cancellation_rate,
COUNT(DISTINCT o.courier_id) AS active_couriers
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name, week
ORDER BY c.city_name, week;