SELECT 
    cs.courier_id,
    AVG(cs.online_hours) AS avg_online_hours,
    COUNT(o.order_id) AS total_orders_assigned,
    AVG(cs.online_hours)/COUNT(o.order_id) AS hours_per_order
FROM courier_shifts cs
LEFT JOIN orders o ON cs.courier_id = o.courier_id
GROUP BY cs.courier_id
ORDER BY hours_per_order ASC
LIMIT 50;