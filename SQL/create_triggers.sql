USE taxiDB;

-- 1
DELIMITER $$
CREATE TRIGGER after_driver_score_insert
AFTER INSERT ON feedbacks
FOR EACH ROW
BEGIN
	DECLARE ID INT;
	SELECT driver_id INTO ID FROM orders WHERE order_id = NEW.order_id;
	CALL update_average_rating(ID);
END $$
DELIMITER ;

-- 2
CREATE TRIGGER after_order_city_insert
AFTER INSERT ON orders
FOR EACH ROW
UPDATE drivers
SET drivers.city = NEW.city
WHERE drivers.driver_id = NEW.driver_id;

DESC payments;

-- 3
DELIMITER $$
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
	INSERT INTO payments (order_id)
    VALUES (NEW.order_id);
END $$
DELIMITER ;

-- 4
DROP TRIGGER after_payment_update
DELIMITER $$
CREATE TRIGGER after_payment_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
	DECLARE orders_number INT;
    SELECT COUNT(order_id)
    INTO orders_number
    FROM orders
    WHERE client_id IN (SELECT client_id FROM orders WHERE order_id = NEW.order_id); 
    IF orders_number = 1 THEN
		UPDATE payments
        SET discount = starting_price * 0.5
        WHERE payment_id = NEW.payment_id;
	END IF;
END $$
DELIMITER ;

-- 5
DELIMITER $$
DROP TRIGGER before_payment_datetime_update;
CREATE TRIGGER before_payment_datetime_update
BEFORE UPDATE ON payments
FOR EACH ROW
BEGIN
	IF NEW.datetime IS NOT NULL THEN
    SET NEW.is_paid = TRUE;
    END IF;
END $$
DELIMITER ;

UPDATE payments
SET datetime = NOW()
WHERE payment_id = 3032;

INSERT INTO orders (client_id, driver_id, datetime, city, starting_location, ending_location)
VALUES (3, 3, NOW(), "Kyiv", ST_GeomFromText("POINT(50.4471 30.4566)"), ST_GeomFromText("POINT(50.4659 30.5150)"));
SELECT * FROM payments WHERE order_id IN
(SELECT order_id FROM orders WHERE city = "Kyiv" AND client_id = 2);
