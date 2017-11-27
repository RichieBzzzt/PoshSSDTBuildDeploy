Function Get-LocalDb2016NuGet {
    <#
.SYNOPSIS
Get Microsoft SQL Server 2016 LocalDB from Nuget.
.DESCRIPTION
Downloads Microsoft SQL Server 2016 LocalDB from Nuget. This Nuget package is not official release from Microsoft.
Before we use Nuget, we use the function "Install-Nuget" to check is Nuget is installed in local folder.
.PARAMETER WorkingFolder
Location that Nuget.exe is/isn't.
Location that we want to download Nuget package to.
Mandatory
.PARAMETER  NugetInstalluri
The url used to download Nuget.
mandatory 
.PARAMETER targetVersion
The version of the Nuget package we want to get.
Not mandatory - will download the latest if not included.
.INPUTS
N/A
.OUTPUTS
targetMsi: the path to  Microsoft SQL Server 2016 LocalDB msi, irrespective of whether it was downloaded or already existed.
.EXAMPLE
$targetMsi = Get-LocalDb2016NuGet -WorkingFolder $PsScriptRoot -NugetInstallUri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -targetVersion "13.1.4001.0" 
.NOTES
  N/A
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $WorkingFolder,
        [Parameter(Mandatory = $true)]
        [string] $NugetInstallUri,
        [Parameter(Mandatory = $false)]
        [string] $targetVersion
    )
    $NuGetPath = Install-NuGet -WorkingFolder $WorkingFolder -NuGetInstallUri $NugetInstallUri
    
    $nugetInstallLocalDb = "&$NuGetPath install Microsoft.SQL.Server.2016.LocalDB -ExcludeVersion -OutputDirectory $WorkingFolder"

    if ($targetVersion) {
        $nugetInstallLocalDb += " -version $targetVersion"
    }
    else {
        Write-Verbose "As no version target version of Microsoft SQL Server 2016 LocalDB, the latest version will be downloaded." -Verbose
    }
    Write-Verbose $nugetInstallLocalDb -Verbose
    Invoke-Expression $nugetInstallLocalDb | Out-Null
    $localDbInstallFolder = "$WorkingFolder\Microsoft.SQL.Server.2016.LocalDB"
    if (-not (Test-Path $localDbInstallFolder)) {
        Throw "It appears that the nuget install hasn't worked, check output above to see whats going on"
    }
    $targetMsi = Join-Path $localDbInstallFolder "SqlLocalDB.msi"
    Return $targetMsi
}
