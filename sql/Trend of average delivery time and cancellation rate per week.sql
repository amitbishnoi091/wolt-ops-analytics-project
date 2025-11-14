SELECT 
    YEARWEEK(o.created_at,1) AS week,
    AVG(TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at)) AS avg_delivery_mins,
    COUNT(CASE WHEN o.cancelled = TRUE THEN 1 END)/COUNT(*) AS cancellation_rate
FROM orders o
GROUP BY week
ORDER BY week;