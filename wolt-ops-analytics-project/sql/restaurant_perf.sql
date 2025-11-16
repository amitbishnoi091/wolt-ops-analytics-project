SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city_id,
    ci.city_name,
    r.cuisine_type,
    IF(r.is_verified=TRUE,'Yes','No') AS is_verified,
    COUNT(o.order_id) AS orders_count,
    ROUND(SUM(COALESCE(o.order_value,0)),2) AS total_revenue,
    ROUND(AVG(COALESCE(o.rating_given,3)),2) AS avg_rating,
    ROUND(AVG(COALESCE(r.avg_prep_time,20)),2) AS avg_prep_time,
    ROUND(AVG(COALESCE(r.delivery_fee,2)),2) AS avg_delivery_fee,
    SUM(COALESCE(r.popularity_score,0)) AS popularity_score
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
LEFT JOIN cities ci ON r.city_id = ci.city_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city_id, ci.city_name, r.cuisine_type, r.is_verified
ORDER BY total_revenue DESC
LIMIT 100;
