
[cmdletbinding()]
param (
    [parameter(Mandatory = $true)] $WorkingFolder,
    [parameter(Mandatory = $false)] $serverName,
    [parameter(Mandatory = $false)] [string] $sqlAdministratorLogin,
    [parameter(Mandatory = $false)] [String] $sqlAdministratorLoginPassword,
    [parameter(Mandatory = $false)] [String] $connectionString,
    [parameter(Mandatory = $true)] [string] $DatabaseName,
    [parameter(Mandatory = $true)] [string] $DacpacPath,
    [parameter(Mandatory = $true)] [string] $PublishProfile,
    [parameter(Mandatory = $true)] [string] $ModulePath
)

if ($PSBoundParameters.ContainsKey('connectionString') -eq $false) {
    if ($PSBoundParameters.ContainsKey('sqlAdministratorLogin') -eq $true) {
        Write-Host "Using SQL Login to deploy"
        [string] $connectionString = "Server=$($serverName);Initial Catalog=$($DatabaseName);Persist Security Info=False;User ID=$($sqlAdministratorLogin);Password=$($sqlAdministratorLoginPassword);MultipleActiveResultSets=False;TrustServerCertificate=True;Connection Timeout=30;"
    }
    else {
        Write-Host "Using Integrated Security to deploy"
        [string] $connectionString = "integrated security=True;data source=$($serverName);initial catalog=$($DatabaseName);TrustServerCertificate=True;Connection Timeout=30;"
    }
}

Import-Module $ModulePath -Force

$dacFxFolder = Install-MicrosoftSqlServerDacFxx64 -WorkingFolder $WorkingFolder 

$dacFX = Join-Path -Path $dacFxFolder -ChildPath "\Microsoft.SqlServer.Dac.dll"
$deployScripts = New-Item -ItemType Directory -Force -Path "$WorkingFolder\deployScripts"

$PublishParams = @{
    dacfxPath                = $dacFX
    dacpac                   = (Resolve-Path $DacpacPath)
    publishXml               = (Resolve-Path $PublishProfile)
    targetConnectionString   = $connectionString
    targetDatabaseName       = $databaseName
    scriptPath               = $deployScripts
    GenerateDeploymentReport = $false
    GenerateDeploymentScript = $false
}
if ($PSBoundParameters.ContainsKey('getSqlCmdVars') -eq $true) {
    $PublishParams.Add("GetSqlCmdVars", $true)
}
Publish-DatabaseDeployment  @PublishParams

