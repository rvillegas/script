rem 1- En este archivo se cambian las fechas de acuerdo 
rem    al rango que queramos actualIZAR.
rem    Fechas son en formato YYYY-DD-MM HH:MM
rem 2- se corre archivo combustible.bat, genera el archivo 
rem    d:\taller\resultados\combustible.sql.csv
rem 3- se copia el archivo al drive de del computador local
rem 4- Se abre la hoja de excel prueba_webservice_v3.xls 
rem    y se oprime el boton "cargar tanqueos dms"
rem    No hay necesidad de copiar el archivo de combustibles 
rem    dentro del excel.


D:\Taller\script\dms2csv.vbs "combustible.sql" "2014-01-01 00:00" "2015-01-01 00:00"
copy "D:\Taller\resultados\combustible.sql.csv"  "\\tsclient\D\combustible.sql.csv"