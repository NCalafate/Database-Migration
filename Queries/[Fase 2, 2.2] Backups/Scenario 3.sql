/*scenario 3*/

/*
Restore the latest full backup
*/
USE AdventureWorks;

SELECT * INTO Orders.OrderedProducts_Backup FROM Orders.OrderedProducts;

USE master;

RESTORE DATABASE AdventureWorks
FROM DISK = 'C:\Backup\AdventureWorks_Full.bak'
WITH REPLACE;

/*
Apply the latest differential backup
*/

RESTORE DATABASE AdventureWorks
FROM DISK = 'C:\Backup\AdventureWorks_Diff.bak'
WITH NORECOVERY;

/*
Apply transaction log backups up to the point of data loss
*/

RESTORE LOG AdventureWorks
FROM DISK = 'C:\Backup\AdventureWorks_Log.trn'
WITH NORECOVERY;

/*
The last transaction log backup should be restored with RECOVERY
*/
RESTORE LOG AdventureWorks
FROM DISK = 'C:\Backup\AdventureWorks_LogN.trn'
WITH RECOVERY;
