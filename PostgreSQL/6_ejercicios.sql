-- Estructura base de una query
--SELECT
--FROM
--JOIN
--WHERE
--ORDER BY

-- 1) Listar todos los nombres y correos de clientes
SELECT c.full_name, c.email
FROM customers as c;

-- 2) Mostrar los productos que cuesten menos de 100
SELECT p.product_name
FROM products as p
WHERE p.unit_price < 100;

-- 3) Obtener los pedidos que tienen un total de ordenes superior a 5000
SELECT o.order_id
FROM orders o
WHERE 5000 < o.order_total;

-- 4) Muestra todos los pagos realizados con un método "CASH"
SELECT p.payment_id
FROM payments as p
WHERE p.method = 'cash';

-- 5) Lista los productos de la categoría "electronics" ordenados por precio de mayor a menor
SELECT p.product_id, p.product_name, p.unit_price
FROM products p
WHERE p.category = 'electronics'
ORDER BY p.unit_price DESC;

-- 6) Obtener el id de la orden y el nombre del cliente para todos los pedidos
SELECT o.order_id, c.full_name
FROM orders as o
JOIN customers c
    ON o.customer_id = c.customer_id;

-- 7) Mostrar el nombre del producto y la cantidad vendida de cada ítem de pedido
SELECT p.product_name, oi.quantity
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id;

-- 8) Lista los órdenes que tengan pagos asociados.
        -- Usar Distinct para no repetir pedidos si tienen múltiples pagos
SELECT DISTINCT o.order_id
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id;

-- 9) Mostrar los nombres de los clientes que hicieron pedidos a través del canal mobile
SELECT c.full_name
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE channel = 'mobile';

-- 10) Obtén los productos comprados en cada pedido, mostrando el order y product name
SELECT o.order_id, product_name
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id;

-- 11) Lista los nombres de los clientes que viven en San Lorenzo y segment retail
SELECT c.full_name
FROM customers c
WHERE city = 'San Lorenzo'
    AND segment = 'retail';

-- 12) Obtén los productos de la marca "Mares" que tienen un precio mayor a 250
SELECT p.product_name
FROM products p
WHERE brand = 'Mares'
    AND unit_price  > 250;

-- 13) Muestra el order_id, el monto real y el nombre del cliente para todos los pedidos realizados por clientes en Asunción
SELECT o.order_id, o.order_total, c.full_name
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.city = 'Asunción';

-- 14) Lista los pagos aprobados que sean mayores a 1000
SELECT p.payment_id, p.amount, payment_status
FROM payments p
WHERE payment_status = 'approved'
    AND amount > 1000
ORDER BY amount DESC;

-- 15) Lista todos los clientes aunque no hayan realizado ningún pedido
SELECT c.full_name, o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

-- 16) Lista todos los productos incluso aquellos que nunca han sido vendidos
-- PENDIENTE: ejercicio sin resolver. Queda comentado para que el archivo se pueda
-- ejecutar entero; al resolverlo, descomentar.
-- SELECT
-- FROM
-- LEFT JOIN
