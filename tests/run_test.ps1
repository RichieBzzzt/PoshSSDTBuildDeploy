Clear-Host
$lldb = Join-Path $PSScriptRoot "launch_localdb.bat"
#$lcaunchLocalDb = Start-Process -FilePath $lldb -WorkingDirectory "C:\WINDOWS\System32" -Wait -PassThru  -NoNewWindow
#Import-Module "C:\Users\Richie\Downloads\PoshSSDTBuildDeploy\PoshSSDTBuildDeploy" -Force
#ipmo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

#localdb
$loc = $PSScriptRoot
$tv = "13.1.4001.0"
#either/or 
$msi = Get-LocalDb2016 -WorkingFolder $loc -targetVersion $tv -Verbose
$msi = Get-LocalDb2016NuGet -WorkingFolder $loc -targetVersion $tv -Verbose
#then pass msi here
Install-LocalDb2016 -LocalDbMsiPath $msi -targetVersion $tv
break

#ssdt - set up vars
$svrConnstring = "SERVER=(LocalDB)\TestDeploy;Integrated Security=True;Database=master"
$WWI_NAME = "WideWorldImporters"
$WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
$WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
$WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
$WWI_DACFX = Join-Path $WWI_DAC "\Microsoft.SqlServer.Dac.dll"
$WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
$WWI_PUB = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.publish.xml"

#setup dependencies for build
Install-VsBuildTools2017
#get datatoolsmsbuild
Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI
#build
Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC 
#deploy
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME