USE AdventureWorks;
GO

/*
recovery model to Full
*/
ALTER DATABASE AdventureWorks SET RECOVERY FULL;

-- not working on mac TODO test on windows
/*
Full Backup
*/
BACKUP DATABASE AdventureWorks
TO DISK = 'C:\Backup\AdventureWorks_Full.bak'

/*
Differential Backup
*/
BACKUP DATABASE AdventureWorks
TO DISK = 'C:\Backup\AdventureWorks_Diff.bak' WITH DIFFERENTIAL;

/*
Transaction Log Backup
*/
BACKUP LOG AdventureWorks
TO DISK = 'C:\Backup\AdventureWorks_Log.trn' WITH INIT;

-- The last transaction log backup
BACKUP LOG AdventureWorks
TO DISK = 'C:\Backup\AdventureWorks_LogN.trn' WITH INIT;

/*
for scenario 2
*/
-- TO DISK = 'C:\Backup\AdventureWorks_Log_$(get-date -f yyyyMMdd_HHmmSS).trn' WITH INIT;

GO