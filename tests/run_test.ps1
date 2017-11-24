Clear-Host
$lldb = Join-Path $PSScriptRoot "launch_localdb.bat"
$installVs2017BuildTools = Start-Process -FilePath $lldb -WorkingDirectory "C:\WINDOWS\System32" -Wait -PassThru  -NoNewWindow
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force
$svrConnstring = "SERVER=(LocalDB)\TestDeploy;Integrated Security=True;Database=master"
$WWI_NAME = "WideWorldImporters"
$WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
$WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
$WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
$WWI_DACFX = Join-Path $WWI_DAC "\Microsoft.SqlServer.Dac.dll"
$WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
$WWI_PUB = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.publish.xml"
Install-VsBuildTools2017
Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI
Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC 
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME