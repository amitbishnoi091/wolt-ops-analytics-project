SELECT 
    c.city_name,
    SUM(CASE WHEN TIMESTAMPDIFF(MINUTE, o.picked_at, o.delivered_at) <= c.sla_target_mins THEN 1 ELSE 0 END)/COUNT(*) AS sla_compliance_rate
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name
ORDER BY sla_compliance_rate ASC;