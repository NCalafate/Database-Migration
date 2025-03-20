/*
scenario 1
*/

/*
Restore the latest full backup
*/
USE master;
/* 
[1] Restore the latest full backup
*/

RESTORE DATABASE AdventureWorks
FROM DISK = '/var/opt/mssql/data/AdventureWorks/AdventureWorks_Full.bak'
WITH REPLACE, NORECOVERY;

/*
[2] Apply the latest differential backup
*/

RESTORE DATABASE AdventureWorks
FROM DISK = '/var/opt/mssql/data/AdventureWorks/AdventureWorks_Diff.bak'
WITH NORECOVERY;

/*
[3] Apply transaction log backups to the point of failure
*/

RESTORE LOG AdventureWorks
FROM DISK = '/var/opt/mssql/data/AdventureWorks/AdventureWorks_Log.trn'
WITH NORECOVERY;

RESTORE DATABASE AdventureWorks
WITH RECOVERY;
