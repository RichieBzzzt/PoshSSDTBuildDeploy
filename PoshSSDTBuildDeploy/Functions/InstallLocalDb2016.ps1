Function Install-LocalDb2016 {
    <#
.SYNOPSIS
Install Microsoft SQL Server 2016 LocalDB on machine.
.DESCRIPTION
Checks to see if Microsoft SQL Server 2016 LocalDB is installed. If not will install.
If installed, will check version installed, and if it is less than the version we want to install, will install it.
.PARAMETER LocalDbMsiPath
Location of Microsoft SQL Server 2016 LocalDB msi.
Mandatory
.PARAMETER  targetVersion
The version we want to install. 
mandatory 
.INPUTS
N/A
.OUTPUTS
N/A
.EXAMPLE
$tv = "13.1.4001.0"
$NugetUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$localDB = "https://download.microsoft.com/download/9/0/7/907AD35F-9F9C-43A5-9789-52470555DB90/ENU/asdf/SqlLocalDB.msi"

$msi = Get-LocalDb2016 -WorkingFolder $PSScriptRoot -downloadLocalDbUri $localDB -targetVersion $tv -checkNuget -NugetInstallUri $NugetUri -Verbose
Install-LocalDb2016 -LocalDbMsiPath $msi -targetVersion $tv 
.NOTES
  N/A
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $LocalDbMsiPath,
        [Parameter(Mandatory = $true)]
        [string] $targetVersion
    )
    
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13E.LOCALDB\MSSQLServer\CurrentVersion"
    if ( -not (Test-Path $registryPath)) {
        Write-Verbose "Microsoft SQL Server 2016 LocalDB not installed." -Verbose
        $install = $true
    }
    else {
        $registryProperties = Get-ItemProperty $registryPath 
        $sourceVersion = $registryProperties.CurrentVersion
        if ($sourceVersion -lt $targetVersion) {
            Write-Verbose "Microsoft SQL Server 2016 LocalDB requires upgrading." -Verbose
            $install = $true
        }
    }
    if ($install -eq $true) {
        try {
            $msi = Get-LocalDb2016 -WorkingFolder $LocalDbMsiPath -targetVersion $tv
            Write-Verbose "Installing Microsoft SQL Server 2016 LocalDB..." -Verbose
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $msi /q IACCEPTSQLLOCALDBLICENSETERMS=YES" -Wait | Out-Null
        }
        catch {
            Throw "It appears LocalDB has not installed properly."
        }
        if ( -not (Test-Path $registryPath)) {
            Write-Verbose "It appears that LocalDB has not installed." -Verbose
        }
        else {
            Write-Verbose "SQL Server LocalDB Installed Successfully." -Verbose
        }
    }
    else {
        Write-Verbose "Microsoft SQL Server 2016 LocalDB already Installed." -Verbose
    }
}
