DELIMITER $$

DROP PROCEDURE IF EXISTS generate_shifts $$
CREATE PROCEDURE generate_shifts()
BEGIN
    DECLARE i INT;
    DECLARE j INT;
    DECLARE k INT;
    DECLARE courier VARCHAR(20);

    SET i = 1;
    WHILE i <= 12 DO
        SET j = 1;
        WHILE j <= 200 DO
            SET courier = CONCAT('C_', i, '_', j);
            SET k = 1;
            WHILE k <= 20 DO
                INSERT INTO courier_shifts(
                    shift_id, courier_id, city_id, date, online_hours, acceptance_rate, completion_rate, earnings_eur
                )
                VALUES(
                    CONCAT('S_', courier, '_', k),
                    courier,
                    i,
                    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*90) DAY),
                    ROUND(2 + RAND()*6, 2),
                    ROUND(0.6 + RAND()*0.35, 2),
                    ROUND(0.7 + RAND()*0.25, 2),
                    ROUND(20 + RAND()*80, 2)
                );
                SET k = k + 1;
            END WHILE;
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;
END $$

DELIMITER ;

CALL generate_shifts();
