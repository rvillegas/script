sqlcmd -U taller -P taller -S SISTEMAS-PC\SQLEXPRESS -d dbST -Q "DBCC SHRINKDATABASE(N'dbST' )"
sqlcmd -U taller -P taller -S SISTEMAS-PC\SQLEXPRESS -i D:\datos\script\backup_dbs.sql
xcopy d:\datos\*.* \\Taller_maquipos\!BU\datos_srv\ /s /y
set /p DUMMY=Hit ENTER to continue...