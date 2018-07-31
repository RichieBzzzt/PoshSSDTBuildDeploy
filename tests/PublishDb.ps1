[cmdletbinding()]
param (
	[parameter(Mandatory = $true)] $WorkingFolder,
	[parameter(Mandatory = $false)] $serverName,
	[parameter(Mandatory=$false)] [string] $sqlAdministratorLogin,
	[parameter(Mandatory=$false)] [String] $sqlAdministratorLoginPassword,
	[parameter(Mandatory=$false)] [String] $connectionString,
	[parameter(Mandatory = $true)] [string] $DatabaseName,
	[parameter(Mandatory = $true)] [string] $DacpacPath,
	[parameter(Mandatory = $true)] [string] $PublishProfile,
	[parameter(Mandatory = $false)] [switch] $getSqlCmdVars,
	[parameter(Mandatory = $true)] [string] $deploytag

)

Set-Variable -Name "deploytag" -Value $deploytag -Scope Global

if ($PSBoundParameters.ContainsKey('connectionString') -eq $false) {
[string] $connectionString = "Server=tcp:$($serverName),1433;Initial Catalog=$($DatabaseName);Persist Security Info=False;User ID=$($sqlAdministratorLogin);Password=$($sqlAdministratorLoginPassword);MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}
try {
	Find-Module -Name "PoshSSDTBuildDeploy"
	Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module PoshSSDTBuildDeploy -Force -Scope CurrentUser
}
catch {
	Write-Host "No PoshSSDTBuildDeploy, Installing from PSGallery."
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module PoshSSDTBuildDeploy -Force -Scope CurrentUser
}
finally {
	Write-Host "Importing PoshSSDTBuildDeploy."
	Import-Module PoshSSDTBuildDeploy -Force
}

$dacFxFolder = Install-MicrosoftDataToolsMSBuild -WorkingFolder $WorkingFolder 

$dacFX = Join-Path -Path $dacFxFolder -ChildPath "\Microsoft.SqlServer.Dac.dll"
New-Item -ItemType Directory -Force -Path "$WorkingFolder\deployScripts"

$PublishParams = @{
        dacfxPath                = $dacFX
        dacpac                   = (Resolve-Path $DacpacPath)
        publishXml               = (Resolve-Path $PublishProfile)
		targetConnectionString   = $connectionString
		targetDatabaseName       = $databaseName
		scriptPath				 = $WorkingFolder
		GenerateDeploymentReport = $true
		GenerateDeploymentScript  =$true
	}
	if ($UserName) {
	$PublishParams.Add("SqlCredential", (New-Object System.Management.Automation.PSCredential ($UserName, $Password)))
}

if ($PSBoundParameters.ContainsKey('getSqlCmdVars') -eq $true) {
	$PublishParams.Add("GetSqlCmdVars", $true)
}

	Publish-DatabaseDeployment  @PublishParams