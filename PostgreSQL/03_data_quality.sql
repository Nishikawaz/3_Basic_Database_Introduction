-- File de Auditoría previa a la asignación de Data Types, se sigue el lineamiento de los conceptos de Ingeniería de Datos y se trabaja en función a:
-- 1) Audit de Tipo y Formato (Data Type & Domain Audit)
-- 2) Audit de Consistencia Matemática (Accuracy Audit)
-- 3) Audit de Unicidad y Duplicación (Uniqueness Audit)
-- 4) Audit de Regla de Flujo / Estado (Logical Consistency Audit)
-- 5) Audit de Completitud e Integridad vacía (Completeness Audit)

-- Detecta letras en el historial de cambios de órdenes de precios/totales [Valor antiguo Vs Nuevo valor] (deberían ser valores numéricos)
-- Audit de Tipo y Formato --> Busca datos alfanuméricos que deberían ser numéricos (NUMERIC) 
SELECT 
    audit_id AS identificador_de_auditoria,
    field_name, 
    old_value, 
    new_value,
    changed_at
FROM staging.order_audit
WHERE field_name = 'order_total'
AND (new_value ~ '[A-Za-z]' OR old_value ~ '[A-Za-z]');  

-- Detecta ítems donde el descuento fue ignorado en el cobro real (El total según CSV es el valor que fijaron en line_total)
-- Audit de Consistencia Matemática --> Busca errores de cálculo heredados, se puede suponer que no se aplicó bien la fórmula en la celda "line_total" puesto que no se descuenta.
SELECT 
    order_item_id, 
    quantity, 
    unit_price, 
    discount_rate,
    line_total AS total_segun_csv,
    (quantity::NUMERIC * unit_price::NUMERIC * (1 - discount_rate::NUMERIC)) AS total_real_esperado
FROM staging.order_items
WHERE discount_rate::NUMERIC > 0
AND line_total::NUMERIC = (quantity::NUMERIC * unit_price::NUMERIC);

-- Detecta clientes duplicados por nombre que tienen IDs diferentes
-- Audit de Unicidad y Duplicación --> Para verificación de valores únicos y duplicados
SELECT 
    c1.customer_id AS id_1, 
    c2.customer_id AS id_2, 
    c1.full_name AS cliente, 
    -- Comparativa de Emails
    c1.email AS email_1, 
    c2.email AS email_2,
    -- Comparativa de Teléfonos
    c1.phone AS phone_1, 
    c2.phone AS phone_2,
    -- Comparativa de Ciudades
    c1.city AS city_1, 
    c2.city AS city_2
FROM staging.customers c1
JOIN staging.customers c2 ON c1.full_name = c2.full_name
-- Con la distinción de 1 sola tanda de combinación en el self join
WHERE c1.customer_id < c2.customer_id 
ORDER BY c1.full_name
LIMIT 100;

-- Detecta mercadería enviada o entregada con cobros rechazados o fallidos.
-- Audit de Regla de Flujo / Estado  --> Rompe con el esquema lógico del modelo de negocio
SELECT 
    o.order_id, 
    o.current_status AS estado_logistico, 
    p.payment_id,
    p.payment_status AS estado_financiero
FROM staging.orders o
JOIN staging.payments p ON o.order_id = p.order_id
WHERE o.current_status IN ('shipped', 'delivered') 
  AND p.payment_status IN ('rejected', 'failed', 'pending')
LIMIT 100;
