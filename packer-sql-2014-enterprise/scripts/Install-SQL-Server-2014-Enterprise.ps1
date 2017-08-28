$sql_server_iso_location = "C:\Windows\Temp\SQLServer2014SP1-FullSlipstream-x64-ENU.iso"

# Mount the Disk Image
Write-Output "Mounting disk image..."
$mountResult = Mount-DiskImage $sql_server_iso_location -PassThru
$driveLetter = ($mountResult | Get-Volume).DriveLetter
Write-Output "Mounted at drive $driveLetter"

# Self-extract Express Packages
Write-Host "Preparing installation..."
$sqlserver_target_location = $driveLetter + ":"
	
# Verify that configuration file is in place
if( !( Test-Path a:\ConfigurationFile.ini )) {
	throw "a:\ConfigurationFile.ini is required and does not exist. Aborting installation..."
}

Try {
	$p = Start-Process $sqlserver_target_location\SETUP.exe -ArgumentList "/ConfigurationFile=a:\ConfigurationFile.ini" -PassThru -Wait 
	
	if( $p.ExitCode -ne 0 ) {
		throw "$_ exited with status code $($p.ExitCode)"
	}
	
} Catch {
	# NOP
} Finally {
	# Clean Up
	Dismount-DiskImage $sql_server_iso_location
	Remove-Item -Force -ErrorAction SilentlyContinue $sql_server_iso_location
}
