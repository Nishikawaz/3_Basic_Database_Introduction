# Pipeline de carga y modelado en PostgreSQL

Pipeline ETL sobre PostgreSQL que carga ~988.000 filas de un e-commerce simulado desde CSV, las tipa y las inserta en un esquema relacional con integridad referencial, restricciones de dominio y soft-delete.

**Stack:** PostgreSQL 18 · SQL puro (sin ORM ni scripts de aplicación)

---

## El dataset

Siete CSV que modelan un e-commerce: clientes, catálogo, pedidos, ítems, pagos, historial de estados y auditoría de cambios.

| Archivo | Filas | Contenido |
|---|---:|---|
| `customers.csv` | 30.000 | Clientes con segmento y soft-delete |
| `products.csv` | 8.000 | Catálogo con SKU, precio y costo |
| `orders.csv` | 120.000 | Pedidos con canal, moneda y estado actual |
| `order_items.csv` | 360.000 | Líneas de pedido con cantidad y descuento |
| `payments.csv` | 140.000 | Pagos con método y estado |
| `order_status_history.csv` | 250.000 | Trazabilidad de cambios de estado |
| `order_audit.csv` | 80.000 | Auditoría campo a campo |

El diccionario de columnas está en `Data/dataset_overview/dataset_dictionary.csv`.

---

## Cómo correrlo

**Requisitos:** PostgreSQL instalado y una base creada.

```bash
createdb penguin_academy_db
```

Los scripts se ejecutan **en orden numérico**. La ruta del dataset se pasa como variable, así el repo funciona en cualquier máquina:

```bash
psql -U postgres -d penguin_academy_db -f PostgreSQL/1_data_staging.sql
psql -U postgres -d penguin_academy_db -v datadir="$(pwd)/Data/dataset" -f PostgreSQL/2_data_loading.sql
psql -U postgres -d penguin_academy_db -f PostgreSQL/3_data_schema.sql
psql -U postgres -d penguin_academy_db -f PostgreSQL/4_data_insert.sql
psql -U postgres -d penguin_academy_db -f PostgreSQL/5_queries.sql
```

Si falta `-v datadir=`, el script corta con un mensaje que explica el uso en vez de fallar con un error de sintaxis críptico.

> `COPY` se ejecuta del lado del **servidor**: la ruta tiene que existir en la máquina donde corre PostgreSQL, y el rol necesita permiso de lectura sobre ella (superusuario o `pg_read_server_files`). Si PostgreSQL corre en otra máquina o en un contenedor, hay que cambiar cada `COPY` por `\copy`, que lee del lado del cliente. El detalle está en [`PostgreSQL/1.5_data_loading_route.md`](PostgreSQL/1.5_data_loading_route.md).

Todos los scripts son idempotentes: empiezan con `DROP ... IF EXISTS` o `TRUNCATE`, así que se pueden volver a correr desde cero sin limpiar a mano.

### Verificado

El pipeline completo se ejecutó contra PostgreSQL 17 con el dataset del repo:

| Paso | Resultado |
|---|---|
| `2_data_loading.sql` | 988.000 filas cargadas en **2,5 s** |
| `4_data_insert.sql` | 988.000 filas migradas al esquema tipado en **1 m 31 s**, sin violar ninguna restricción |
| `5_queries.sql` / `6_ejercicios.sql` | corren completos, sin errores |
| Segunda corrida completa | mismos conteos — la idempotencia se cumple |

---

## Estructura

```
Data/
├── dataset/                     Los 7 CSV de origen
└── dataset_overview/
    └── dataset_dictionary.csv   Filas y columnas por archivo

PostgreSQL/
├── 1_data_staging.sql           Crea las 7 tablas staging (todo TEXT)
├── 2_data_loading.sql           Carga masiva con COPY + conteo de verificación
├── 1.5_data_loading_route.md    Comando de carga en Windows
├── 3_data_schema.sql            Esquema final: ENUMs, tablas, FKs, CHECKs, índices
├── 4_data_insert.sql            Casteo y migración de staging → esquema final
├── 5_queries.sql                Consultas de verificación y reportes de negocio
├── 6_ejercicios.sql             16 ejercicios de SELECT, JOIN y filtrado
└── justificacion.md             Por qué PostgreSQL y no otro motor
```

---

## Decisiones de diseño

**Staging en `TEXT` antes del esquema tipado.** Las siete tablas staging declaran todas sus columnas como `TEXT`. Es deliberado: `COPY` es *todo o nada* — bloquea la tabla y aborta la transacción completa ante el primer error de tipo. Cargar contra columnas tipadas significaría que una sola fecha mal formateada en la fila 300.000 tira abajo toda la carga sin decir cuál era el problema. Con staging en texto, la carga entra siempre y la validación se hace después, en el paso de casteo, donde los errores son inspeccionables con `SELECT`.

**El casteo vive en `4_data_insert.sql`.** Ahí se convierte cada columna a su tipo real: `::NUMERIC(12,2)` para montos, `::TIMESTAMP` para fechas, `::ENUM` para dominios cerrados. Se usa `TRIM` contra espacios sobrantes, `NULLIF` para convertir cadenas vacías en `NULL` (que es lo que `COPY` deja al leer un campo vacío del CSV), y `CASE WHEN` para traducir texto a booleanos.

**Diez tipos ENUM en lugar de `VARCHAR` con `CHECK`.** Categorías, canales, estados de pedido, métodos de pago, monedas y actores tienen dominios cerrados y conocidos. Un ENUM los valida a nivel de tipo, ocupa 4 bytes en lugar de la cadena completa, y hace que un valor inválido falle en el casteo en vez de entrar silenciosamente a la tabla.

**Soft-delete con restricción de consistencia.** Clientes, productos y pedidos no se borran: se marcan. Un `CHECK` fuerza que los dos campos que representan ese estado no puedan contradecirse:

```sql
CONSTRAINT chk_customer_soft_delete CHECK (
    (is_active = TRUE  AND deleted_at IS NULL) OR
    (is_active = FALSE AND deleted_at IS NOT NULL)
)
```

Sin esa restricción es cuestión de tiempo que aparezca una fila activa con fecha de borrado, o una borrada sin fecha. La base no permite ninguno de los dos.

**Reglas de negocio en la base, no en la aplicación.** `unit_price > unit_cost` impide un producto que se vende a pérdida. `discount_rate BETWEEN 0 AND 0.25` topea el descuento en 25%. `quantity > 0` y `amount >= 0` cierran los casos absurdos. La ventaja de que vivan acá es que valen para cualquier cliente que escriba en la base, incluida una consola de `psql` a mano.

**Índices sobre las seis claves foráneas.** PostgreSQL crea índice automático para las PK y las restricciones `UNIQUE`, pero **no** para las FK. Sin ellos, cada `JOIN` desde `orders` hacia `order_items` sería un *sequential scan* sobre 360.000 filas. Además hay índices sobre las columnas que más se filtran: `current_status`, `payment_status` y `order_datetime DESC` (descendente, porque los reportes piden lo más reciente primero).

**Por qué PostgreSQL.** El razonamiento completo está en [`PostgreSQL/justificacion.md`](PostgreSQL/justificacion.md): integridad referencial estricta, soporte de ENUM y restricciones complejas, y `COPY` nativo para carga masiva a nivel de sistema de archivos.

---

## Verificación

`5_queries.sql` incluye las consultas de control:

1. **Tablero de carga** — conteo por tabla, para confirmar que llegaron todas las filas
2. **Integridad de montos** — separa violaciones de restricción de anomalías de negocio (ver abajo)
3. **Reporte de ventas por categoría** — `JOIN` sobre el esquema final, excluyendo órdenes dadas de baja
4. **Detección de huérfanos** — pagos sin pedido asociado

Las consultas 2 y 4 deberían dar cero: si las FK y los `CHECK` están bien puestos, la base ya hace imposibles esos casos. Son la verificación de que las restricciones efectivamente se aplicaron, no de que los datos "parezcan" bien.

**Sobre la consulta 2 — por qué separa dos cosas.** El esquema declara `amount >= 0`, así que un pago en 0 es *válido* para la base. Medirlo junto con los negativos bajo una etiqueta de "pagos inválidos" hacía que una carga perfectamente correcta reportara 6.911 problemas. Ahora la consulta distingue:

| Medida | Valor | Qué significa |
|---|---:|---|
| `violaciones_check_negativo` | 0 | El `CHECK` se aplicó. Si diera ≠ 0, algo está muy mal |
| `pagos_en_cero` | 6.911 | Permitido por el esquema — dato a revisar, no falla |
| `aprobados_en_cero` | 5.541 | De esos, los realmente sospechosos: un pago *aprobado* de 0 |

**Sobre la consulta 3 — el filtro de soft-delete no es opcional.** El esquema no borra órdenes, las marca. Un reporte de ventas que no filtra `is_active` suma las órdenes dadas de baja: en este dataset son 605 órdenes y **1.210.234,57 de ventas fantasma**. Implementar soft-delete y después ignorarlo en el único reporte de negocio anula el propósito del diseño.

`6_ejercicios.sql` recorre 16 ejercicios que van de `SELECT` con `WHERE` simple hasta `LEFT JOIN` para listar clientes sin pedidos. El ejercicio 16 está **sin resolver** y queda comentado para que el archivo se pueda ejecutar entero.

---

## Contexto

Challenge de introducción a bases de datos. La consigna pedía elegir un motor y justificar la elección, diseñar un esquema normalizado con integridad referencial, cargar un dataset masivo desde CSV y demostrar el manejo de errores de carga.

La estructura en dos capas — staging crudo y esquema tipado — es la respuesta a la parte de la consigna sobre forzar y detectar fallos de integridad: permite ver exactamente qué fila y qué columna rompen, en lugar de recibir un abort genérico.

---
