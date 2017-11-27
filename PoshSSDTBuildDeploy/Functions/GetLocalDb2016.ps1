Function Get-LocalDb2016 {
    <#
.SYNOPSIS
Get Microsoft SQL Server 2016 LocalDB from Microsoft website.
.DESCRIPTION
Downloads Microsoft SQL Server 2016 LocalDB from Microsoft website. The url was obtained by running Fiddler with https requests on when using SQL Server 2016 Express Installer.
Thisi s becauseMicrosoft have not published the download link anywhere.
.PARAMETER WorkingFolder
Location of where we want to download Microsoft SQL Server 2016 LocalDB msi
Mandatory
.PARAMETER  checkNuget
A switch that can be used to check Nuget for package if the url does not work. See notes for more details. 
.PARAMETER targetVersion
The version of the Nuget package we want to get.
Not mandatory - will download the latest if not included.
.PARAMETER  NugetInstalluri
The url used to download Nuget. 
Not mandatory because we may not want to/be able to use Nuget.
.INPUTS
N/A
.OUTPUTS
targetMsi: the path to  Microsoft SQL Server 2016 LocalDB msi, irrespective of whether it was downloaded or already existed.
.EXAMPLE
$tv = "13.1.4001.0"
$NugetUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$localDB = "https://download.microsoft.com/download/9/0/7/907AD35F-9F9C-43A5-9789-52470555DB90/ENU/SqlLocalDB.msi"

$msi = Get-LocalDb2016 -WorkingFolder $PSScriptroot -downloadLocalDbUri $localDB -targetVersion $tv -checkNuget -NugetInstallUri $NugetUri -Verbose
.NOTES
Because the url from Microsoft is not official, it amy change from time to time, leading current known url invalid.
To anticiapte this we can check Nuget for a version that we can then download.
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $WorkingFolder,
        [Parameter(Mandatory = $false)]
        [string] $targetVersion
    )
    $NugetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    $downloadLocalDbUri = "https://download.microsoft.com/download/9/0/7/907AD35F-9F9C-43A5-9789-52470555DB90/ENU/SqlLocalDB.msi"
    Write-Verbose "Working Folder   : $WorkingFolder" -Verbose
    Write-Verbose "Target Version   : $targetVersion" -Verbose
    $targetMsi = Join-Path $WorkingFolder "Microsoft.SQL.Server.2016.LocalDB"
    if (-not (Test-Path $targetMsi)) {
        New-Item $targetMsi -type directory | Out-Null
    }
    [string]$targetMsi = Join-Path $targetMsi "SqlLocalDB.msi"
    if (-not (Test-Path $targetMsi)) {
        If (($LinkStatus = Test-DownloadUri -uri $downloadLocalDbUri) -ne 200) {
            Write-Verbose "It appears that the download link is no longer working..." -Verbose
            Write-Verbose "Checking Nuget for Microsoft SQL Server 2016 LocalDB msi..."
            $targetMsi = Get-LocalDb2016NuGet -WorkingFolder $WorkingFolder -NugetInstallUri $NugetInstallUri -targetVersion $targetVersion
        }
        Else {
            try {
                Write-Verbose "Downloading Microsoft SQL Server 2016 LocalDB msi..." -Verbose
                Invoke-WebRequest -Uri $downloadLocalDbUri -OutFile $targetMsi -Verbose
            }
            catch {
                Throw $_.Exception
            }      
        }
    }
    Else {
        Write-Verbose "Microsoft SQL Server 2016 LocalDB msi already downloaded." -Verbose
    }
    Return $targetMsi    
}
