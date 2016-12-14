$app = "apache-tomcat-7.0.65"
$source = "http://mirrors.fe.up.pt/pub/apache/tomcat/tomcat-7/v7.0.65/bin/apache-tomcat-7.0.65.exe"
$destination = "G:\Temp\apache-tomcat-7.0.65.exe"
$InstallDestination = "G:\apache-tomcat-7.0.65"
$client = new-object System.Net.WebClient


 
Write-Host "Checking if $app is already installed"
if (Test-Path "$InstallDestination") {
    Write-Host "No need to Install $app"
    Exit
}

New-Item -ItemType Directory -Force -Path G:\Temp | Out-Null

Write-Host "Downloading to $destination" 
$client.downloadFile($source, $destination)
if (!(Test-Path $destination)) {
    Write-Host "Downloading $destination failed"
    Exit
}
 

try {
    Write-Host "Installing $app"
    $proc1 = Start-Process -FilePath "$destination" -ArgumentList "/S /D=$InstallDestination" -Wait -PassThru
    $proc1.waitForExit()
    Write-Host 'Installation Done.'
} catch [exception] {
    write-host '$_ is' $_
    write-host '$_.GetType().FullName is' $_.GetType().FullName
    write-host '$_.Exception is' $_.Exception
    write-host '$_.Exception.GetType().FullName is' $_.Exception.GetType().FullName
    write-host '$_.Exception.Message is' $_.Exception.Message
}
 
if (Test-Path "$InstallDestination") {
    Write-Host "$app installed successfully."
}

try {
    Write-Host "Setting Tomcat variables"
	$proc1 = Start-Process -FilePath "$InstallDestination\bin\tomcat7.exe" -ArgumentList "//US//Tomcat7  --JvmOptions -Dcatalina.home=$InstallDestination;-Dcatalina.base=$InstallDestination;-Djava.endorsed.dirs=$InstallDestination\endorsed;-Djava.io.tmpdir=$InstallDestination\temp;-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager;-Djava.util.logging.config.file=$InstallDestination\conf\logging.properties;-DHOME_LOG=$InstallDestination\logs"  -Wait -PassThru
    $proc1.waitForExit()
} catch [exception] {
    write-host '$_ is' $_
    write-host '$_.GetType().FullName is' $_.GetType().FullName
    write-host '$_.Exception is' $_.Exception
    write-host '$_.Exception.GetType().FullName is' $_.Exception.GetType().FullName
    write-host '$_.Exception.Message is' $_.Exception.Message
}
Write-Host 'Done. Goodbye.'