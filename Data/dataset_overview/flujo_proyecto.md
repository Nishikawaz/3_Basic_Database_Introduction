Flujo de trabajo

1) Se crean las carpetas "Data", "PostgreSQL" y "diagramas" donde se cargan los archivos .csv 
[1] "dataset" con los 7 files .csv --> (customers, orders, order_items, order_status_history, order_audit, products, payments) 
[2] "dataset_overview" con el resumen de los archivos, la cantidad de valores y las PKs y FKs --> (dataset_dictionary) 
2) Se añade el archivo "justificación" donde se explica la decisión detrás de la elección de este motor de BD. 
3) Se añade el archivo "dataset_datatypes" con los posibles tipos de datos de cada columna de cada tabla.
4) Se crean los comandos SQL para el staging de datos en el "01_data_staging" 
5) 