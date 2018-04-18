$ErrorActionPreference="Stop"

Write-Output "Hello! We'll be configuring SQL Server 2017 Developer Edition for the first time."
Import-module "D:\Program Files (x86)\Microsoft SQL Server\140\Tools\PowerShell\Modules\SQLPS" -DisableNameChecking

## Enable CLR
$srv = New-Object Microsoft.SqlServer.Management.SMO.Server .
$Config = $srv.Configuration
$CLR = $srv.Configuration.IsSqlClrEnabled
$CLR.ConfigValue = $true
$Config.Alter()

Write-host "CLR has been enabled..."

# Load the IntegrationServices Assembly
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices")

# Store the IntegrationServices Assembly namespace to avoid typing it every time
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

Write-Host "Connecting to server ..."

# Create a connection to the server
$sqlConnectionString = "Data Source=localhost;Initial Catalog=master;Integrated Security=SSPI;"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString

# Create the Integration Services object
$integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection

# Provision a new SSIS Catalog
$catalog = New-Object $ISNamespace".Catalog" ($integrationServices, "SSISDB", "P@assword1")
$catalog.Create()
	
Write-Host "SSISDB has successfully been created..."

#Add ssrs proxy windows user
net user ssrs "55r5Pr0xy" /add

Write-Output "Starting Needed Services..."

Write-Warning "Configuring TCP port on Configuration Manager..."

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
Write-Warning "Restarting MSSQLSERVER service... "
Restart-Service -f "SQL Server (MSSQLSERVER)"

# Create a Shortcut to Management Studio 
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\vagrant\Desktop\ManagementStudio.lnk")
$Shortcut.TargetPath = "D:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Ssms.exe"
$Shortcut.Save()

netsh advfirewall firewall add rule name="SQL Instances" dir=in action=allow protocol=TCP localport=1433;