SELECT 
    c.city_name,
    YEARWEEK(o.created_at,1) AS week,
    SUM(o.order_value) AS total_revenue,
    AVG(o.order_value) AS avg_order_value
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name, week
ORDER BY total_revenue DESC;