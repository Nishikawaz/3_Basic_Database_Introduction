# Flujo del proyecto (ETL)

Extract, Transform & Load


# Detalles del proyecto
1) Inicialmente se genera la carpeta de "dataset", "dataset_overview" y "diagramas" donde se colocan los files de origen (.CSV).
2) Luego se genera una nueva carpeta "PostgreSQL" donde se listan los files en los que se estará trabajando para el challenge (.SQL).
3) Se inicia creando el file "1_data_staging.sql" en donde se generan las tablas staging, donde se traen todos los datos "crudos" TEXT, se importa todo como texto primero para asegurar que los datos "aterricen" en la base de datos. Posteriormente se validarán, limpiarán y se convertirán (castear) a sus datatypes reales en tablas definitivas.
4) El file "1.5_data_loading_route.md" es un comando inicial que actúa como puente entre el SO y el motor de BD. Explicando un poco la secuencia:

"C:\Program Files\PostgreSQL\18\bin\psql.exe": Llama directamente a la herramienta interactiva de PostgreSQL.  

-U postgres: Indica que te estás conectando con el usuario superadministrador "postgres". 

-d penguin_academy_db: Especifica que todas las instrucciones se ejecutarán dentro de esta base de datos en particular.  

-f 2_data_loading.sql: Es el parámetro clave. Le dice al motor que no espere comandos manuales, sino que lea y ejecute todo el archivo SQL especificado.  

5) Dentro del file "2_data_loading.sql" El comando "COPY" toma los datos de manera eficiente y los inyecta directamente en las tablas. El "FROM" indica la ruta absoluta, por lo que es vital que el servidor PostgreSQL tenga permisos de lectura sobre esa ruta. "WITH CSV" le indica al motor que espere el formato estándar de valores separados por comas, "HEADER" indica que ignore la primera fila de cada file CSV, ya que contiene los nombres de las columnas y no datos reales. "DELIMITER "," " confirma que el separador es con comas.

6) En el file "3_data_quality.sql" se hace una auditoría. 
7) Se realiza una auditoría del tipo de dato y el formato (Regex) 