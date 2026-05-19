# Los distintos tipos de datos para las diferentes tablas #

INT = Almacenamiento de números enteros
NUMERIC = Almacenamiento de números exactos (ya sean enteros o decimales)
CHAR = Almacenamiento de cadenas de caracteres de longitud fija
VARCHAR = Almacenamiento de cadenas de caracteres de longitud variable
ENUM = Delimita y restringe los valores de una columna a opciones definidas (Se guarda como un número)
UNIQUE = Valores únicos, no permite duplicados
NOT NULL = Constraint para contener un valor necesariamente

1. CUSTOMERS
-ID --> INT 
-Full name --> VARCHAR + [NOT NULL]
-Email --> VARCHAR + [UNIQUE] + [NOT NULL]
-Phone --> VACRCHAR + [NOT NULL] (por si se llegara a añadir el +595) Teóricamente se podría aplicar también un CHAR directo en función a la longitud si NO se cuenta el +
-City --> VARCHAR + [NOT NULL]
-Segment --> ENUM + [NOT NULL] porque son categorías FIJAS
-Created at --> TIMESTAMP + [NOT NULL]
-Is active --> BOOLEAN + [NOT NULL]
-Deleted at --> TIMESTAMP (Permite "NULL" porque no necesariamente se habrá borrado)

2. PRODUCTS
-Product ID --> INT 
-SKU --> VARCHAR + [UNIQUE] + [NOT NULL] Teóricamente podría ser un CHAR si TODOS LOS CODES tienen la misma longitud.
-Product name --> VARCHAR + [NOT NULL]
-Category --> ENUM + [NOT NULL]
-Brand --> VARCHAR + + [NOT NULL]
-Unit price --> NUMERIC + [NOT NULL] + CHECK (para chequeo > 0 y que no tenga redondeo como FLOAT)
-Unit cost --> NUMERIC + [NOT NULL] + CHECK (para chequeo > 0 y que no tenga redondeo como FLOAT)
-Created at --> TIMESTAMP + [NOT NULL]
-Is active --> BOOLEAN + [NOT NULL]
-Deleted at --> TIMESTAMP (Permite "NULL" porque no necesariamente se habrá borrado)

3. ORDERS
-Order ID --> INT
-Customer id --> INT + [NOT NULL]
-Order datetime --> TIMESTAMP + [NOT NULL]
-Channel --> ENUM + [NOT NULL]
-Currency --> ENUM + [NOT NULL] (Podría ser también CHAR)
-Current status --> ENUM + [NOT NULL]
-Is active --> BOOLEAN + [NOT NULL]
-Deleted at --> TIMESTAMP (Permite "NULL" porque no necesariamente se habrá borrado)
-Order total --> NUMERIC + [NOT NULL] + CHECK (para chequeo >= 0)

4. ORDER ITEMS
-Order item ID --> INT
-Order ID --> INT + [NOT NULL]
-product ID --> INT + [NOT NULL]
-Quantity --> INT + [NOT NULL] + CHECK (para chequeo >0)
-Unit price --> NUMERIC 
-Discount rate --> 
-Line total --> 