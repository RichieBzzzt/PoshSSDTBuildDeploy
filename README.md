# PoshSSDTBuildDeploy

PowerShell Module designed to make use of [Microsoft.Data.Tools.MSBuild](https://www.nuget.org/packages/Microsoft.Data.Tools.Msbuild/).

## Build Status

### CI Build
[<img src="https://bzzztio.visualstudio.com/_apis/public/build/definitions/e986a19c-74f7-4d1f-8316-7f478f3d6646/5/badge"/>](https://bzzztio.visualstudio.com/PoshSSDTBuildDeploy/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=5)

### Publish Build
[<img src="https://bzzztio.visualstudio.com/_apis/public/build/definitions/e986a19c-74f7-4d1f-8316-7f478f3d6646/20/badge"/>](https://bzzztio.visualstudio.com/PoshSSDTBuildDeploy/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=20)

## Latest Releases
[NuGet](https://www.nuget.org/packages/PoshSSDTBuildDeploy/)

[PowerShellGallery](https://www.powershellgallery.com/packages/PoshSSDTBuildDeploy)


## How To's
To test all the scripts locally 
```
C:\..\PoshSSDTBuildDeploy> cd tests
C:\..\PoshSSDTBuildDeploy\tests> .\Invoke-Tests.ps1

Executing all tests in '.\*.Tests.ps1'

Executing script C:\projects\PoshSSDTBuildDeploy\tests\Install-MicrosoftDataToolsMSBuild.Tests.ps1

  Describing Install-MicrosoftDataToolsMSBuild
    [+] should install MicrosoftDataToolsMSBuild 10.0.61026 91ms
  ...
  ...
  ...
  Describing Publish-DatabaseDeployment
    [+] throws exception if not at least one of GenerateDeploymentScript or GenerateDeploymentReport is true when using ScriptOnly 73ms
    [+] throws exception if Script Path is Invalid 55ms
Tests completed in 36.66s
Tests Passed: 12, Failed: 0, Skipped: 0, Pending: 0, Inconclusive: 0
```
Consult the `/tests/*.Tests.ps1` files in the repo for samples of how to use this module to build and deploy.

Each Function should have it's own helping headers... eventually. Currently only the ones that pertain to LocalDB install do.

The basic process is 

* Set up variables to build and deploy
* Check if VS Build Tools 2017 is Installed and Install if not
* Install Microsoft.Data.Tools.MSBuild. 
* Build sqlproj file
* Deploy DACPAC

### How To Install Prerequisites?

#### LocalDB
Use either [Get-LocalDb2016](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/GetLocalDb2016.ps1) or [Get-LocalSB2016NuGet](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/GetLocalDb2016NuGet.ps1) to download the LocalDB MSI to a working folder. Then pas MSI when executing [Install-LocalDB2016](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/InstallLocalDb2016.ps1).

All of these functions can be re-run, so if MSI already downloaded or LocalDB already installed then it won't re-try. 

This test script includes a step to create a localdb instance to deploy to. Therefore this test script shouldrun without having to set up anything else.

#### MSBuild Tools
Use [Install-VsBuildTools2017](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/InstallVsBuildTools2017.ps1) to check if latest MSBuild Tools is installed. If not then function will download and install. Elevated permissions are required!

### How To Build SSDT Project
Use [Invoke-MsBuildSSDT](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/InvokeMSBuildSSDT.ps1), passing in the file path to the solution or the project. The path to Data.Tools.MSBuild is also required - 
```powershell
$WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
$WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
$WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI
Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC 
```
The above sample set the path to the directroy where the sqlproj file is, and also used this as the working directory to download the NuGet package. This means the dlls etc were local to the project. 

### How To Publish DACPAC
Use [Publish-DatabaseDeployment](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/PublishDatabaseDeployment.ps1), passsing in the location to the dac dll, the location of the dac dll, the publish file and the dacpac.

As of version 2, there are four new options on the function - 
* -GenerateDeploymentScript - boolean - determines whether Deployment Script is generated.
* -GenerateDeployMentReport - boolean - determines whether Deployment Report is generated.
* -ScriptPath - string - fodler path where the scriptsa re goingto be created.
* -ScriptOnly (optional, see **How To Only Script Changes Instaead of Deploying?** for more info)
```powershell
$WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
$WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
$WWI_DACFX = Join-Path $WWI_DAC "\Microsoft.SqlServer.Dac.dll"
$WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
$WWI_PUB = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.publish.xml"

#deploy
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI #-getSqlCmdVars

Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath $WWI #-getSqlCmdVars

Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath $WWI #-getSqlCmdVars

Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath $WWI #-getSqlCmdVars

#script only
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars

Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $true -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars

Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeployMentReport $true -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars
#should fail
#Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly #-getSqlCmdVars

```
Above example again sets the location of the source folder and creates the relative paths.

### How To Update SQLCMDVars in a Publish.XML File
If you have SqlCmdVariables that need updating, you can do this by including the 'getSqlCmdVars' switch when executing the [Publish-DatabaseDeployment](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/PublishDatabaseDeployment.ps1) Function. 
By adding this swtich the function [Get-SqlCmdVars](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/Functions/GetSqlCmdVars.ps1) is executed. This will attempt to resolve SQLCmd variables via matching powershell variables explicitly defined in the current context.
So in the [publish.xml](https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/tests/wwi-dw-ssdt/WideWorldImportersDW.publish.xml) file there is a SqlCmdVariable called  "DeployTag" with a value of "OldValue". If I want to overwrite this then you will need a PowerShell variable ```$DeployTag``` with a new value. if a variable is not found with this value then it will fail if the Switch ```FailOnMissingVars``` is included. If there are any missing vars and this switch is not included it will simply write an info message and move on. My post on my blog shows how to [Update XML With PowerShell With Elements](https://bzzzt.io/2017/10/31/updating-xml-with-powershell-now-including-elements/).
```powershell
$DeployTag = "NewValue"
Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME #-getSqlCmdVars
```

### How To Only Script Changes Instaead of Deploying?

Use the ```-ScriptOnly``` Flag on Publish-DatabaseDeployment. For this to work either ```-GenerateDeployMentReport``` or ```-GenerateDeploymentScript``` must be set to ```$true``` as well as ```-ScriptPath```

### Making Use Of GenerateDeployMentReport

If the GenerateDeployMentReport Switch is included, the Publish function will run ```Get-OperationSummary``` and ```Get-OperationTotal``` functions and output the changes to the console in the form of pscustomobjects. It is now easier to determine what changes are going to be made. IE in the case below we are creating and dropping a few objects - 

![DeployReportinfoWithWarnings](img\\DeployReportAlertsAndSummariesJoined.PNG)
