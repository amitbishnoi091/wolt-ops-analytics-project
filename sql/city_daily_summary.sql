SELECT
c.city_name,
DATE(o.created_at) AS day,
COUNT(*) AS total_orders,
AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) AS avg_delivery_mins,
SUM(o.order_value) AS total_revenue,
COUNT(DISTINCT o.courier_id) AS active_couriers,
COUNT(CASE WHEN o.cancelled = TRUE THEN 1 END)/COUNT(*) AS cancellation_rate
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name, day
ORDER BY day, c.city_name;