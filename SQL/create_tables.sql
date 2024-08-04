CREATE DATABASE IF NOT EXISTS taxiDB;
USE taxiDB;

CREATE TABLE IF NOT EXISTS clients
(
	client_id INT PRIMARY KEY AUTO_INCREMENT,
    surname VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    phone_number BIGINT UNSIGNED,
    email VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS employees
(
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    surname VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    phone_number BIGINT UNSIGNED,
    email VARCHAR(50),
    card_number BIGINT UNSIGNED
);

CREATE TABLE IF NOT EXISTS drivers
(
	driver_id INT PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(25) NOT NULL,
    current_location POINT,
    can_take_order BOOLEAN NOT NULL,
    average_rating FLOAT,
    employee_id INT NOT NULL UNIQUE,
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);

CREATE TABLE IF NOT EXISTS vehicles
(
	vehicle_number VARCHAR(8) PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    production_year YEAR NOT NULL,
    type ENUM("Standart", "Comfort", "Electric") NOT NULL, -- типи авто
    seats_number TINYINT UNSIGNED NOT NULL,
    driver_id INT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers (driver_id)
);

CREATE TABLE IF NOT EXISTS salaries
(
	salary_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    working_hours SMALLINT UNSIGNED NOT NULL,
    waiting_hours SMALLINT UNSIGNED DEFAULT 0,
    total_amount DECIMAL(8, 2),
    employee_salary DECIMAL(8, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS time_reserved
(
	reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    start DATETIME NOT NULL,
    end DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS messages
(
	message_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients (client_id),
    employee_id INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    sender ENUM("Employee", "Client") NOT NULL,
    text VARCHAR(500) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders
(
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients (client_id),
    driver_id INT,
    FOREIGN KEY (driver_id) REFERENCES drivers (driver_id),
    datetime DATETIME NOT NULL,
    city VARCHAR(25) NOT NULL,
	starting_location POINT NOT NULL,
    ending_location POINT NOT NULL
);

CREATE TABLE IF NOT EXISTS payments
(
	payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    FOREIGN KEY (order_id) REFERENCES orders (order_id),
    datetime DATETIME NOT NULL,
    type ENUM("Card", "Cash") NOT NULL,
    is_paid BOOL DEFAULT FALSE,
	starting_price DECIMAL(7, 2) NOT NULL,
    discount DECIMAL(7,2) DEFAULT 0,
    driver_income DECIMAL(7,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS feedbacks
(
	feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    driver_score TINYINT UNSIGNED NOT NULL
    CHECK (driver_score >= 1 AND driver_score <= 5), -- від 1 до 5-- 
    text VARCHAR(500)
);