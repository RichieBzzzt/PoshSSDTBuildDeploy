

function Install-MicrosoftDataToolsMSBuild {
     <#
.SYNOPSIS
Install Microsoft.Data.Tools.Msbuild from NuGet
.DESCRIPTION
Installs Microsoft.Data.Tools.Msbuild into a folder path, optionally using NuGet that is already preinstalled.
.PARAMETER WorkingFolder
Mandatory - Location of where NuGet package is to be installed.
.PARAMETER  DataToolsMsBuildPackageVersion
OPtional - The version we want to install. 
.PARAMETER  NuGetPath
Optional - Can use NuGet already installed or leave blank to downloadNuGet from the internet.   
.INPUTS
N/A
.OUTPUTS
Directory of Nuget package.
.EXAMPLE
Example 1) Download latest NuGet package to PSScriptRoot
$workingFolder = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $WorkingFolder
$msBuildDataTools = Join-Path $WorkingFolder "\Microsoft.Data.Tools.Msbuild\lib\net46"
if ((Test-Path $msBuildDataTools) -eq $false) {
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $workingFolder
}
if ((Test-Path $msBuildDataTools) -eq $false) {
    Write-Output "Oh! It looks like MSBuildDataTools did not download."
}
.NOTES
  N/A
#>
    [cmdletbinding()]
    param ( 
        [parameter(Mandatory)]
        [string] $WorkingFolder, 
        [string] $DataToolsMsBuildPackageVersion,
        [string] $NuGetPath
    )
    Write-Verbose "Verbose Folder : $WorkingFolder" -Verbose
    Write-Verbose "DataToolsVersion : $DataToolsMsBuildPackageVersion" -Verbose 
    Write-Warning "If DataToolsVersion is blank latest will be used"
    if ($PSBoundParameters.ContainsKey('NuGetPath') -eq $false) {
        $NuGetExe = Install-NuGet -WorkingFolder $WorkingFolder
    }
    else {
        Write-Verbose "Skipping Nuget download..." -Verbose
        $NuGetExe = Join-Path $NuGetPath "nuget.exe"
        if (-not (Test-Path $($NuGetExe))) {
            Throw "NuGetpath specified, but nuget exe does not exist!"
        }
    }
    $TestDotNetVersion = Test-NetInstalled -DotNetVersion "4.6.1"
    Write-Host ".NET Version is $($TestDotNetVersion.DotNetVersion), DWORD Value is $($TestDotNetVersion.DWORD) and Required Version is $($TestDotNetVersion.RequiredVersion)" -ForegroundColor White -BackgroundColor DarkMagenta
    if ($TestDotNetVersion.DWORD -le 394254) {
        Throw "Need to install .NET 4.6.1 at least!"
    }
    $nugetArgs = @("install","Microsoft.Data.Tools.Msbuild","-ExcludeVersion","-OutputDirectory",$WorkingFolder)
    if ($DataToolsMsBuildPackageVersion) {
        if ($DataToolsMsBuildPackageVersion -lt "10.0.61026") {
            Throw "Lower versions than 10.0.61026 will NOT work with Publish-DatabaseDeployment. For more information, read the post https://blogs.msdn.microsoft.com/ssdt/2016/10/20/sql-server-data-tools-16-5-release/"            
        }
        $nugetArgs += "-version",$DataToolsMsBuildPackageVersion
    }
    Write-Host $nugetExe ($nugetArgs -join " ") -BackgroundColor White -ForegroundColor DarkGreen
    &$nugetExe $nugetArgs  2>&1 | Out-Host
    $SSDTMSbuildFolderNet46 = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net46"
    if (-not (Test-Path $SSDTMSbuildFolderNet46)) {
        $SSDTMSbuildFolderNet40 = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net40"
        if (-not (Test-Path $SSDTMSbuildFolderNet40)) {
            Throw "It appears that the nuget install hasn't worked, check output above to see whats going on."
        }
    }
    if (Test-Path $SSDTMSbuildFolderNet46) {
        return $SSDTMSbuildFolderNet46
    }
    elseif (Test-Path $SSDTMSbuildFolderNet40) {
        return $SSDTMSbuildFolderNet40
    }
}

