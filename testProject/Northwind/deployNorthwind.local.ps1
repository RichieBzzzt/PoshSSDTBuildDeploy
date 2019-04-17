$instanceName = "poshssdtbuilddeploy"
SqlLocalDB.exe create $instanceName 13.0 -s
SqlLocalDB.exe info $instanceName

$serverInstance = "(localdb)\$instanceName"
$str = "SERVER=$serverInstance;Integrated Security=True;Database=master"

$dacpac = Resolve-Path .\bin\Debug\Northwind.dacpac
$pubFile = Resolve-Path .\bin\Debug\Northwind.publish.xml
$poshSSDTBuildDeploy = Join-Path $PSScriptRoot "..\..\poshssdtbuilddeploy"

.\deployNorthwind.ps1 -WorkingFolder $PSScriptRoot -connectionString $str -DatabaseName "Northwind" -DacpacPath $dacpac -PublishProfile $pubFile -ModulePath $poshSSDTBuildDeploy
