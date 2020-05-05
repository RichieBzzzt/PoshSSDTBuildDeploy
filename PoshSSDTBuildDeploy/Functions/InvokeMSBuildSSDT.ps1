

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
Optional - Specify if using version 14 or 15 or 16. Will default to 15 if left blank. Can be installed by using Install-VSBuildTools2017. 
.PARAMETER  MSBuild
Optional - path to MSBuild 
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
        , [string]$msbuild
    )

    if ($PSBoundParameters.ContainsKey('msbuild') -eq $false) {
            
        if ([string]::IsNullOrEmpty($MSBuildVersionNumber)) {
            $MSBuildVersionNumber = "15.0"
        }
        if ($MSBuildVersionNumber -eq "15.0") {
            $filepath = "C:\Program Files (x86)\Microsoft Visual Studio\2017"
            $folders = Get-ChildItem $filepath
            $MsBuildInstalled = 0
            foreach ($folder in $folders) {
                $MsbuildPath = "$($folder.FullName)\MSBuild\15.0\Bin"
                if ((Test-Path $MsbuildPath) -eq $true) {
                    Write-Host "MsBuild found!" -ForegroundColor Green -BackgroundColor Yellow
                    $MsBuild = Join-Path $MsbuildPath "msbuild.exe"
                    $MsBuildInstalled = 1
                    break
                }
            }
            if ($MsBuildInstalled -eq 0) {
                Write-Error "Install Visual Studio Tools 2017 MSBuild Tools to continue!"
                Throw
            }
        }
        else {
            $msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
        }
    }
    if (-not (Test-Path $msbuild)) {
        Write-Error "No MSBuild installed. Either specify correct path or install Build Tools using 'Install-VsBuildTools2017', set -MSBuildVersionNumber to 15.0 and try again!"
        Throw
    }
    $arg1 = "/p:tv=$MSBuildVersionNumber"
    $arg2 = "/p:SSDTPath=$DataToolsFilePath"
    $arg3 = "/p:SQLDBExtensionsRefPath=$DataToolsFilePath"
    $arg4 = "/p:Configuration=Debug"

    Write-Host $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 -ForegroundColor White -BackgroundColor DarkGreen

    & $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 2>&1
}
