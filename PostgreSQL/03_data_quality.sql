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

