# Justificación Técnica del Motor de BD (PostgreSQL) #
Como el enunciado exige justificar la elección tecnológica, expongo los siguientes argumentos clave por los que utilizo PostgreSQL:

1. Manejo de Integridad Referencial: PostgreSQL implementa de forma estricta el estándar SQL para claves foráneas (FOREIGN KEY), garantizando que no existan pedidos "huérfanos" ni pagos sin cliente asociado. Soporta acciones en cascada (ON DELETE CASCADE / RESTRICT) y evaluación diferida de restricciones si fuera necesario.

2. Soporte para Constraints e Índices: Permite la creación de restricciones complejas (CHECK), unicidad (UNIQUE) y tipos de datos avanzados (como ENUM para estados o UUID). Soporta índices B-Tree (por defecto para búsquedas rápidas), Exclusión y GIST, ideales para optimizar consultas estructurales.

3. Comportamiento ante Carga Masiva (CSV): Cuenta con el comando nativo COPY, una herramienta extremadamente eficiente que procesa la carga directamente a nivel de sistema de archivos. Al ejecutar COPY, PostgreSQL valida de forma estricta e inmediata todas las reglas de integridad (tipos de datos, NOT NULL, CHECK). Si una sola fila viola una restricción, la transacción completa aborta, lo que te permitirá forzar y detectar los fallos requeridos por el challenge.

4. Limitaciones Relevantes: El comando COPY nativo requiere que el archivo mantenga una estructura perfectamente uniforme y es "todo o nada" (bloquea la tabla y falla al primer error). Para un sistema en producción, la gestión de bloqueos por alta concurrencia durante inserciones masivas requiere una configuración fina de vacuuming y monitoreo de MVCC (Multi-Version Concurrency Control).