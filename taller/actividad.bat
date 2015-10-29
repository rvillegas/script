rem argumentos: fecha


D:\Taller\script\dms2csv.vbs "flt_actividad_equipos.sql" "2014" "11"
D:\Taller\script\dms2csv.vbs "flt_actividad_equipos_lin.sql" "2014" "11"
D:\Taller\script\dms2csv.vbs "flt_actividad_equipos_consumos.sql" "2014" "11"
D:\Taller\script\dms2csv.vbs "flt_actividad_equipos_inspeccion.sql" "2014" "11"
D:\Taller\script\dms2csv.vbs "flt_equipos_au.sql" "2014" "09"

D:\Taller\script\dms2csv.vbs "tall_operarios.sql" 
D:\Taller\script\dms2csv.vbs "v_equipos.sql"
D:\Taller\script\dms2csv.vbs "conceptos_distribucion.sql"




copy "D:\Taller\resultados\flt_actividad_equipos.sql.csv"  "\\tsclient\D\datos\csv\flt_actividad_equipos.sql.csv"
copy "D:\Taller\resultados\flt_actividad_equipos_lin.sql.csv"  "\\tsclient\D\datos\csv\flt_actividad_equipos_lin.sql.csv"
copy "D:\Taller\resultados\flt_actividad_equipos_consumos.sql.csv"  "\\tsclient\D\datos\csv\flt_actividad_equipos_consumos.sql.csv"
copy "D:\Taller\resultados\flt_actividad_equipos_inspeccion.sql.csv"  "\\tsclient\D\datos\csv\flt_actividad_equipos_inspeccion.sql.csv"
copy "D:\Taller\resultados\flt_equipos_au.sql.csv"  "\\tsclient\D\datos\csv\flt_equipos_au.sql.csv"



copy "D:\Taller\resultados\tall_operarios.sql.csv"  "\\tsclient\D\datos\csv\tall_operarios.sql.csv"
copy "D:\Taller\resultados\v_equipos.sql.csv"  "\\tsclient\D\datos\csv\v_equipos.sql.csv"
copy "D:\Taller\resultados\conceptos_distribucion.sql.csv"  "\\tsclient\D\datos\csv\conceptos_distribucion.sql.csv"

set /p DUMMY=Hit ENTER to continue...