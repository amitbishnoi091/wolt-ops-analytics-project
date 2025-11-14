SELECT
cs.courier_id,
COUNT(o.order_id)/COUNT(DISTINCT cs.shift_id) AS orders_per_shift,
AVG(cs.online_hours) AS avg_online_hours,
AVG(cs.acceptance_rate) AS avg_acceptance,
AVG(cs.completion_rate) AS avg_completion,
AVG(cs.earnings_eur) AS avg_earnings
FROM courier_shifts cs
LEFT JOIN orders o ON cs.courier_id = o.courier_id
GROUP BY cs.courier_id
ORDER BY avg_earnings DESC
LIMIT 20;