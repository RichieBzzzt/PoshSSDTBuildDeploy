
Param(
    [string] $databaseName = 'Northwind',
    [string] $dataBaseProjectFileName = 'Northwind.sqlproj',
    [string] $msBuild = "C:\Program Files (x86)\MSBuild\16.0\Bin\MSBuild.exe"
)

$poshSSDTBuildDeploy = Join-Path $PSScriptRoot "..\..\poshssdtbuilddeploy"
$poshSSDTBuildDeploy = Resolve-Path $poshSSDTBuildDeploy
Import-Module $poshSSDTBuildDeploy -Force

Write-Host "Build $databaseName Database" -ForegroundColor DarkGreen -BackgroundColor White
$sqlproj = Join-Path $PSScriptRoot "$dataBaseProjectFileName"
$workingFolder = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $WorkingFolder
$msBuildDataTools = Join-Path $WorkingFolder "\Microsoft.Data.Tools.Msbuild\lib\net46"
if ((Test-Path $msBuildDataTools) -eq $false) {
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $workingFolder
}
if ((Test-Path $msBuildDataTools) -eq $false) {
    Write-Output "Oh! It looks like MSBuildDataTools did not download."
}

    Invoke-MsBuildSSDT -DatabaseSolutionFilePath $sqlproj -DataToolsFilePath $msBuildDataTools -msBuild $msBuild
    if ($LASTEXITCODE -ne 0){
        Throw
    }

$nwdacpac = Join-Path $PSScriptRoot "\bin\Debug\$databaseName.dacpac"

if ((Test-Path $nwdacpac) -ne $true) {
    Write-Host "$databaseName dacpac not found, checking release folder..." -ForegroundColor Black -BackgroundColor Red
    $nwdacpac = Join-Path $PSScriptRoot "\bin\Release\$databaseName.dacpac"
    if ((Test-Path $nwdacpac) -ne $true) {
        Write-Error "$databaseName Dacpac not found in bin directories!"
        Throw
    }
}
