

function Install-MicrosoftDataToolsMSBuild {

    param ( [string] $WorkingFolder,
        [String] $NugetPath
        , [string] $DataToolsMsBuildPackageVersion
    )

    if (-Not $WorkingFolder) {
        Throw "Working folder needs to be set. Its blank"
    }
    Write-Verbose "Verbose Folder  (with Verbose) : $WorkingFolder" -Verbose

    Write-Verbose "DataToolsVersion : $DataToolsMsBuildPackageVersion" -Verbose
    Write-Warning "If DataToolsVersion is blank latest will be used"
    $NugetExe = "$NugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Error "Cannot find nuget at path $NugetPath\nuget.exe"
        exit 1
    }

    write-warning "At least .NET Framework 4.6.1 needs to be installed on this machine to use Microsoft.Data.Tools.Msbuild." -verbose

    $nugetInstallMsbuild = "&$NugetExe install Microsoft.Data.Tools.Msbuild -ExcludeVersion -OutputDirectory $WorkingFolder"

    if ($DataToolsMsBuildPackageVersion) {
        $nugetInstallMsbuild += "-version '$DataToolsMsBuildPackageVersion'"
    }
    Write-Host $nugetInstallMsbuild -BackgroundColor White -ForegroundColor DarkGreen
    Invoke-Expression $nugetInstallMsbuild

    $SSDTMSbuildFolder = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net46"
    if (-not (Test-Path $SSDTMSbuildFolder)) {
        $SSDTMSbuildFolder = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net40"
        if (-not (Test-Path $SSDTMSbuildFolder)) {
            Throw "It appears that the nuget install hasn't worked, check output above to see whats going on"
        }
    }
}
