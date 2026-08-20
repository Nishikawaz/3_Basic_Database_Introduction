-- ============================================================================
-- Carga masiva de los CSV a las tablas staging.
--
-- La ruta del dataset NO está hardcodeada: se pasa como variable de psql al
-- invocar el script, así el repo funciona en cualquier máquina.
--
--   psql -U postgres -d penguin_academy_db \
--        -v datadir=/ruta/absoluta/a/Data/dataset \
--        -f 2_data_loading.sql
--
-- Ojo: COPY se ejecuta del lado del SERVIDOR, así que la ruta tiene que existir
-- en la máquina donde corre PostgreSQL y el usuario necesita permisos de lectura
-- sobre ella (por defecto, superusuario o el rol pg_read_server_files).
-- Si PostgreSQL corre en otra máquina o en un contenedor, cambiar cada COPY por
-- \copy, que lee del lado del cliente y no necesita esos permisos.
-- ============================================================================

-- Corte temprano y con mensaje claro si falta la variable. Sin esto, el error
-- sería un "no existe la relación :datadir" que no explica nada.
\if :{?datadir}
\else
\echo ''
\echo 'ERROR: falta la variable datadir.'
\echo 'Uso: psql -d penguin_academy_db -v datadir=/ruta/a/Data/dataset -f 2_data_loading.sql'
\echo ''
\quit
\endif

\echo 'Cargando CSV desde:' :datadir

-- Se eliminan los valores de las tablas
TRUNCATE TABLE
staging_customers,
staging_products,
staging_orders,
staging_order_items,
staging_payments,
staging_order_status_history,
staging_order_audit
CASCADE;

-- Carga masiva usando el comando COPY
-- COPY permite la transferencia de datos de manera rápida y eficiente entre tabla/s de la BD y files externos
-- \set concatena sus argumentos, así que cada ruta se arma como datadir + nombre del archivo.
-- :'variable' interpola el valor ya escapado como literal SQL.

\set ruta_customers :datadir '/customers.csv'
COPY staging_customers (customer_id, full_name, email, phone, city, segment, created_at, is_active, deleted_at)
FROM :'ruta_customers' WITH CSV HEADER DELIMITER ',';

\set ruta_products :datadir '/products.csv'
COPY staging_products (product_id, sku, product_name, category, brand, unit_price, unit_cost, created_at, is_active, deleted_at)
FROM :'ruta_products' WITH CSV HEADER DELIMITER ',';

\set ruta_orders :datadir '/orders.csv'
COPY staging_orders (order_id, customer_id, order_datetime, "channel", currency, current_status, is_active, deleted_at, order_total)
FROM :'ruta_orders' WITH CSV HEADER DELIMITER ',';

\set ruta_order_items :datadir '/order_items.csv'
COPY staging_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_rate, line_total)
FROM :'ruta_order_items' WITH CSV HEADER DELIMITER ',';

\set ruta_payments :datadir '/payments.csv'
COPY staging_payments (payment_id, order_id, payment_datetime, "method", payment_status, amount, currency)
FROM :'ruta_payments' WITH CSV HEADER DELIMITER ',';

\set ruta_status_history :datadir '/order_status_history.csv'
COPY staging_order_status_history (status_history_id, order_id, "status", changed_at, changed_by, reason)
FROM :'ruta_status_history' WITH CSV HEADER DELIMITER ',';

\set ruta_order_audit :datadir '/order_audit.csv'
COPY staging_order_audit (audit_id, order_id, field_name, old_value, new_value, changed_at, changed_by)
FROM :'ruta_order_audit' WITH CSV HEADER DELIMITER ',';

-- Comandos SELECT para verificar filas generadas en las tablas
SELECT 'customers' AS tabla, COUNT(*) AS total_filas FROM staging_customers
UNION ALL
SELECT 'products', COUNT(*) FROM staging_products
UNION ALL
SELECT 'orders', COUNT(*) FROM staging_orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM staging_order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM staging_payments
UNION ALL
SELECT 'order_status_history', COUNT(*) FROM staging_order_status_history
UNION ALL
SELECT 'order_audit', COUNT(*) FROM staging_order_audit;
