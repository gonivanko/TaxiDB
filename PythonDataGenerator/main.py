import random
from decimal import Decimal

import mysql.connector
from faker import Faker
from faker_vehicle import VehicleProvider

db = mysql.connector.connect(
    host="localhost",
    user="taxi_admin",
    password="admin228",
    database="taxiDB"
)

cursor = db.cursor()

fake = Faker("en_US")
fake.add_provider(VehicleProvider)


def get_location_string(x, y):
    location = f'ST_GeomFromText("POINT({x} {y})")'
    return location


def get_used_ids(id_name, table_name):
    cursor.execute(f"SELECT {id_name} FROM {table_name}")
    used_id = cursor.fetchall()
    for i in range(0, len(used_id)):
        used_id[i] = int(used_id[i][0])
    return used_id


def get_not_used_ids(id_name, table_name):
    used_ids = get_used_ids(id_name, table_name)
    cursor.execute(f"SELECT MAX({id_name}) FROM {table_name}")
    max_id = int(cursor.fetchone()[0])
    all_ids = list(range(1, max_id + 1))
    not_used_ids = [item for item in all_ids if item not in used_ids]
    return max_id, not_used_ids


def get_not_drivers_ids():
    cursor.execute("SELECT employee_id FROM employees WHERE employee_id NOT IN (SELECT employee_id FROM drivers);")
    employee_not_driver_id = cursor.fetchall()
    for i in range(0, len(employee_not_driver_id)):
        employee_not_driver_id[i] = int(employee_not_driver_id[i][0])
    return employee_not_driver_id


def get_array_from_select(query):
    cursor.execute(query)
    array = cursor.fetchall()
    for i in range(0, len(array)):
        array[i] = int(array[i][0])
    return array

def get_rows_number(column_name, table_name):
    cursor.execute(f"SELECT COUNT({column_name}) FROM {table_name}")
    rows_number = int(cursor.fetchone()[0])
    return rows_number


def random_phone_number():
    phone_number = 3800

    for i in range(9):
        phone_number += random.randint(0, 9)
        phone_number *= 10

    phone_number = int(phone_number / 10)
    return phone_number


def generate_random_clients(rows_number):
    for i in range(rows_number):
        sql_query = f'INSERT INTO clients (surname, name, phone_number, email) VALUES ("{fake.last_name()}", "{fake.first_name()}", {random_phone_number()}, "{fake.ascii_free_email()}")'
        # print(sql_query)
        cursor.execute(sql_query)

    db.commit()

    print(f"{rows_number} rows have been exported successfully to clients table")


def generate_random_employees(rows_number):
    for i in range(rows_number):
        sql_query = f'INSERT INTO employees (surname, name, phone_number, email, card_number) VALUES ("{fake.last_name()}", "{fake.first_name()}", {random_phone_number()}, "{fake.ascii_free_email()}", {fake.credit_card_number()})'
        # print(sql_query)
        cursor.execute(sql_query)

    db.commit()

    print(f"{rows_number} rows have been exported successfully to employees table")


def generate_random_drivers(rows_number):
    cursor.execute("SELECT COUNT(employee_id) FROM employees")
    n = int(cursor.fetchone()[0])

    used_id = get_used_ids("employee_id", "drivers")
    # indexes = list(range(444, 589))
    # used_driver_ids = get_used_ids("driver_id", "drivers")
    # cursor.execute("SELECT MAX(driver_id) FROM drivers")
    # max_id = int(cursor.fetchone()[0])
    # all_ids = list(range(1, max_id + 1))
    # not_used_ids = [item for item in all_ids if item not in used_driver_ids]
    # print(used_id)
    # print(not_used_ids)
    # print(len(not_used_ids))
    # for i in not_used_ids:
    for i in range(rows_number):
        random_location = fake.local_latlng()
        random_id = random.choice([e for e in range(n) if e not in used_id])
        used_id.append(random_id)
        # print(random_id)

        sql_query = f'INSERT INTO drivers (city, current_location, can_take_order, employee_id) VALUES ("{random_location[2]}", ST_GeomFromText("POINT({float(random_location[0])} {float(random_location[1])})"), {bool(random.getrandbits(1))}, {random_id})'
        # sql_query = f'INSERT INTO drivers (driver_id, city, current_location, can_take_order, employee_id) VALUES ({i}, "{random_location[2]}", ST_GeomFromText("POINT({float(random_location[0])} {float(random_location[1])})"), {bool(random.getrandbits(1))}, {random_id})'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to drivers table")


def generate_random_vehicles(rows_number):
    vehicle_types = ["Standart", "Comfort", "Electric"]
    cursor.execute("SELECT COUNT(driver_id) FROM drivers")
    n = int(cursor.fetchone()[0])
    used_id = get_used_ids("driver_id", "vehicles")
    # print(used_id)
    for i in range(n - 1):
        random_id = random.choice([e for e in range(n) if e not in used_id])
        used_id.append(random_id)
        sql_query = f'INSERT INTO vehicles (vehicle_number, model, production_year, type, seats_number, driver_id) VALUES ("{fake.license_plate()}", "{fake.vehicle_make_model()}", {fake.vehicle_year()}, "{random.choice(vehicle_types)}", {random.randint(4, 7)}, {random_id})'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to employees table")


def generate_random_orders(rows_number):
    cursor.execute("SELECT COUNT(driver_id) FROM drivers")
    drivers_number = int(cursor.fetchone()[0])
    cursor.execute("SELECT COUNT(client_id) FROM clients")
    clients_number = int(cursor.fetchone()[0])

    max_id, not_used_ids = get_not_used_ids("order_id", "orders")
    length = len(not_used_ids)

    if not_used_ids and length > rows_number:
        this_range = not_used_ids[0:rows_number]
    elif not_used_ids and length <= rows_number:
        this_range = not_used_ids.extend(range(max_id, max_id + rows_number - length))
    else:
        this_range = range(rows_number)

    for i in this_range:
        random_driver_id = random.randint(1, drivers_number)
        random_client_id = random.randint(1, clients_number)
        random_datetime = fake.date_time_this_year()

        cursor.execute(f"SELECT city FROM drivers WHERE driver_id = {random_driver_id}")
        city = str(cursor.fetchone()[0])

        cursor.execute(
            f"SELECT ST_X(current_location), ST_Y(current_location) FROM drivers WHERE driver_id = {random_driver_id}")
        start = cursor.fetchone()
        start_x = float(start[0])
        start_y = float(start[1])
        starting_location = get_location_string(start_x, start_y)

        end_x = fake.coordinate(start_x, 0.7)
        end_y = fake.coordinate(start_y, 0.7)
        random_ending_location = get_location_string(end_x, end_y)
        if not_used_ids:
            sql_query = f'INSERT INTO orders VALUES ({i}, {random_client_id}, {random_driver_id}, "{random_datetime}", "{city}", {starting_location}, {random_ending_location})'
        else:
            sql_query = f'INSERT INTO orders (client_id, driver_id, datetime, city, starting_location, ending_location) VALUES ({random_client_id}, {random_driver_id}, "{random_datetime}", "{city}", {starting_location}, {random_ending_location})'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to orders table")


def generate_random_feedbacks(rows_number):
    cursor.execute("SELECT COUNT(order_id) FROM orders")
    n = int(cursor.fetchone()[0])
    used_order_id = get_used_ids("order_id", "feedbacks")
    print(used_order_id)

    for i in range(rows_number):
        random_id = random.choice([e for e in range(n) if e not in used_order_id])
        used_order_id.append(random_id)

        random_driver_score = random.randint(1, 5)
        random_text = fake.text(200)

        sql_query = f'INSERT INTO feedbacks (order_id, driver_score, text) VALUES ({random_id}, {random_driver_score}, "{random_text}");'
        # print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to feedbacks table")


def generate_random_payments(rows_number):
    orders_number = get_rows_number("order_id", "orders")
    used_order_id = get_used_ids("order_id", "payments")
    print(used_order_id)

    type_enum = ["Card", "Cash"]

    for i in range(rows_number):
        random_order_id = random.choice([e for e in range(orders_number) if e not in used_order_id])
        used_order_id.append(random_order_id)

        random_type = random.choice(type_enum)
        cursor.execute(f"SELECT datetime FROM orders WHERE order_id = {random_order_id}")
        order_datetime = cursor.fetchone()[0]
        payment_datetime = fake.date_time_between(order_datetime)
        # print(order_datetime, payment_datetime)

        random_paid_status = bool(random.getrandbits(1))

        random_price = 100 + round(abs(random.normalvariate(200, 100)), 2)
        random_discount = round(random.uniform(0, 0.3) * random_price, 2)
        random_driver_income = round(random.uniform(0.2, 0.7) * (random_price - random_discount), 2)

        sql_query = f'INSERT INTO payments (order_id, datetime, type, is_paid, starting_price, discount, driver_income) VALUES ({random_order_id}, "{payment_datetime}", "{random_type}", {random_paid_status}, {random_price}, {random_discount}, {random_driver_income});'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to feedbacks table")


def generate_random_messages(rows_number):
    clients_number = get_rows_number("client_id", "clients")

    not_driver_ids = get_not_drivers_ids()

    sender_enum = ["Employee", "Client"]

    max_id, not_used_ids = get_not_used_ids("message_id", "messages")
    length = len(not_used_ids)
    #
    print(not_used_ids)

    if not_used_ids and length > rows_number:
        this_range = not_used_ids[0:rows_number]
    elif not_used_ids and length <= rows_number:
        not_used_ids.extend(range(max_id, max_id + rows_number - length))
        this_range = not_used_ids
    else:
        this_range = range(rows_number)
    print(type(not_used_ids))
    print(type(this_range))

    for i in this_range:
        random_client_id = random.randint(1, clients_number + 1)

        clients_driver_ids = get_array_from_select(f"SELECT driver_id FROM orders WHERE client_id = {random_client_id}")

        random_employee_id = random.choice(clients_driver_ids + not_driver_ids)

        random_sender = random.choice(sender_enum)

        random_text = fake.text(100)
        if not_used_ids:
            sql_query = f'INSERT INTO messages (message_id, client_id, employee_id, sender, text) VALUES ({i}, {random_client_id}, {random_employee_id}, "{random_sender}", "{random_text}");'
        else:
            sql_query = f'INSERT INTO messages (client_id, employee_id, sender, text) VALUES ({random_client_id}, {random_employee_id}, "{random_sender}", "{random_text}");'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to feedbacks table")


def generate_random_salaries(rows_number):
    employees_number = get_rows_number("employee_id", "employees")

    sender_enum = ["Employee", "Client"]

    for i in range(rows_number):
        random_employee_id = random.randint(1, employees_number)

        random_working_hours = int(abs(random.normalvariate(40, 5)))
        random_waiting_hours = int(abs(random.normalvariate(5, 1)))

        cursor.execute(
            f"SELECT (starting_price - discount), driver_income FROM payments WHERE order_id IN (SELECT order_id FROM orders WHERE driver_id IN (SELECT employee_id FROM drivers WHERE employee_id = {random_employee_id}))")

        driver_income = 0
        total_income = 0
        incomes = cursor.fetchall()
        for income in incomes:
            total_income += income[0]
            driver_income += income[1]

        random_income = Decimal(abs(random.normalvariate(50000, 7000)))
        total_income = round(total_income + random_income, 2)
        employee_salary = round((driver_income + random_income * Decimal(0.4)), 2)

        random_date = fake.date_this_year()

        sql_query = f'INSERT INTO salaries (employee_id, working_hours, waiting_hours, total_amount, employee_salary, date) VALUES ({random_employee_id}, {random_working_hours}, {random_waiting_hours}, {total_income}, {employee_salary}, "{random_date}");'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to salaries table")


def generate_random_time_reserved(rows_number):
    employees_number = get_rows_number("employee_id", "employees")

    for i in range(rows_number):
        random_employee_id = random.randint(1, employees_number)

        random_start_datetime = fake.date_time_this_year()
        random_end_datetime = fake.date_time_between(random_start_datetime)

        sql_query = f'INSERT INTO time_reserved (employee_id, start, end) VALUES ({random_employee_id}, "{random_start_datetime}", "{random_end_datetime}");'
        print(sql_query)
        cursor.execute(sql_query)
        db.commit()

    print(f"{rows_number} rows have been exported successfully to time_reserved table")


if __name__ == '__main__':
    # print(get_rows_number("client_id", "clients"))

    # generate_random_time_reserved(10000)
    # print(fake.local_latlng())
    # print(get_not_drivers_ids())
    # print(get_array_from_select("SELECT driver_id FROM orders WHERE client_id = 3"))
    # generate_random_salaries(1000)
    # generate_random_payments(1000)
    # generate_random_feedbacks(1000)
    # generate_random_messages(2000)
    # generate_random_orders(1000)
    # generate_random_employees(1000)
    # generate_random_drivers(1000)
    generate_random_vehicles(10);
