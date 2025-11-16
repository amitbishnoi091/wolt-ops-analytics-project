SELECT
    c.segment,
    c.city_id,
    ci.city_name,
    COUNT(*) AS customer_count,
    ROUND(AVG(COALESCE(c.lifetime_orders,0)),2) AS avg_orders,
    ROUND(AVG(COALESCE(c.avg_order_value,0)),2) AS avg_order_value,
    ROUND(AVG(COALESCE(c.cancellation_rate,0)),3) AS avg_cancellation_rate,
    ROUND(AVG(COALESCE(c.complaint_rate,0)),3) AS avg_complaint_rate,
    ROUND(SUM(COALESCE(c.lifetime_orders,0)),0) AS total_orders,
    ROUND(SUM(COALESCE(c.avg_order_value,0)*COALESCE(c.lifetime_orders,0)),2) AS total_value
FROM customers c
LEFT JOIN cities ci ON c.city_id = ci.city_id
GROUP BY c.segment, c.city_id, ci.city_name
ORDER BY total_value DESC;
