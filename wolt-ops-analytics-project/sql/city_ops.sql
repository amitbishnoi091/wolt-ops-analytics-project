SELECT
    c.city_id,
    c.city_name,
    c.market_tier,
    DATE(o.order_datetime) AS order_date,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status='delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN o.order_status='cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN o.order_status='failed' THEN 1 ELSE 0 END) AS failed_orders,
    SUM(CASE WHEN o.order_status='returned' THEN 1 ELSE 0 END) AS returned_orders,
    SUM(CASE WHEN o.complaint_flag=TRUE THEN 1 ELSE 0 END) AS complaints,
    ROUND(AVG(COALESCE(o.actual_sla_mins, c.sla_target_mins)),2) AS avg_delivery_mins,
    ROUND(AVG(COALESCE(o.estimated_sla_mins, c.sla_target_mins)),2) AS avg_estimated_sla_mins,
    ROUND(SUM(COALESCE(o.order_value,0)),2) AS total_revenue,
    ROUND(AVG(COALESCE(o.order_value,0)),2) AS avg_order_value,
    ROUND(SUM(CASE WHEN o.order_status='cancelled' THEN 1 ELSE 0 END)/NULLIF(COUNT(o.order_id),0),3) AS cancellation_rate,
    ROUND(SUM(CASE WHEN o.complaint_flag=TRUE THEN 1 ELSE 0 END)/NULLIF(COUNT(o.order_id),0),3) AS complaint_rate
FROM cities c
LEFT JOIN orders o ON c.city_id = o.city_id
GROUP BY c.city_id, c.city_name, c.market_tier, DATE(o.order_datetime)
ORDER BY c.city_id, order_date;
