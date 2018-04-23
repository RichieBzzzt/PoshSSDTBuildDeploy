

function Install-MicrosoftDataToolsMSBuild {

    param ( [string] $WorkingFolder
        , [string] $DataToolsMsBuildPackageVersion
    )

    if (-Not $WorkingFolder) {
        Throw "Working folder needs to be set. Its blank"
    }
    Write-Verbose "Verbose Folder  (with Verbose) : $WorkingFolder" -Verbose
    Write-Verbose "DataToolsVersion : $DataToolsMsBuildPackageVersion" -Verbose
    Write-Warning "If DataToolsVersion is blank latest will be used"
    $NugetExe = "$WorkingFolder\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Host "Cannot find nuget at path $NugetPath\nuget.exe"
        Write-Host "Downloading Latest copy of NuGet!"
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $NugetExe
    }
    $TestDotNetVersion = Test-NetInstalled -DotNetVersion "4.6.1"
    Write-Host ".NET Version is $($TestDotNetVersion.DotNetVersion), DWORD Value is $($TestDotNetVersion.DWORD) and Required Version is $($TestDotNetVersion.RequiredVersion)" -ForegroundColor White -BackgroundColor DarkMagenta
    if ($TestDotNetVersion.DWORD -le 394254) {
        Throw "Need to install .NET 4.6.1 at least!"
    }
    $nugetInstallMsbuild = "&$NugetExe install Microsoft.Data.Tools.Msbuild -ExcludeVersion -OutputDirectory $WorkingFolder"
    if ($DataToolsMsBuildPackageVersion) {
        if ($DataToolsMsBuildPackageVersion -lt "10.0.61026") {
            Write-Error "Lower versions than 10.0.61026 will NOT work with Publish-DatabaseDeployment. For more information, read the post https://blogs.msdn.microsoft.com/ssdt/2016/10/20/sql-server-data-tools-16-5-release/"
            Throw
        }
        $nugetInstallMsbuild += " -version '$DataToolsMsBuildPackageVersion'"
    }
    Write-Host $nugetInstallMsbuild -BackgroundColor White -ForegroundColor DarkGreen
    Invoke-Expression $nugetInstallMsbuild
    $SSDTMSbuildFolderNet46 = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net46"
    if (-not (Test-Path $SSDTMSbuildFolderNet46)) {
        $SSDTMSbuildFolderNet40 = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net40"
        if (-not (Test-Path $SSDTMSbuildFolderNet40)) {
            Throw "It appears that the nuget install hasn't worked, check output above to see whats going on"
        }
    }
    if (Test-Path $SSDTMSbuildFolderNet46) {
        return $SSDTMSbuildFolderNet46
    }
    elseif (Test-Path $SSDTMSbuildFolderNet40) {
        return $SSDTMSbuildFolderNet40
    }
}