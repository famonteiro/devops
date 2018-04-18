$ErrorActionPreference="Stop"

$sql_server_edition = "MSSQL - Server Developer Edition 2017"

#Installs SQL Server locally with standard settings for Developers/Testers.
# Install SQL from command line help - https://msdn.microsoft.com/en-us/library/ms144259.aspx
$sw = [Diagnostics.Stopwatch]::StartNew()
$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
$SqlServerIsoImagePath = "C:\Windows\Temp\en_sql_server_2017_developer_x64_dvd_11296168.iso"

#Mount the installation media, and change to the mounted Drive.
$mountVolume = Mount-DiskImage -ImagePath $SqlServerIsoImagePath -PassThru
$driveLetter = ($mountVolume | Get-Volume).DriveLetter
$drivePath = $driveLetter + ":"
push-location -path "$drivePath"

Try {
	$p = Start-Process $drivePath\SETUP.exe -ArgumentList "/ConfigurationFile=C:\Windows\Temp\ConfigurationFile.ini /IAcceptSQLServerLicenseTerms" -PassThru -Wait 
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
