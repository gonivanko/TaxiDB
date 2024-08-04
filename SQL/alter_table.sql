USE taxiDB;

ALTER TABLE vehicles
MODIFY COLUMN vehicle_number VARCHAR(10);

SELECT * FROM salaries;

ALTER TABLE salaries
ADD COLUMN date DATE;

ALTER TABLE payments
MODIFY datetime DATETIME;

ALTER TABLE payments
MODIFY starting_price DECIMAL(7, 2);

ALTER TABLE payments
MODIFY driver_income DECIMAL(7, 2);