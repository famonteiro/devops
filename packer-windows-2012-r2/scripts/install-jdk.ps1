$JDK_VER="7u75"
$JDK_FULL_VER="7u75-b13"
$JDK_PATH="1.7.0_75"
$source64 = "http://download.oracle.com/otn-pub/java/jdk/$JDK_FULL_VER/jdk-$JDK_VER-windows-x64.exe"
$destination64 = "G:\Temp\$JDK_VER-x64.exe"
$InstallDestination64 = "G:\jdk1.7.0_79"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
 
 
 
 
 
Write-Host 'Checking if Java is already installed'
if (Test-Path "$InstallDestination64") {
    Write-Host 'No need to Install Java'
    Exit
}

New-Item -ItemType Directory -Force -Path G:\Temp | Out-Null
 
Write-Host 'Downloading x64 to $destination64'
 
$client.downloadFile($source64, $destination64)
if (!(Test-Path $destination64)) {
    Write-Host "Downloading $destination64 failed"
    Exit
}
 
 
try {
    Write-Host 'Installing JDK-x64'
    $proc1 = Start-Process -FilePath "$destination64" -ArgumentList "/s REBOOT=ReallySuppress INSTALLDIR=$InstallDestination64" -Wait -PassThru
    $proc1.waitForExit()
    Write-Host 'Installation Done.'
} catch [exception] {
    write-host '$_ is' $_
    write-host '$_.GetType().FullName is' $_.GetType().FullName
    write-host '$_.Exception is' $_.Exception
    write-host '$_.Exception.GetType().FullName is' $_.Exception.GetType().FullName
    write-host '$_.Exception.Message is' $_.Exception.Message
}
 
if (Test-Path "$InstallDestination64") {
    Write-Host 'Java installed successfully.'
}
Write-Host 'Setting up Path variables.'
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "$InstallDestination64", "Machine")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";$InstallDestination64\bin", "Machine")
Write-Host 'Done. Goodbye.'