Import-Module ServerManager;

$WindowsVersion = [environment]::OSVersion.Version

If ($WindowsVersion.Major -eq 10) {
    Add-WindowsFeature Net-Framework-45-Core;
}
