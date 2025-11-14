SELECT
c.city_name,
YEARWEEK(co.activated_at, 1) AS week,
COUNT(*) AS new_couriers
FROM courier_onboard co
JOIN cities c ON co.city_id = c.city_id
GROUP BY c.city_name, week
ORDER BY c.city_name, week;