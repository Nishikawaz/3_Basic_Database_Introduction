TRUNCATE TABLE
    customers,
    products,
    orders,
    order_items,
    payments,
    order_status_history,
    order_audit
CASCADE;

-- ::(DATATYPE), es un casteo. Transforma el TEXT del staging al DataType correcto. 
-- ::(ENUM), es un casteo para indicar ENUMS.
-- TRIM, elimina los espacios en blanco al inicio y al final.
-- CASE WHEN, es la lógica condicional de SQL. Se traducen a booleanos.
-- NULLIF, Si el texto está vacío "", lo convierte en un valor NULL.
-- NUMERIC(X,Y), Convierte el texto en número decimal que permite hasta "X" dígitos y "Y" decimales (sin redondeo).

INSERT INTO customers (
    customer_id,
    full_name,
    email,
    phone,
    city,
    segment,
    created_at,
    is_active,
    deleted_at
)
SELECT
    customer_id::INTEGER,
    TRIM(full_name),
    TRIM(email),
    TRIM(phone),
    TRIM(city),
    LOWER(TRIM(segment))::customer_section,
    created_at::TIMESTAMP,
    CASE
        WHEN LOWER(TRIM(is_active)) IN ('1') THEN TRUE
        WHEN LOWER(TRIM(is_active)) IN ('0') THEN FALSE
        ELSE NULL
    END,
    NULLIF(TRIM(deleted_at), '')::TIMESTAMP 
FROM staging_customers;

INSERT INTO products (
    product_id,
    sku,
    product_name,
    category,
    brand,
    unit_price,
    unit_cost,
    created_at,
    is_active,
    deleted_at
)
SELECT
    product_id::INTEGER,
    TRIM(sku),
    TRIM(product_name),
    LOWER(TRIM(category))::product_category,
    TRIM(brand),
    unit_price::NUMERIC(12,2),
    unit_cost::NUMERIC(12,2),
    created_at::TIMESTAMP,
    CASE
        WHEN LOWER(TRIM(is_active)) IN ('1') THEN TRUE
        WHEN LOWER(TRIM(is_active)) IN ('0') THEN FALSE
        ELSE NULL
    END,
    NULLIF(TRIM(deleted_at), '')::TIMESTAMP
FROM staging_products;

INSERT INTO orders (
    order_id,
    customer_id,
    order_datetime,
    channel,
    currency,
    current_status,
    order_total,
    is_active,
    deleted_at
)
SELECT
    order_id::INTEGER,
    customer_id::INTEGER,
    order_datetime::TIMESTAMP,
    LOWER(TRIM(channel))::order_channel,
    UPPER(TRIM(currency))::currency_code,
    LOWER(TRIM(current_status))::order_status,
    order_total::NUMERIC(12,2),
    CASE
        WHEN LOWER(TRIM(is_active)) IN ('1') THEN TRUE
        WHEN LOWER(TRIM(is_active)) IN ('0') THEN FALSE
        ELSE NULL
    END,
    NULLIF(TRIM(deleted_at), '')::TIMESTAMP
FROM staging_orders;

INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_rate,
    line_total
)
SELECT
    order_item_id::INTEGER,
    order_id::INTEGER,
    product_id::INTEGER,
    quantity::INTEGER,
    unit_price::NUMERIC(12,2),
    discount_rate::NUMERIC(5,4),
    line_total::NUMERIC(12,2)
FROM staging_order_items;

INSERT INTO payments (
    payment_id,
    order_id,
    payment_datetime,
    method,
    payment_status,
    amount,
    currency
)
SELECT
    payment_id::INTEGER,
    order_id::INTEGER,
    payment_datetime::TIMESTAMP,
    LOWER(TRIM(method))::payment_method,
    LOWER(TRIM(payment_status))::payment_status_check,
    amount::NUMERIC(12,2),  -- 12,2 para coincidir con el tipo declarado en 3_data_schema.sql
    UPPER(TRIM(currency))::currency_code
FROM staging_payments;

INSERT INTO order_status_history (
    status_history_id,
    order_id,
    status,
    changed_at,
    changed_by,
    reason
)
SELECT
    status_history_id::INTEGER,
    order_id::INTEGER,
    LOWER(TRIM(status))::order_status,
    changed_at::TIMESTAMP,
    LOWER(TRIM(changed_by))::status_actor,
    NULLIF(LOWER(TRIM(reason)), '')::order_reason
FROM staging_order_status_history;

INSERT INTO order_audit (
    audit_id,
    order_id,
    field_name,
    old_value,
    new_value,
    changed_at,
    changed_by
)
SELECT
    audit_id::INTEGER,
    order_id::INTEGER,
    LOWER(TRIM(field_name)),
    NULLIF(TRIM(old_value), ''),
    NULLIF(TRIM(new_value), ''),
    changed_at::TIMESTAMP,
    LOWER(TRIM(changed_by))::audit_responsible
FROM staging_order_audit;