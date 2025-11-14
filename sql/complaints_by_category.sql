SELECT
c.city_name,
comp.category,
COUNT(*) AS total_complaints
FROM complaints comp
JOIN cities c ON comp.city_id = c.city_id
GROUP BY c.city_name, comp.category
ORDER BY total_complaints DESC;