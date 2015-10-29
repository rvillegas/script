set/A year = %Date:~10,4%
set/A month = %Date:~4,2%


D:\Taller\script\dms2csv.vbs "inventario1.sql" "%year%" "%month%"
copy "D:\Taller\resultados\inventario1.sql.csv"  "\\tsclient\D\inventario%month%.sql.csv"

D:\Taller\script\dms2csv.vbs "referencias.sql" "1900-01-01 00:00:00"
D:\Taller\script\dms2csv.vbs "uso_referencias.sql" "20090101" "20151212"

copy "D:\Taller\resultados\referencias.sql.csv"  "\\tsclient\D\referencias.sql.csv"
copy "D:\Taller\resultados\uso_referencias.sql.csv"  "\\tsclient\D\uso_referencias.sql.csv"