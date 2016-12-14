# This script downloads the SQL Server Enterprise Edition (2014) ISO, mounts it and installs.
$sqlserver_download_url = "http://care.dlservice.microsoft.com/dl/download/2/F/8/2F8F7165-BB21-4D1E-B5D8-3BD3CE73C77D/SQLServer2014SP1-FullSlipstream-x64-ENU.iso"
#$sqlserver_download_url = "http://172.28.23.224/binaries/msft/SQLServer2014SP1-FullSlipstream-x64-ENU.iso"
$sql_server_iso_location = "C:\Windows\Temp\SQLServer2014SP1-FullSlipstream-x64-ENU.iso"
$sql_server_edition = "MSFT SQL Server Enterprise 2014"

# Download Disk Image
$retrycount = 0
$completed = $false
$args.ErrorAction = "Stop"
while (-not $completed) {
	Try {
		Write-Output "Downloading from $sqlserver_download_url"
		$webclient = new-object System.Net.WebClient
		$webclient.DownloadFile($sqlserver_download_url, $sql_server_iso_location)
		Write-Output "Finish downloading $sql_server_edition"
		$completed = $TRUE
	} Catch {
		if( $retrycount -ge 3 ) {
			throw "Unable to complete the download of $sqlserver_edition"
		}
		$retrycount = $retrycount + 1
		Write-Warning "Retrying url..."
	}
}

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
	# Install
	Write-Output "Attempting installation..." 
	$p = Start-Process $sqlserver_target_location\SETUP.exe -ArgumentList "/ConfigurationFile=a:\ConfigurationFile.ini" -PassThru -Wait 
	
	if( $p.ExitCode -ne 0 ) {
		throw "$_ exited with status code $($p.ExitCode)"
	}
	
	Write-Output "Successfuly installed $sql_server_edition"
	
} Catch {
	Write-Error "Installation of $sql_server_edition failed."
} Finally {
	# Clean Up
	Dismount-DiskImage $sql_server_iso_location
	Remove-Item -Force -ErrorAction SilentlyContinue $sql_server_iso_location
}
