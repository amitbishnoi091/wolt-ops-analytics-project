SELECT
cs.courier_id,
c.city_name,
SUM(cs.earnings_eur) AS total_earnings,
AVG(cs.completion_rate) AS avg_completion_rate,
COUNT(o.order_id) AS total_orders
FROM courier_shifts cs
JOIN cities c ON cs.city_id = c.city_id
LEFT JOIN orders o ON cs.courier_id = o.courier_id
GROUP BY cs.courier_id, c.city_name
ORDER BY total_earnings DESC
LIMIT 50;