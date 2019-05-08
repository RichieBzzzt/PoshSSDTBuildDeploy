

function Invoke-MsBuildSSDT {
    <#
.SYNOPSIS
Build a datbase project/solution using Microsoft.Data.Tools.MSBuild
.DESCRIPTION
Using MSBUild, the database project/solution is comiled using Microsoft.Data.Tools.MSBuild. This can be downloaded by using Install-MicrosoftDataToolsMSBuild
.PARAMETER DatabaseSolutionFilePath
Mandatory - Filepath to the sln/sqlproj file.
.PARAMETER  DataToolsFilePath
Mandatory - Location of the Micorosft.Data.Tools.MSBuild. Required for SSDTPath and ExtensionsReferences.
.PARAMETER  MSBuildVersionNumber
Optional - Specify if using version 14 or 15. Will default to 15 if left blank. Can be installed by using Install-VSBuildTools2017. 
.INPUTS
N/A
.OUTPUTS
N/A
.EXAMPLE
$sqlproj = $PSSCriptRoot\solution.sln
$workingFolder = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $WorkingFolder
$msBuildDataTools = Join-Path $WorkingFolder "\Microsoft.Data.Tools.Msbuild\lib\net46"
if ((Test-Path $msBuildDataTools) -eq $false) {
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $workingFolder
}
if ((Test-Path $msBuildDataTools) -eq $false) {
    Write-Output "Oh! It looks like MSBuildDataTools did not download."
}

    Invoke-MsBuildSSDT -DatabaseSolutionFilePath $sqlproj -DataToolsFilePath $msBuildDataTools
    if ($LASTEXITCODE -ne 0){
        Throw
    }

.NOTES
  N/A
#>
    param ( [string] $DatabaseSolutionFilePath
        , [string] $DataToolsFilePath
        , [string]$MSBuildVersionNumber
        , [ValidateSet("Professional", "Enterprise", "Community", "BuildTools")][string]$VisualStudioVersion
        , [switch] $ValidatePackageManager
        , [string] $dacPacRootPath
        )

    if ([string]::IsNullOrEmpty($MSBuildVersionNumber)) {
        $MSBuildVersionNumber = "15.0"
    }
    if ($MSBuildVersionNumber -eq "15.0") {
        if ($PSBoundParameters.ContainsKey('VisualStudioVersion') -eq $true) {
            $filepath = Join-Path "C:\Program Files (x86)\Microsoft Visual Studio\2017" $VisualStudioVersion  
            $MsbuildPath = Join-Path $filepath "MSBuild\15.0\Bin"
            $msbuild = Test-MsBuildInstalled -MsbuildPath $msbuildPath
        }
        else {
            $filepath = "C:\Program Files (x86)\Microsoft Visual Studio\2017"
            $folders = Get-ChildItem $filepath
            foreach ($folder in $folders) {
                $MsbuildPath = Join-Path $filepath "$folder\MSBuild\15.0\Bin"
                $msbuild = Test-MsBuildInstalled -MsbuildPath $msbuildPath
            }
        }
    }
    else {
        $msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
    }
    if (-not (Test-Path $msbuild)) {
        Write-Error "No MSBuild installed. Install Build Tools using 'Install-VsBuildTools2017', set -MSBuildVersionNumber to 15.0 and try again!"
        Throw
    }

    if ($PSBoundParameters.ContainsKey('ValidatePackageManager') -eq $true) {
        if ($PSBoundParameters.ContainsKey('VisualStudioVersion') -eq $true) {
            $filepath = Join-Path "C:\Program Files (x86)\Microsoft Visual Studio\2017" $VisualStudioVersion  
        }
        else {
            $filepath = "C:\Program Files (x86)\Microsoft Visual Studio\2017"
        }
        $folders = Get-ChildItem $filepath
        $PackageManagerInstalled = 0
        foreach ($folder in $folders) {
            $packageManagerPath = Join-Path $filepath "$folder\Common7\IDE\CommonExtensions\Microsoft\NuGet"
            if ((Test-Path $packageManagerPath) -eq $true) {
                Write-Host "PackageManager extension found!" -ForegroundColor Green -BackgroundColor Yellow
                Write-Host $packageManagerPath -ForegroundColor White -BackgroundColor DarkCyan
                $PackageManagerInstalled = 1
                break
            }
        }
        if ($PackageManagerInstalled -eq 0) {
            Write-Error "Install Visual Studio Tools 2017 Nuget Package Manager to continue!"
            Throw
        }
    }
    

    $arg1 = "/p:tv=$MSBuildVersionNumber"
    $arg2 = "/p:SSDTPath=$DataToolsFilePath"
    $arg3 = "/p:SQLDBExtensionsRefPath=$DataToolsFilePath"
    $arg4 = "/p:Configuration=Debug"
    if ($PSBoundParameters.ContainsKey('dacPacRootPath') -eq $true) {
        $arg5 = "/p:dacPacRootPath=$dacPacRootPath"
        
        Write-Host $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 $arg5 -ForegroundColor White -BackgroundColor DarkCyan
        & $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 $arg5 2>&1
    }
    else {
        Write-Host $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 -ForegroundColor White -BackgroundColor DarkGreen
        & $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 2>&1
    }
}