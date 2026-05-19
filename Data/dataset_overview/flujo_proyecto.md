Flujo de trabajo

1) Se crean las carpetas "Data", "PostgreSQL" y "diagramas" donde se cargan los archivos .csv 
[1] "dataset" con los 7 files .csv --> (customers, orders, order_items, order_status_history, order_audit, products, payments) 
[2] "dataset_overview" con el resumen de los archivos, la cantidad de valores y las PKs y FKs --> (dataset_dictionary) 
2) Se añade el archivo "justificación" donde se explica la decisión detrás de la elección de este motor de BD. 
3) Se añade el archivo "dataset_datatypes" con los posibles tipos de datos de cada columna de cada tabla.
4) Se crean los comandos SQL para el staging de datos en el "01_data_staging" 
5) Se crea un file "01.5_data_loading_route" con un ejecutador psql para cargar las tablas Staging que habilita las rutas internas de la PC.
6) Se crean los comandos SQL para el loading de los datos y se realiza un "Truncate Table" y luego las copias de los valores de los datos (de forma rápida) en el "02_data_loading" Si bien se cargaron los valores, los datatypes siguen siendo "TEXT".
7) "03_data_quality" corresponde al file de Auditoría previa a la asignación de Data Types, se sigue el lineamiento de los conceptos de Ingeniería de Datos.
8) 