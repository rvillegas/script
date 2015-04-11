sqlcmd -U taller -P taller -S SISTEMAS-PC\SQLEXPRESS -d dbST -Q "DBCC SHRINKDATABASE(N'dbST' )"
sqlcmd -U taller -P taller -S SISTEMAS-PC\SQLEXPRESS -i D:\datos\script\backup_dbs.sql
