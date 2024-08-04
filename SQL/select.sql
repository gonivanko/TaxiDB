USE taxiDB;
-- 1
SELECT CONCAT(employees.name, " ", employees.surname) AS driver_name,
       vehicles.vehicle_number,
       vehicles.model,
       vehicles.production_year,
       vehicles.seats_number
FROM vehicles
JOIN drivers ON vehicles.driver_id = drivers.driver_id
JOIN employees ON drivers.driver_id = employees.employee_id
WHERE vehicles.seats_number > 5
  AND vehicles.model LIKE 'Audi%'
  AND vehicles.production_year >= 2019;

-- 2
SELECT 
	payment_id, 
    (starting_price - discount - driver_income) AS company_income,
    p.datetime
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE 
	is_paid = True AND city = "Boston"
ORDER BY company_income DESC;

-- 3
SELECT 
	(
		SELECT CONCAT(name, " ", surname) 
		FROM employees 
		WHERE employees.employee_id = salaries.employee_id
	) AS employee_full_name, 
	working_hours, 
	employee_salary
FROM salaries
WHERE 
	employee_salary > (SELECT AVG(employee_salary) FROM salaries)
ORDER BY employee_salary DESC;

-- 4
SELECT 
	(
		SELECT CONCAT(name, " ", surname)
        FROM employees WHERE employees.employee_id = time_reserved.employee_id
	) 	AS employee_full_name, 
	start, end, SEC_TO_TIME(end - start) AS duration
FROM time_reserved
WHERE SEC_TO_TIME(end - start) <= "08:00:00"
ORDER BY duration DESC;

-- 5
-- Обрати 10 клієнтів, які витратили найбільше
SELECT 
	c.client_id, 
	CONCAT(c.name, " ", c.surname) AS client_name, 
	c.email,
	SUM(starting_price - discount) AS total_spent
FROM payments p
JOIN orders o ON o.order_id = p.order_id
JOIN clients c ON c.client_id = o.client_id
GROUP BY c.client_id
ORDER BY total_spent DESC
LIMIT 10;

-- 6
-- Найпопулярніші моделі автомобілів
SELECT v.model, COUNT(v.model) AS trips_number
FROM orders o
LEFT JOIN vehicles v ON o.driver_id = v.driver_id
GROUP BY v.model
ORDER BY trips_number DESC;

-- 7 
-- Обрати найвищі оцінки водіїв 
SELECT o.driver_id, CONCAT(e.name, " ", e.surname) AS driver_name,
	driver_score, o.datetime
FROM feedbacks f
JOIN orders o ON o.order_id = f.order_id
JOIN drivers d ON o.driver_id = d.driver_id
JOIN employees e ON e.employee_id = d.employee_id
ORDER BY driver_score DESC;

-- 8
-- Обрати працівників таксі, які не є водіями
SELECT * FROM employees
WHERE employee_id 
NOT IN (SELECT employee_id FROM drivers);

-- 9
-- Обрати стартову точку та точку призначення замовлень
SELECT o.order_id, 
    ST_AsText(starting_location) AS starting_location, 
    ST_AsText(ending_location) AS ending_location
FROM orders o
LEFT JOIN clients c ON c.client_id = o.client_id
LEFT JOIN drivers d ON d.driver_id = o.driver_id
LEFT JOIN employees e ON e.employee_id = d.employee_id;

-- 10 
-- Обрати оцінки водіїв та їх заробіток із кожної поїздки
SELECT feedback_id, driver_score, driver_income
FROM feedbacks f
JOIN payments p ON p.order_id = f.order_id
ORDER BY driver_score DESC;

-- 11
-- Обрати дані про оплату та місто поїздки
SELECT payment_id, type, (starting_price - discount) AS price, driver_income, city
FROM payments
JOIN orders ON orders.order_id = payments.order_id
WHERE 
	starting_price >= (SELECT AVG(starting_price) FROM payments) * 2.5;

-- 12
-- Клієнти, які ніразу не їздили в таксі
SELECT * FROM clients
WHERE client_id NOT IN (SELECT client_id FROM orders);

-- 13
SELECT 
	city, 
	vehicle_number, model, type, production_year 
FROM clients
JOIN orders ON orders.client_id = clients.client_id
JOIN vehicles ON vehicles.driver_id = orders.driver_id
WHERE clients.client_id = 1234;

-- 14
SELECT * FROM feedbacks
JOIN orders ON feedbacks.order_id = orders.order_id
JOIN clients ON orders.client_id = clients.client_id
WHERE clients.client_id = 2345;

-- 15
-- Обрати водіїв з автомобілями, які отримали найбільше прибутку
SELECT 
	vehicles.driver_id, 
	SUM(driver_income) AS total_driver_income, 
    vehicle_number, model, production_year, vehicles.type 
FROM payments
JOIN orders ON orders.order_id = payments.order_id
JOIN vehicles ON vehicles.driver_id = orders.driver_id
GROUP BY vehicle_number
ORDER BY total_driver_income DESC
LIMIT 100;

-- 16
-- Вивести загальний заробіток водіїв та їхню зарплату
SELECT 
	orders.driver_id, 
    SUM(driver_income) AS driver_trips_income, 
    SUM(employee_salary) AS driver_salary
FROM payments
INNER JOIN orders ON orders.order_id = payments.order_id
INNER JOIN drivers ON drivers.driver_id = orders.driver_id
INNER JOIN salaries ON drivers.employee_id = salaries.employee_id
GROUP BY orders.driver_id
HAVING orders.driver_id <= 300;

-- 17
-- Вивести водіїв, у яких середній чек за поїздку менше 50
SELECT 
	drivers.driver_id, 
    AVG(starting_price - discount) AS average_taxi_income 
FROM payments
INNER JOIN orders ON orders.order_id = payments.order_id
INNER JOIN drivers ON drivers.driver_id = orders.driver_id
GROUP BY drivers.driver_id
HAVING average_taxi_income < 50
ORDER BY average_taxi_income ASC;

-- 18
SELECT messages.*
FROM messages
JOIN clients ON messages.client_id = clients.client_id
WHERE sender = "Employee";

-- 19
SELECT 
	message_id,
	CONCAT(c.name, " ", c.surname) AS client_name,
    CONCAT(e.name, " ", e.surname) AS driver_name,
	sender,
    text
FROM clients c
JOIN messages m ON m.client_id = c.client_id
JOIN employees e ON e.employee_id = m.employee_id
JOIN drivers d ON d.employee_id = m.employee_id;

-- 20
SELECT client_id, text 
FROM messages
WHERE sender = "Client"
UNION
SELECT orders.client_id, text
FROM feedbacks
JOIN orders ON feedbacks.order_id = orders.order_id
ORDER BY client_id;