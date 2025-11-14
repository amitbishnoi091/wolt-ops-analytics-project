-- Insert orders
DELIMITER $$

DROP PROCEDURE IF EXISTS generate_orders $$
CREATE PROCEDURE generate_orders()
BEGIN
  DECLARE d INT;
  DECLARE c INT;
  DECLARE o INT;
  DECLARE order_date DATE;
  SET d = 0;

  WHILE d < 90 DO -- 90 days
    SET order_date = DATE_SUB(CURDATE(), INTERVAL d DAY);
    SET c = 1;
    WHILE c <= 12 DO -- cities
      SET o = 1;
      WHILE o <= 40 DO -- 40 orders per city per day
        INSERT INTO orders(
          order_id, created_at, picked_at, delivered_at,
          city_id, courier_id, distance_km, order_value, cancelled, complaint_flag
        )
        VALUES(
          CONCAT('ORD_', c, '_', d, '_', o),
          order_date + INTERVAL FLOOR(RAND()*24) HOUR,
          order_date + INTERVAL FLOOR(RAND()*24) HOUR + INTERVAL (5 + FLOOR(RAND()*10)) MINUTE,
          order_date + INTERVAL FLOOR(RAND()*24) HOUR + INTERVAL (30 + FLOOR(RAND()*40)) MINUTE,
          c,
          (SELECT courier_id FROM couriers WHERE city_id = c ORDER BY RAND() LIMIT 1),
          ROUND(0.5 + RAND()*8, 2),
          ROUND(5 + RAND()*25, 2),
          IF(RAND() < 0.03, TRUE, FALSE),
          IF(RAND() < 0.012, TRUE, FALSE)
        );
        SET o = o + 1;
      END WHILE;
      SET c = c + 1;
    END WHILE;
    SET d = d + 1;
  END WHILE;
END $$

DELIMITER ;

CALL generate_orders();
