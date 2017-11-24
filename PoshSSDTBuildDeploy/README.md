# PoshSSDTBuildDeploy

Initial uplaod of build and deploy using PowerShell and Microsoft.FData.Tools.MSBuild. See test folder for tests.

## Build Status
[<img src="https://bzzztio.visualstudio.com/_apis/public/build/definitions/e986a19c-74f7-4d1f-8316-7f478f3d6646/5/badge"/>](https://bzzztio.visualstudio.com/PoshSSDTBuildDeploy/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=5)

## Latest Releases
[NuGet](https://www.nuget.org/packages/PoshSSDTBuildDeploy/)

[PowerShellGallery](https://www.powershellgallery.com/packages/PoshSSDTBuildDeploy)


## How To 
Consult the [https://github.com/RichieBzzzt/PoshSSDTBuildDeploy/blob/master/PoshSSDTBuildDeploy/test/run_test.ps1] (Test Script) in the repo for a sample of how to use this module to build and deploy.

Each Function should have it's own helping headers... eventually.

The basic process is 

* Set up variables to build and deploy
* Check if VS Build Tools 2017 is Installed and INstall if not
* Install Microsoft.Data.Tools.MSBuild. 
* Build sqlproj file
* Deploy DACPAC

This teest script includes a step to create a localdb instance to deploy to. Therefore this test script shouldrun without having to set up anything else.

