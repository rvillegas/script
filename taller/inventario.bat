rem argumentos: año, mes 


D:\Taller\script\dms2csv.vbs "inventario.sql" "2014" "5"
D:\Taller\script\dms2csv.vbs "referencias.sql" "1900-01-01 00:00:00"
D:\Taller\script\dms2csv.vbs "uso_referencias.sql" "20090101" "20141212"

copy "D:\Taller\resultados\inventario.sql.csv"  "\\tsclient\D\inventario.sql.csv"
copy "D:\Taller\resultados\referencias.sql.csv"  "\\tsclient\D\referencias.sql.csv"
copy "D:\Taller\resultados\uso_referencias.sql.csv"  "\\tsclient\D\uso_referencias.sql.csv"