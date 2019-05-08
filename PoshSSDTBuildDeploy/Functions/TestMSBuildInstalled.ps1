

function Test-MsBuildInstalled {
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
    param ( [string] $MsbuildPath)

    Write-Host "Searching for MSBuild at $MsbuildPath"
    if ((Test-Path $MsbuildPath) -eq $true) {
        Write-Host "MsBuild found!" -ForegroundColor Green -BackgroundColor Yellow
        $MsBuild = Join-Path $MsbuildPath "msbuild.exe"
        Write-Host $MsBuild -ForegroundColor White -BackgroundColor DarkGreen
        $MsBuild
    }
}

