
DBCC SHRINKDATABASE(N'analisisInventarios' )
BACKUP DATABASE [analisisInventarios] TO  DISK = N'G:\analisisInventario.bak' WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  NAME = N'analisisInventarios-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10

DBCC SHRINKDATABASE(N'dbST' )
BACKUP DATABASE [dbST] TO  DISK = N'G:\dbST.bak' WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  NAME = N'dbST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10

