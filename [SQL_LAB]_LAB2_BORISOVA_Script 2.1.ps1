$QueryDropHR = @'
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'HumanResources'
USE [master]
/****** Object:  Database [HumanResources]    Script Date: 11/10/2018 9:00:23 AM ******/
DROP DATABASE [HumanResources]
'@

$QueryDropIS = @'
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'InternetSales'
USE [master]
ALTER DATABASE [InternetSales] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
USE [master]
/****** Object:  Database [InternetSales]    Script Date: 11/11/2018 5:50:03 AM ******/
DROP DATABASE [InternetSales]
'@

$QueryCreateHR = @'
CREATE DATABASE [HumanResources]
 ON  PRIMARY 
( NAME = N'HumanResources', 
  FILENAME = N'F:\DATA\HumanResources.mdf' , 
  SIZE = 51200KB , 
  FILEGROWTH = 5120KB )
 LOG ON 
(NAME = N'HumanResources_log', 
FILENAME = N'F:\LOGS\HumanResources_log.ldf' , 
SIZE = 5120KB , 
FILEGROWTH = 1024KB )
'@


$QueryCreateIS = @'
CREATE DATABASE [InternetSales]
 ON  PRIMARY 
( NAME = N'InternetSales', 
  FILENAME = N'F:\DATA\InternetSales.mdf' , 
  SIZE = 5120KB , FILEGROWTH = 1024KB ), 
 FILEGROUP [SalesData] 
( NAME = N'InternetSales_data1', 
  FILENAME = N'F:\AdditionalData\InternetSales_data1.ndf' , 
  SIZE = 102400KB , 
  FILEGROWTH = 10240KB ), 
( NAME = N'InternetSales_data2', 
  FILENAME = N'F:\AdditionalData\InternetSales_data2.ndf' , 
  SIZE = 102400KB , 
  FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'InternetSales_log', 
  FILENAME = N'F:\LOGS\InternetSales_log.ldf' , 
  SIZE = 2048KB , 
  FILEGROWTH = 10%)
 
ALTER DATABASE [InternetSales] MODIFY FILEGROUP [SalesData] DEFAULT
'@



#Opening SQL connection
#Check if such databases exist

$DBHR = (Invoke-Sqlcmd -ServerInstance vm1 -Query "select DB_id ('HumanResources')").Column1
$DBIS = (Invoke-Sqlcmd -ServerInstance vm1 -Query "select DB_id ('InternetSales')").Column1

    if (($dbIS -is [int16])){
      $Sw = Read-Host "InternetSales DB exists. Do you want to delete it? [y/n]"
	    Switch ($sw) {
	        y {
               try {
                 Invoke-Sqlcmd -ServerInstance vm1 -query $QueryDropIS
               }
	        catch {[System.Exception]
               Write-Host "Error!"
            }
               finally {
                  Write-Host "InternetSales DB deleted"
               }
	        }
	        n {Write-Host "DB was not deleted"}
        }
    }
        
    if (($dbHR -is [int16])) {
        $Sw1 = Read-Host "HumanResources DB exists. Do you want to delete it? [y/n]"
	    Switch ($sw1) {
            y {
                Write-Host "HumanResources DB exists. Tryng to delete"
                try {
                Invoke-Sqlcmd -ServerInstance vm1 -query $QueryDropHR
                }
                catch {[System.Exception]
                Write-Host "Error!"}
                finally {
                Write-Host "HumanResources DB deleted"
                }
            }
        }
    }

#Create new DBs
Invoke-Sqlcmd -ServerInstance vm1 -query $QueryCreateIS
Invoke-Sqlcmd -ServerInstance vm1 -query $QueryCreateHR
