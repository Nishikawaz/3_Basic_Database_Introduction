-- Vaciamos las tablas antes de la carga masiva (por si estuvieran precargadas)
TRUNCATE TABLE
    staging.customers,
    staging.products,
    staging.orders,
    staging.order_items,
    staging.payments,
    staging.order_status_history,
    staging.order_audit
RESTART IDENTITY CASCADE;

-- Carga masiva usando el COPY del Servidor 
COPY staging.customers (customer_id, full_name, email, phone, city, segment, created_at, is_active, deleted_at) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/customers.csv' WITH CSV HEADER DELIMITER ',';

COPY staging.products (product_id, sku, product_name, category, brand, unit_price, unit_cost, created_at, is_active, deleted_at) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/products.csv' WITH CSV HEADER DELIMITER ',';

COPY staging.orders (order_id, customer_id, order_datetime, "channel", currency, current_status, is_active, deleted_at, order_total) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/orders.csv' WITH CSV HEADER DELIMITER ',';

COPY staging.order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_rate, line_total) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/order_items.csv' WITH CSV HEADER DELIMITER ',';

COPY staging.payments (payment_id, order_id, payment_datetime, "method", payment_status, amount, currency) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/payments.csv' WITH CSV HEADER DELIMITER ',';

COPY staging.order_status_history (status_history_id, order_id, "status", changed_at, changed_by, reason) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/order_status_history.csv' WITH CSV HEADER DELIMITER ',';

COPY staging.order_audit (audit_id, order_id, field_name, old_value, new_value, changed_at, changed_by) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/order_audit.csv' WITH CSV HEADER DELIMITER ',';