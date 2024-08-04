USE taxiDB;

-- 1
DELIMITER $$
CREATE PROCEDURE get_car_by_properties_table(
	IN car_city VARCHAR(25), car_type enum('Standart','Comfort','Electric'), min_seats INT, min_year INT
)
BEGIN
DROP TABLE IF EXISTS car_by_properties_table;
CREATE TEMPORARY TABLE IF NOT EXISTS car_by_properties_table AS
	SELECT CONCAT(employees.name, " ", employees.surname) AS driver_name,
       vehicles.vehicle_number,
       vehicles.model,
       vehicles.production_year,
       vehicles.seats_number
	FROM vehicles
	JOIN drivers ON vehicles.driver_id = drivers.driver_id
	JOIN employees ON drivers.driver_id = employees.employee_id
	WHERE 
		city = car_city
		AND vehicles.seats_number >= min_seats
		AND type = car_type
		AND vehicles.production_year >= min_year;

END $$
DELIMITER ;

CALL get_car_by_properties_table("Boston", "Standart", 2, 2002);
SELECT * FROM car_by_properties_table;

-- 2
DELIMITER $$
CREATE PROCEDURE get_top_drivers_by_revenue(
	IN n INT)
BEGIN
SELECT 
	orders.driver_id, 
	SUM(starting_price - discount) AS revenue
FROM payments
JOIN orders ON orders.order_id = payments.order_id
GROUP BY orders.driver_id
ORDER BY revenue DESC
LIMIT n;
END $$
DELIMITER ;

CALL get_top_drivers_by_revenue(1000);


-- 3
DELIMITER $$
CREATE PROCEDURE update_average_rating(
	IN driverID INT
)
BEGIN
    UPDATE drivers
	SET average_rating = 
	(
		SELECT AVG(driver_score) FROM feedbacks
		JOIN orders ON orders.order_id = feedbacks.order_id
		WHERE driver_id = driverID
	)
	WHERE driver_id = driverID;
END $$
DELIMITER ;

CALL update_average_rating(5);

-- 4
DELIMITER $$
CREATE PROCEDURE update_all_average_ratings()
BEGIN
	DECLARE drivers_number INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    SELECT COUNT(driver_id)
    INTO drivers_number
    FROM drivers;
    
    WHILE i <= drivers_number DO
		CALL update_average_rating(i);
		SET i = i + 1;
    END WHILE;
    
END $$
DELIMITER ;

CALL update_all_average_ratings();

-- 5
DELIMITER $$
CREATE PROCEDURE get_highest_ranked_drivers()
BEGIN
SELECT driver_id, name, surname, email, average_rating 
FROM drivers
JOIN employees ON drivers.employee_id = employees.employee_id
WHERE average_rating = (SELECT MAX(average_rating) FROM drivers)
ORDER BY average_rating DESC;
END $$
DELIMITER ;

CALL get_highest_ranked_drivers();

-- 6
DELIMITER $$
CREATE PROCEDURE get_client_contact_info(
	IN id INT, IN contact_type ENUM("email", "phone_number")
)
BEGIN
	IF (contact_type = "email") THEN
		SELECT email FROM clients WHERE client_id = id;
	ELSE
		SELECT phone_number FROM clients WHERE client_id = id;
	END IF;
END $$

DELIMITER ;

CALL get_client_contact_info(3, "email");

-- 7
DELIMITER $$
CREATE PROCEDURE get_used_cars_by_client(
	IN id INT
)
BEGIN
	SELECT 
		city, 
		vehicle_number, model, type, production_year 
	FROM clients
	JOIN orders ON orders.client_id = clients.client_id
	JOIN vehicles ON vehicles.driver_id = orders.driver_id
	WHERE clients.client_id = id;
END $$
DELIMITER ;

CALL get_used_cars_by_client(228);

-- 8
-- DROP FUNCTION get_driver_salary;
DELIMITER $$
CREATE FUNCTION get_driver_salary(
	driverID INT
)
RETURNS DECIMAL(8, 2)
DETERMINISTIC
BEGIN
	DECLARE salary DECIMAL(8, 2);
    SELECT SUM(employee_salary) 
    INTO salary
    FROM salaries
    JOIN drivers ON drivers.employee_id = salaries.employee_id
    WHERE drivers.driver_id = driverID;
    RETURN salary;
END $$
DELIMITER ;

SELECT (get_driver_salary(1234));

-- 9
DELIMITER $$
CREATE FUNCTION salary_received_status(
	employeeID INT
)
RETURNS ENUM("Received", "Not received")
DETERMINISTIC
BEGIN
	DECLARE salaries_number INT;
	SELECT COUNT(date) 
    INTO salaries_number
    FROM salaries
    WHERE employee_id = employeeID;
    IF salaries_number = 0 THEN
		RETURN "Not received";
	ELSE 
		RETURN "Received";
	END IF;
END $$

DELIMITER ;

SELECT 
	employee_id, 
    CONCAT(name, " ", surname) AS employee_name, 
    salary_received_status(employee_id) AS salary_received_status
FROM employees;

-- 10
DROP PROCEDURE IF EXISTS get_drivers_feedback;
DELIMITER $$
CREATE PROCEDURE get_drivers_feedbacks (ID INT)

BEGIN
	SELECT * FROM feedbacks
    WHERE order_id IN (SELECT order_id FROM orders WHERE orders.driver_id = ID);
END $$

DELIMITER ;

CALL get_drivers_feedbacks(3456);

-- 11
DELIMITER $$
CREATE PROCEDURE get_top_drivers_by_trips_number()
BEGIN
SELECT vehicles.driver_id, vehicle_number, COUNT(vehicle_number) AS trips_number FROM vehicles
JOIN orders ON vehicles.driver_id = orders.driver_id
GROUP BY vehicles.driver_id, vehicle_number
ORDER BY trips_number DESC;
END $$
DELIMITER ;

CALL get_top_drivers_by_trips_number();

-- 13
DELIMITER $$
CREATE PROCEDURE get_employee_info (IN first_name VARCHAR(50), IN last_name VARCHAR(50))

BEGIN
	SELECT * FROM employees
	WHERE name = first_name AND surname = last_name;
END $$


CALL get_employee_info("Rebecca", "Henry");

DROP PROCEDURE fix_drivers_cities;
DELIMITER $$
CREATE PROCEDURE fix_drivers_cities()
BEGIN
	DECLARE drivers_number INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    SELECT COUNT(driver_id)
    INTO drivers_number
    FROM drivers;
    
    WHILE i <= drivers_number DO
		IF (SELECT COUNT(city) FROM orders WHERE driver_id = i) > 0 THEN
			UPDATE drivers
			SET city = (SELECT city FROM orders WHERE driver_id = i LIMIT 1)
			WHERE driver_id = i;
		END IF;
		SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;

CALL fix_drivers_cities();

