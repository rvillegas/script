sqlcmd -U taller -P taller -S SISTEMAS-PC\SQLEXPRESS -d dbST -Q "DBCC SHRINKDATABASE(N'dbST' )"

xcopy d:\datos\*.* \\Taller_maquipos\!BU\datos_srv\ /s /y
set /p DUMMY=Hit ENTER to continue...