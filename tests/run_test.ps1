Clear-Host
#$lldb = Join-Path $PSScriptRoot "launch_localdb.bat"
#$lcaunchLocalDb = Start-Process -FilePath $lldb -WorkingDirectory "C:\WINDOWS\System32" -Wait -PassThru  -NoNewWindow
#Import-Module "C:\Users\Richie\Downloads\PoshSSDTBuildDeploy\PoshSSDTBuildDeploy" -Force
#ipmo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

# #localdb
# $loc = $PSScriptRoot
# $tv = "13.1.4001.0"
# #either/or 
# $msi = Get-LocalDb2016 -WorkingFolder $loc -targetVersion $tv -Verbose
# #$msi = Get-LocalDb2016NuGet -WorkingFolder $loc -targetVersion $tv -Verbose
# #then pass msi here
# Install-LocalDb2016 -LocalDbMsiPath $msi -targetVersion $tv

#ssdt - set up vars
$svrConnstring = "SERVER=(localdb)\MSSQLLocalDB;Integrated Security=True;Database=master"
$WWI_NAME = "WideWorldImporters"
$WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
$WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
$WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
$WWI_DACFX = Join-Path $WWI_DAC "\Microsoft.SqlServer.Dac.dll"
$WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
$WWI_PUB = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.publish.xml"

# #setup dependencies for build
# Install-VsBuildTools2017 -WorkingFolder $WWI
# #get datatoolsmsbuild
# Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI 

Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"
# #should fail
try{
Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.60809" -ErrorAction SilentlyContinue
}
catch{
    Write-Host "10.0.60809 not supported as expected"
}
# #build
Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC 
# #deploy
# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath $WWI #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath $WWI #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath $WWI #-getSqlCmdVars

# # # #script only
 Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
 Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
 Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
# #should fail
#Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath "X:\bob" #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath "X:\bob" #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath "X:\bob" #-getSqlCmdVars

# Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath "X:\bob" #-getSqlCmdVars
