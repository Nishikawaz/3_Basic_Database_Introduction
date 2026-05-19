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


