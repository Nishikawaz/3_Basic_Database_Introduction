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
-- Comprobar que no existen pagos con monto 0 o negativo en public
SELECT COUNT(*) AS pagos_invalidos_en_public
FROM payments
WHERE amount <= 0;

-- 3. Reporte de Ventas por Categoría (Ejemplo de uso de JOIN)
SELECT 
    p.category, 
    SUM(oi.line_total) AS total_ventas,
    COUNT(DISTINCT o.order_id) AS cantidad_ordenes
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY total_ventas DESC;

-- 4. Verificación de Huérfanos
-- Comprobar si hay pagos que no tienen una orden asociada
SELECT COUNT(*) 
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;