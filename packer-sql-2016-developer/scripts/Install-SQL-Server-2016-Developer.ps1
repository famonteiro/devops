$sql_server_edition = "MSSQL - Server Express Edition with Advanced services 2016"

#Installs SQL Server locally with standard settings for Developers/Testers.
# Install SQL from command line help - https://msdn.microsoft.com/en-us/library/ms144259.aspx
$sw = [Diagnostics.Stopwatch]::StartNew()
$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
$SqlServerIsoImagePath = "C:\Windows\Temp\en_sql_server_2016_developer_x64_dvd_8777069.iso"

#Mount the installation media, and change to the mounted Drive.
$mountVolume = Mount-DiskImage -ImagePath $SqlServerIsoImagePath -PassThru
$driveLetter = ($mountVolume | Get-Volume).DriveLetter
$drivePath = $driveLetter + ":"
push-location -path "$drivePath"

Try {
	$p = Start-Process $drivePath\SETUP.exe -ArgumentList "/ConfigurationFile=C:\Users\vagrant\ConfigurationFile.ini /IAcceptSQLServerLicenseTerms" -PassThru -Wait 
	if( $p.ExitCode -ne 0 ) {
		throw "$_ exited with status code $($p.ExitCode)"
	}

	# Check If Required Services Are Running
	$arrService = Get-Service -Name "MSSQLSERVER"
	$sqlBrowserService = Get-Service -Name "SQL Server Browser"

	# The Database Engine Service is Mandatory and Must be Running to Proceed
	if ( $arrService.Status -ne "Running" ){
		throw "The required service is not running. Please check your SQL SERVER installation."
	}

	if ( $sqlBrowserService.Status -ne "Running" ) {
		# Enable SQL Browser
		Set-Service SQLBrowser -StartupType Automatic
		Start-Service "SQL Server Browser"
	}

	# Add DB1\vagrant user to SQL sysadmin so that scripts can get executed
	Invoke-Sqlcmd -Username 'sa' -Password 'Qwerty1!' -OutputSqlErrors $TRUE -Query "sp_addsrvrolemember 'DB1\vagrant', 'sysadmin'"
	Invoke-Sqlcmd -Username 'sa' -Password 'Qwerty1!' -OutputSqlErrors $TRUE -Query "sp_addsrvrolemember 'DB1\Administrator', 'sysadmin'"

	$ErrorActionPreference = "Stop"

	## Import the SQL Server Module.
	# https://msdn.microsoft.com/en-us/library/hh231286.aspx
	Import-Module "sqlps" -DisableNameChecking
	Get-Module -ListAvailable -Name Sqlps;
	
	$srv = new-object 'Microsoft.SqlServer.Management.Smo.Server' .
	if( $srv.Configuration ) {
		$CLR = $srv.Configuration.IsSqlClrEnabled
		$CLR.ConfigValue = $true
		$srv.Configuration.alter()
	}

	# http://www.dbi-services.com/index.php/blog/entry/sql-server-2012-configuring-your-tcp-port-via-powershell
	# Set the port
	$smo = 'Microsoft.SqlServer.Management.Smo.'
	$wmi = new-object ($smo + 'Wmi.ManagedComputer')
	$uri = "ManagedComputer[@Name='DB1']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"
	$Tcp = $wmi.GetSmoObject($uri)
	$Tcp.IsEnabled = $true
	$wmi.GetSmoObject($uri + "/IPAddress[@Name='IPAll']").IPAddressProperties[1].Value="1433"
	$Tcp.alter()
	
	# Restart service so that configurations are applied
	Restart-Service -f "SQL Server (MSSQLSERVER)"


} Catch {
	#Write-Error $_.Exception | Format-List -Force
} Finally {
	# Clean Up

}

#Dismount the installation media.
pop-location
Dismount-DiskImage -ImagePath $SqlServerIsoImagePath

#print Time taken to execute
$sw.Stop()
"Sql install script completed in {0:c}" -f $sw.Elapsed;
