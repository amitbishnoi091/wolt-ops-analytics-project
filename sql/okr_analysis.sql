
SELECT
c.city_name,
YEARWEEK(o.created_at, 1) AS week,
AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) AS avg_delivery_mins,
MAX(k.target_avg_delivery_mins) AS target_delivery_mins,
AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) - MAX(k.target_avg_delivery_mins) AS variance
FROM orders o
JOIN cities c ON o.city_id = c.city_id
JOIN okrs k ON o.city_id = k.city_id
GROUP BY c.city_name, YEARWEEK(o.created_at, 1)
ORDER BY c.city_name, week;