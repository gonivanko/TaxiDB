CREATE USER 'taxi_admin'@'localhost' IDENTIFIED BY 'admin228';
GRANT ALL PRIVILEGES ON taxiDB.* TO taxi_admin@localhost WITH GRANT OPTION;
SHOW GRANTS FOR taxi_admin@localhost;


CREATE USER 'taxi_driver'@'localhost' IDENTIFIED BY 'taxi228';

GRANT SELECT ON taxiDB.clients TO taxi_driver@localhost;
GRANT SELECT ON taxiDB.drivers TO taxi_driver@localhost;
GRANT SELECT ON taxiDB.employees TO taxi_driver@localhost;
GRANT SELECT ON taxiDB.feedbacks TO taxi_driver@localhost;
GRANT SELECT ON taxiDB.orders TO taxi_driver@localhost;
GRANT SELECT ON taxiDB.payments TO taxi_driver@localhost;
GRANT SELECT ON taxiDB.salaries TO taxi_driver@localhost;

GRANT INSERT ON taxiDB.time_reserved TO taxi_driver@localhost;
GRANT INSERT ON taxiDB.messages TO taxi_driver@localhost;

GRANT SELECT, INSERT ON taxiDB.vehicles TO taxi_driver@localhost;
SHOW GRANTS FOR taxi_driver@localhost;

CREATE USER 'taxi_client'@'localhost' IDENTIFIED BY 'taxi228';
SELECT user, host from mysql.user;

GRANT SELECT ON taxiDB.drivers TO taxi_client@localhost;
GRANT INSERT ON taxiDB.feedbacks TO taxi_client@localhost;
GRANT INSERT ON taxiDB.messages TO taxi_client@localhost;
GRANT INSERT ON taxiDB.orders TO taxi_client@localhost;
GRANT SELECT ON taxiDB.vehicles TO taxi_client@localhost;
SHOW GRANTS FOR taxi_client@localhost;