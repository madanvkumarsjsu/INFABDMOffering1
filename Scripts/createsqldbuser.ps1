Param(
  [string]$dbUserName,
  [string]$dbPassword
)

netsh advfirewall firewall add rule name="Informatica_PC_MMSQL" dir=in action=allow profile=any localport=1433 protocol=TCP

mkdir -Path C:\Informatica\Archive\scripts

$dateAndTime = Get-Date
echo "$dateAndTime Arguments recieved: $dbUserName and $dbPassword" | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log

$connectionString = "Data Source=localhost;Integrated Security=true;Initial Catalog=model;Connect Timeout=3;"
$sqlConn = new-object ("Data.SqlClient.SqlConnection") $connectionString
$sqlConn.Open()

$tryCount = 0
while($sqlConn.State -ne "Open" -And $tryCount -lt 100)
{
    $dateAndTime = Get-Date
    echo "$dateAndTime Attempt $tryCount" | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log

	Start-Sleep -s 30
	$sqlConn.Open()
	$tryCount = $tryCount + 1
}

if ($sqlConn.State -eq 'Open')
{
	$sqlConn.Close();
	echo "Connection to MSSQL Server succeed." | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log
}
else
{
    echo "Connection to MSSQL Server failed." | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log
    exit 255
}

$newLoginQuery = "CREATE LOGIN " + $dbUserName +  " WITH PASSWORD = '" + $dbPassword + "'"
$newUserQuery = "CREATE USER " + $dbUserName + " FOR LOGIN " + $dbUserName + " WITH DEFAULT_SCHEMA = " + $dbUserName
$updateUserRoleQuery = "ALTER ROLE db_datareader ADD MEMBER " + $dbUserName + ";" + 
                        "ALTER ROLE db_datawriter ADD MEMBER " + $dbUserName + ";" + 
                        "ALTER ROLE db_ddladmin ADD MEMBER " + $dbUserName
$newSchemaQuery = "CREATE SCHEMA " + $dbUserName + " AUTHORIZATION " + $dbUserName

Invoke-Sqlcmd -ServerInstance '(local)' -Database 'Model' -Query $newLoginQuery | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log
Invoke-Sqlcmd -ServerInstance '(local)' -Database 'Model' -Query $newUserQuery | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log
Invoke-Sqlcmd -ServerInstance '(local)' -Database 'Model' -Query $updateUserRoleQuery | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log
Invoke-Sqlcmd -ServerInstance '(local)' -Database 'Model' -Query $newSchemaQuery | Out-File -Append C:\Informatica\Archive\scripts\createdbusers.log