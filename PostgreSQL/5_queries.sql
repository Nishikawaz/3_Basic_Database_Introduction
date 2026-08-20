-- Consultas de verificación final y reportes de negocio

-- 1. Resumen de Carga Final (Tablero de Control)
SELECT 'Clientes' AS tabla, COUNT(*) FROM customers
UNION ALL SELECT 'Productos', COUNT(*) FROM products
UNION ALL SELECT 'Ordenes', COUNT(*) FROM orders
UNION ALL SELECT 'Items', COUNT(*) FROM order_items
UNION ALL SELECT 'Pagos', COUNT(*) FROM payments
UNION ALL SELECT 'Historial', COUNT(*) FROM order_status_history
UNION ALL SELECT 'Auditoria', COUNT(*) FROM order_audit;

-- 2. Verificación de Integridad
-- Se separan dos cosas que NO son lo mismo:
--   a) monto negativo  -> viola el CHECK (amount >= 0) del esquema. Tiene que dar 0
--                         siempre; si diera otra cosa, la restricción no se aplicó.
--   b) monto en cero   -> el esquema lo PERMITE, así que no es una violación. Es una
--                         anomalía de negocio a revisar (un pago aprobado de 0 es raro).
-- Antes las dos iban juntas con `amount <= 0` bajo la etiqueta "pagos_invalidos", y
-- una carga perfectamente válida reportaba 6.911 "inválidos". Un control que avisa
-- en falso sobre datos correctos enseña a ignorarlo.
SELECT
    COUNT(*) FILTER (WHERE amount < 0)                                AS violaciones_check_negativo,
    COUNT(*) FILTER (WHERE amount = 0)                                AS pagos_en_cero,
    COUNT(*) FILTER (WHERE amount = 0 AND payment_status = 'approved') AS aprobados_en_cero
FROM payments;

-- 3. Reporte de Ventas por Categoría (Ejemplo de uso de JOIN)
-- El WHERE o.is_active NO es opcional: el esquema usa soft-delete, así que las
-- órdenes dadas de baja siguen físicamente en la tabla. Sin filtrarlas, el reporte
-- sumaba 1.210.234,57 de ventas de 605 órdenes borradas.
SELECT
    p.category,
    SUM(oi.line_total) AS total_ventas,
    COUNT(DISTINCT o.order_id) AS cantidad_ordenes
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.is_active
GROUP BY p.category
ORDER BY total_ventas DESC;

-- 4. Verificación de Huérfanos
-- Comprobar si hay pagos que no tienen una orden asociada
SELECT COUNT(*) 
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;