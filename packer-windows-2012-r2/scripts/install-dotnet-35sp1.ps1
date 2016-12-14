Import-Module servermanager

$dotnet_download_url = "https://download.microsoft.com/download/0/6/1/061F001C-8752-4600-A198-53214C69B51F/dotnetfx35setup.exe"
$dotnet_target = "C:\Windows\Temp\dotnetfx35setup.exe"

# Download Microsoft.NET Framework 3.5 SP1
if( !(Test-Path $dotnet_target)) {
	Write-Output "Downloading $dotnet_download_url..."
	Invoke-WebRequest $dotnet_download_url -OutFile $dotnet_target
}

# Install Microsoft.NET Framework 3.5 SP1
Write-Output "Attempting installation of Microsoft.NET Framework 3.5 SP1..."
Install-WindowsFeature Net-Framework-Core -Source $dotnet_target


# Verify that the Installation Succeeded
#Write-Warning "Verifying that the correct versions have been installed..."

#$list = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
#Get-ItemProperty -name Version,Release -EA 0 |
#Where { $_.PSChildName -match '^(?!S)\p{L}'} |
#Select PSChildName, Version, Release

#$success = $FALSE
#ForEach ( $i in $list ) {
#	if( ($i.Version).StartsWith("3.5") ) {
#		Write-Output "Found $i.Version installed..."
#		$success = $TRUE
#	}  
#}

#if( !( $success ) ) {
#	throw "Microsoft.NET Framework 3.5 SP1 could not be installed."
#}

Write-Output "Microsoft.NET Framework 3.5 SP1 successfully installed."

