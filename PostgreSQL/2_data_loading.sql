-- Carga masiva usando el comando COPY del Servidor 
-- COPY permite la transferencia de datos de manera rápida y eficiente entre tabla/s de la BD y files externos
-- Si se llegara a mover el path del archivo, se debe cambiar el FROM para que se ejecute correctamente el comando

TRUNCATE TABLE
staging_customers,
staging_products,
staging_orders,
staging_order_items,
staging_payments,
staging_order_status_history,
staging_order_audit
CASCADE;

COPY staging_customers (customer_id, full_name, email, phone, city, segment, created_at, is_active, deleted_at) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/customers.csv' WITH CSV HEADER DELIMITER ',';

COPY staging_products (product_id, sku, product_name, category, brand, unit_price, unit_cost, created_at, is_active, deleted_at) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/products.csv' WITH CSV HEADER DELIMITER ',';

COPY staging_orders (order_id, customer_id, order_datetime, "channel", currency, current_status, is_active, deleted_at, order_total) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/orders.csv' WITH CSV HEADER DELIMITER ',';

COPY staging_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_rate, line_total) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/order_items.csv' WITH CSV HEADER DELIMITER ',';

COPY staging_payments (payment_id, order_id, payment_datetime, "method", payment_status, amount, currency) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/payments.csv' WITH CSV HEADER DELIMITER ',';

COPY staging_order_status_history (status_history_id, order_id, "status", changed_at, changed_by, reason) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/order_status_history.csv' WITH CSV HEADER DELIMITER ',';

COPY staging_order_audit (audit_id, order_id, field_name, old_value, new_value, changed_at, changed_by) 
FROM 'C:/Users/kento/OneDrive/Desktop/Database_Introduction/Data/dataset/order_audit.csv' WITH CSV HEADER DELIMITER ',';

