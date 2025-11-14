SELECT 
    c.city_name,
    HOUR(o.created_at) AS hour,
    COUNT(*) AS total_orders
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name, hour
ORDER BY c.city_name, total_orders DESC;