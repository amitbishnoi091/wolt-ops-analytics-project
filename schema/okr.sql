INSERT INTO okrs(okr_id, city_id, week_start, target_avg_delivery_mins, target_cancellation_rate, notes)
SELECT 
  CONCAT('OKR_', city_id, '_', wk) AS okr_id,
  city_id,
  CURDATE() - INTERVAL (wk*7) DAY AS week_start,
  CASE WHEN city_id IN (1,2,3) THEN 30 ELSE 33 END AS target_avg_delivery_mins,
  0.025 AS target_cancellation_rate,
  'Auto-generated OKR'
FROM (SELECT city_id FROM cities) c
CROSS JOIN (SELECT 0 wk UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
            UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 
            UNION SELECT 10 UNION SELECT 11) weeks;
