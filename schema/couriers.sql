-- Insert 200 couriers per city (12 cities)
DELIMITER $$

DROP PROCEDURE IF EXISTS generate_couriers $$
CREATE PROCEDURE generate_couriers()
BEGIN
  DECLARE i INT;
  DECLARE j INT;
  SET i = 1;
  
  WHILE i <= 12 DO -- cities
    SET j = 1;
    WHILE j <= 200 DO
      INSERT INTO couriers(courier_id, city_id, onboard_date, status, rating)
      VALUES(
        CONCAT('C_', i, '_', j),
        i,
        DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY),
        IF(RAND() < 0.9, 'active', 'inactive'),
        ROUND(3 + RAND()*2, 2)
      );
      SET j = j + 1;
    END WHILE;
    SET i = i + 1;
  END WHILE;
END $$

DELIMITER ;

CALL generate_couriers();
