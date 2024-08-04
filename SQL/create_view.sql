USE taxiDB;

CREATE VIEW clients_messages_sent AS 
SELECT 
	messages.client_id, 
    CONCAT(clients.name, " ", clients.surname) AS client_name, 
    COUNT(messages.client_id) AS messages_sent
FROM messages
JOIN clients ON messages.client_id = clients.client_id
GROUP BY messages.client_id;

CREATE VIEW feedbacks_order_prices AS 
SELECT feedback_id, driver_score, starting_price, discount  
FROM feedbacks f
JOIN payments p ON p.order_id = f.order_id
ORDER BY driver_score DESC;

CREATE VIEW cars_in_cities AS 
SELECT 
	city, model, COUNT(model) FROM clients
JOIN orders ON orders.client_id = clients.client_id
JOIN vehicles ON vehicles.driver_id = orders.driver_id
GROUP BY city, model
ORDER BY city;

SELECT * FROM clients_messages_sent;
SELECT * FROM feedbacks_order_prices;
SELECT * FROM cars_in_cities;