SELECT
    c.courier_id,
    c.city_id,
    ci.city_name,
    c.vehicle_type,
    c.status,
    COUNT(o.order_id) AS orders_handled,
    ROUND(AVG(COALESCE(o.actual_sla_mins,0)),2) AS avg_delivery_time,
    ROUND(AVG(COALESCE(o.estimated_sla_mins,0)),2) AS avg_estimated_sla,
    ROUND(AVG(COALESCE(s.earnings_eur,0)),2) AS avg_shift_earnings,
    ROUND(SUM(COALESCE(s.earnings_eur,0)),2) AS total_earnings,
    ROUND(AVG(COALESCE(o.rating_given,0)),2) AS avg_rating_given,
    ROUND(AVG(COALESCE(s.acceptance_rate,0)),3) AS avg_acceptance_rate,
    ROUND(AVG(COALESCE(s.completion_rate,0)),3) AS avg_completion_rate
FROM couriers c
LEFT JOIN orders o ON c.courier_id = o.courier_id
LEFT JOIN courier_shifts s ON c.courier_id = s.courier_id
LEFT JOIN cities ci ON c.city_id = ci.city_id
GROUP BY c.courier_id, c.city_id, ci.city_name, c.vehicle_type, c.status
ORDER BY orders_handled DESC;
