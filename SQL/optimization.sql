USE taxiDB;

CREATE INDEX name_surname_idx
ON clients (name, surname);

CREATE INDEX name_surname_idx
ON employees (name, surname);

CREATE INDEX model_year_idx
ON vehicles (model, production_year);

CREATE INDEX type_seats_number_idx
ON vehicles (type, seats_number);

CREATE INDEX city_idx
ON drivers (city);


-- ALTER TABLE vehicles
-- DROP INDEX model_year_idx;

-- ALTER TABLE vehicles
-- DROP INDEX type_seats_number_idx;

-- ALTER TABLE drivers
-- DROP INDEX city_idx;