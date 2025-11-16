SELECT
    co.complaint_id,
    co.order_id,
    COALESCE(o.customer_id,'Unknown') AS customer_id,
    COALESCE(o.restaurant_id,'Unknown') AS restaurant_id,
    o.city_id,
    ci.city_name,
    COALESCE(o.courier_id,'Unknown') AS courier_id,
    CONCAT('Courier_', COALESCE(o.courier_id,'Unknown')) AS courier_name,
    co.category AS complaint_category,
    COALESCE(co.notes,'No Notes') AS notes,
    COALESCE(o.order_status,'Unknown') AS order_status,
    COALESCE(o.reason_cancel,'None') AS reason_cancel,
    COALESCE(o.actual_sla_mins,0) AS actual_sla_mins,
    COALESCE(o.order_value,0) AS order_value,
    IF(o.complaint_flag=TRUE,1,0) AS complaint_flag,
    IF(o.order_status='cancelled',1,0) AS is_cancelled
FROM complaints co
LEFT JOIN orders o ON co.order_id = o.order_id
LEFT JOIN cities ci ON o.city_id = ci.city_id;
