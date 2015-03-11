rem uso_referencias
rem argumentos: año, mes 
rem 20140501 aammdd

D:\Taller\script\dms2csv.vbs "ubicacion_equipos.sql"
D:\Taller\script\dms2csv.vbs "horometros.sql"

copy "D:\Taller\resultados\ubicacion_equipos.sql.csv"  "\\tsclient\D\ubicacion_equipos.sql.csv"
copy "D:\Taller\resultados\horometros.sql.csv"  "\\tsclient\D\horometros.sql.csv"