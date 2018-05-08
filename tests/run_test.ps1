#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

#create a localdb instance to deploy to...
sqllocaldb.exe create "poshssdtbuilddeploy" 13.0 -s
sqllocaldb.exe info "poshssdtbuilddeploy"

#ssdt - set up vars
$svrConnstring = "SERVER=(localdb)\poshssdtbuilddeploy;Integrated Security=True;Database=master"
$WWI_NAME = "WideWorldImporters"
$WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
$WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
$WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
$WWI_DACFX = Join-Path $WWI_DAC "\Microsoft.SqlServer.Dac.dll"
$WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
$WWI_PUB = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.publish.xml"

# #setup dependencies for build (if required)
# Install-VsBuildTools2017 -WorkingFolder $WWI
# #get datatoolsmsbuild
# Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI 

# should pass
Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"
# should fail
try {
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.60809" 
}
catch {
    Write-Host "10.0.60809 not supported as expected"
}
finally {
    $ErrorActionPreference = $OldErrorActionPreference
}
#build - should pass
Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC 
#deploy
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI #-getSqlCmdVars
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath $WWI #-getSqlCmdVars
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath $WWI #-getSqlCmdVars
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath $WWI #-getSqlCmdVars

#script only
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
# #should fail

try {
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
}
catch {
    Write-Host "negative test 1 passed" -BackgroundColor DarkCyan
}
finally {
    $ErrorActionPreference = $OldErrorActionPreference
}
try {
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath "X:\bob" #-getSqlCmdVars
}
catch {
    Write-Host "negative test 2 passed" -BackgroundColor DarkCyan
}
finally {
    $ErrorActionPreference = $OldErrorActionPreference
}

try {
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath "X:\bob" #-getSqlCmdVars
}
catch {
    Write-Host "negative test 3 passed" -BackgroundColor DarkCyan
}
finally {
    $ErrorActionPreference = $OldErrorActionPreference
}

try {
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath "X:\bob" #-getSqlCmdVars
}
catch {
    Write-Host "negative test 4 passed" -BackgroundColor DarkCyan
}
finally {
    $ErrorActionPreference = $OldErrorActionPreference
}

try {
    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath "X:\bob" #-getSqlCmdVars
}
catch {
    Write-Host "negative test 5 passed" -BackgroundColor DarkCyan
}
finally {
    $ErrorActionPreference = $OldErrorActionPreference
}