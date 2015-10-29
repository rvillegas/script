rem Solo corre despues de las 8pm, para evitar que estorbe cuando se abre el rd de dia
echo %time%
set/A year = %Date:~10,4%
set/A month = %Date:~4,2%



rem if %time% LEQ 20:00:00 goto Salir

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


D:\Taller\script\dms2csv.vbs "combustible_srv.sql"

D:\Taller\script\dms2csv.vbs "bodegas.sql" 
copy "D:\Taller\resultados\combustible_srv.sql.csv"  "\\tsclient\D\datos\csv\combustible_srv.sql.csv"
copy "D:\Taller\resultados\bodegas.sql.csv"  "\\tsclient\D\datos\csv\bodegas.sql.csv"

rem D:\Taller\script\dms2csv.vbs "inventario1.sql" "%year%" "%month%"
rem copy "D:\Taller\resultados\inventario1.sql.csv"  "\\tsclient\D\datos\csv\inventario%month%.sql.csv"

D:\Taller\script\dms2csv.vbs "inventario1.sql" 2015 3
copy "D:\Taller\resultados\inventario1.sql.csv"  "\\tsclient\D\datos\csv\inventario3.sql.csv"

D:\Taller\script\dms2csv.vbs "referencias.sql" "1900-01-01 00:00:00"
D:\Taller\script\dms2csv.vbs "uso_referencias.sql" "20090101" "20151212"

copy "D:\Taller\resultados\referencias.sql.csv"  "\\tsclient\D\datos\csv\referencias.sql.csv"
copy "D:\Taller\resultados\uso_referencias.sql.csv"  "\\tsclient\D\datos\csv\uso_referencias.sql.csv"



D:\Taller\script\dms2csv.vbs "pedidos.sql" 
D:\Taller\script\dms2csv.vbs "pedidos_entregados.sql" 
D:\Taller\script\dms2csv.vbs "pedidos_lin.sql" 
copy "D:\Taller\resultados\pedidos.sql.csv"  "\\tsclient\D\datos\csv\pedidos.sql.csv"
copy "D:\Taller\resultados\pedidos_entregados.sql.csv"  "\\tsclient\D\datos\csv\pedidos_entregados.sql.csv"
copy "D:\Taller\resultados\pedidos_lin.sql.csv"  "\\tsclient\D\datos\csv\pedidos_lin.sql.csv"

D:\Taller\script\dms2csv.vbs "horometros.sql"
copy "D:\Taller\resultados\horometros.sql.csv"  "\\tsclient\D\datos\csv\horometros.sql.csv"



shutdown /l
:Salir

rem set/p tt=0