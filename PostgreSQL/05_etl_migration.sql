-- 1. Desactivamos las restricciones de FK temporalmente para la carga masiva
SET session_replication_role = 'replica';

-- 2. Limpieza segura: TRUNCATE es más rápido que DELETE
TRUNCATE TABLE 
    public.order_audit,
    public.order_status_history,
    public.payments,
    public.order_items,
    public.orders,
    public.products,
    public.customers
RESTART IDENTITY CASCADE;

-- 3. Inserciones con manejo de errores de conversión
INSERT INTO public.customers (customer_id, full_name, email, phone, city, segment, created_at, is_active, deleted_at)
SELECT
    customer_id::INTEGER, TRIM(full_name), TRIM(email), TRIM(phone),
    TRIM(city), TRIM(segment)::customer_section, created_at::TIMESTAMP,
    (is_active::text = '1'), -- Conversión booleana segura
    NULLIF(TRIM(deleted_at), '')::TIMESTAMP
FROM staging.customers
WHERE email LIKE '%@%' AND customer_id IS NOT NULL AND TRIM(phone) != '';

INSERT INTO public.products (product_id, sku, product_name, category, brand, unit_price, unit_cost, created_at, is_active, deleted_at)
SELECT
    product_id::INTEGER, TRIM(sku), TRIM(product_name), TRIM(category)::product_category,
    TRIM(brand), unit_price::NUMERIC, unit_cost::NUMERIC, created_at::TIMESTAMP,
    (is_active::text = '1'),
    NULLIF(TRIM(deleted_at), '')::TIMESTAMP
FROM staging.products
WHERE unit_price::NUMERIC > unit_cost::NUMERIC;

INSERT INTO public.orders (order_id, customer_id, order_datetime, channel, currency, current_status, order_total, is_active, deleted_at)
SELECT
    order_id::INTEGER, customer_id::INTEGER, order_datetime::TIMESTAMP,
    TRIM(channel)::order_channel, TRIM(currency)::currency_code,
    TRIM(current_status)::order_status, order_total::NUMERIC,
    (is_active::text = '1'),
    NULLIF(TRIM(deleted_at), '')::TIMESTAMP
FROM staging.orders
WHERE customer_id::INTEGER IN (SELECT customer_id FROM public.customers)
  AND order_total::NUMERIC >= 0;

INSERT INTO public.order_items
SELECT 
    order_item_id::INTEGER, order_id::INTEGER, product_id::INTEGER, 
    quantity::INTEGER, unit_price::NUMERIC, discount_rate::NUMERIC,
    CASE 
        WHEN discount_rate::NUMERIC > 0 THEN (quantity::NUMERIC * unit_price::NUMERIC * (1 - discount_rate::NUMERIC))
        ELSE line_total::NUMERIC 
    END
FROM staging.order_items
WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders);

INSERT INTO public.payments (payment_id, order_id, payment_datetime, method, payment_status, amount, currency)
SELECT
    payment_id::INTEGER, order_id::INTEGER, payment_datetime::TIMESTAMP,
    TRIM(method)::payment_method, TRIM(payment_status)::payment_status_check,
    amount::NUMERIC, TRIM(currency)::currency_code
FROM staging.payments
WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders)
  AND amount::NUMERIC > 0
  AND TRIM(payment_status) IN ('pending', 'approved', 'rejected', 'refunded');

INSERT INTO public.order_status_history (status_history_id, order_id, status, changed_at, changed_by, reason)
SELECT
    status_history_id::INTEGER, order_id::INTEGER,
    TRIM(status)::order_status, changed_at::TIMESTAMP,
    TRIM(changed_by)::status_actor,
    NULLIF(TRIM(reason), '')::order_reason
FROM staging.order_status_history
WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders)
  AND (reason IS NULL OR TRIM(reason) IN ('chargeback', 'customer_request', 'fraud_check', 'out_of_stock', 'payment_failed', 'return', 'service_issue'));

INSERT INTO public.order_audit (audit_id, order_id, field_name, old_value, new_value, changed_at, changed_by)
SELECT
    audit_id::INTEGER, order_id::INTEGER, field_name, old_value, new_value,
    changed_at::TIMESTAMP, TRIM(changed_by)::audit_responsible
FROM staging.order_audit
WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders)
  AND field_name IN ('current_status', 'shipping_address', 'order_total', 'notes', 'customer_phone');

-- 4. Reactivamos las restricciones de FK
SET session_replication_role = 'origin';