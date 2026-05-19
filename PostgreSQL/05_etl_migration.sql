-- Clientes: Limpieza de espacios y filtro de emails basura
TRUNCATE TABLE 
    public.order_audit,
    public.order_status_history,
    public.payments,
    public.order_items,
    public.orders,
    public.products,
    public.customers
CASCADE;
INSERT INTO public.customers
SELECT 
    customer_id::INTEGER, TRIM(full_name), TRIM(email), NULLIF(TRIM(phone), ''), 
    TRIM(city), TRIM(segment), created_at::TIMESTAMP, 
    is_active::INTEGER::BOOLEAN, NULLIF(TRIM(deleted_at), '')::TIMESTAMP
FROM customers
WHERE email LIKE '%@%' AND customer_id IS NOT NULL;

-- Productos: Aseguramos el margen de ganancia
INSERT INTO public.products
SELECT 
    product_id::INTEGER, TRIM(sku), TRIM(product_name), TRIM(category), 
    TRIM(brand), unit_price::NUMERIC, unit_cost::NUMERIC, is_active::INTEGER::BOOLEAN
FROM staging.products
WHERE unit_price::NUMERIC >= unit_cost::NUMERIC;

-- Órdenes: Solo aquellas con IDs de cliente válidos que migraron
INSERT INTO public.orders
SELECT 
    order_id::INTEGER, customer_id::INTEGER, order_datetime::TIMESTAMP, 
    TRIM(channel), TRIM(currency), TRIM(current_status), order_total::NUMERIC
FROM staging.orders
WHERE customer_id::INTEGER IN (SELECT customer_id FROM public.customers)
  AND order_total::NUMERIC >= 0;

-- Ítems: Corregimos la matemática si el descuento fue ignorado en el CSV
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

-- Pagos, Historial y Auditoría (Sigue la misma lógica de FK)
INSERT INTO public.payments (
    payment_id, order_id, payment_datetime, method, payment_status, amount, currency
)
SELECT 
    payment_id::INTEGER, 
    order_id::INTEGER, 
    payment_datetime::TIMESTAMP, 
    TRIM(method), 
    TRIM(payment_status), 
    amount::NUMERIC, 
    TRIM(currency)
FROM staging.payments 
WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders)
  AND amount::NUMERIC > 0; -- Acá filtramos la basura matemática que hizo saltar el error

INSERT INTO public.order_status_history
SELECT status_history_id::INTEGER, order_id::INTEGER, status, changed_at::TIMESTAMP, changed_by
FROM staging.order_status_history WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders);

INSERT INTO public.order_audit
SELECT audit_id::INTEGER, order_id::INTEGER, field_name, old_value, new_value, changed_at::TIMESTAMP, changed_by
FROM staging.order_audit WHERE order_id::INTEGER IN (SELECT order_id FROM public.orders);