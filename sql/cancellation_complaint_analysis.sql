SELECT
c.city_name,
COUNT(CASE WHEN o.cancelled = TRUE THEN 1 END)/COUNT(*) AS cancellation_rate,
COUNT(CASE WHEN o.complaint_flag = TRUE THEN 1 END)/COUNT(*) AS complaint_rate
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name
ORDER BY cancellation_rate DESC;