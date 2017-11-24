# PoshSSDTBuildDeploy

```powershell
Import-Module "C:\Users\Richie\Source\Repos\PoshSSDTBuildDeploy\PoshSSDTBuildDeploy" -Force
    $svrConnstring = "SERVER=.\sixteen;Integrated Security=True;Database=master"
    $WWI_OLTP_NAME = "WideWorldImporters"
    $WWI_OLTP = "C:\Users\Richie\Source\Repos\AssistDeploy_WWI_SSIS_Samples\WWI_SSDT\wwi-ssdt"
    $WWI_OLTP_SLN = Join-Path $WWI_OLTP "\WideWorldImporters.sqlproj"
    $WWI_OLTP_DAC = Join-Path $WWI_OLTP "\Microsoft.Data.Tools.Msbuild\lib\net46"
    $WWI_OLTP_DACFX = Join-Path $WWI_OLTP_DAC "\Microsoft.SqlServer.Dac.dll"
    $WWI_OLTP_DACPAC = Join-Path $WWI_OLTP "\bin\Debug\WideWorldImporters.dacpac"
    $WWI_OLTP_PUB = Join-Path $WWI_OLTP "\bin\Debug\WideWorldImporters.publish.xml"


Clear-Host
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI_OLTP
    Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_OLTP_SLN -DataToolsFilePath $WWI_OLTP_DAC 
    Publish-DatabaseDeployment -dacfxPath $WWI_OLTP_DACFX -dacpac $WWI_OLTP_DACPAC -publishXml $WWI_OLTP_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_OLTP_NAME
```powershell