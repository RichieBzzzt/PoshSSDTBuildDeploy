

function Install-MicrosoftDataToolsMSBuild {
    [cmdletbinding()]
    param ( 
        [parameter(Mandatory)]
        [string] $WorkingFolder, 
        [string] $DataToolsMsBuildPackageVersion,
        [string] $NuGetPath
    )

    Write-Verbose "Verbose Folder : $WorkingFolder" -Verbose
    Write-Verbose "DataToolsVersion : $DataToolsMsBuildPackageVersion" -Verbose 
    Write-Warning "If DataToolsVersion is blank latest will be used"
    if ($PSBoundParameters.ContainsKey('NuGetPath') -eq $false) {
        $NuGetExe = Install-NuGet -WorkingFolder $WorkingFolder
    }
    else {
        Write-Verbose "Skipping Nuget download..." -Verbose
        $NuGetExe = Join-Path $NuGetPath "nuget.exe"
    }
    $TestDotNetVersion = Test-NetInstalled -DotNetVersion "4.6.1"
    Write-Host ".NET Version is $($TestDotNetVersion.DotNetVersion), DWORD Value is $($TestDotNetVersion.DWORD) and Required Version is $($TestDotNetVersion.RequiredVersion)" -ForegroundColor White -BackgroundColor DarkMagenta
    if ($TestDotNetVersion.DWORD -le 394254) {
        Throw "Need to install .NET 4.6.1 at least!"
    }
    $nugetArgs = @("install","Microsoft.Data.Tools.Msbuild","-ExcludeVersion","-OutputDirectory",$WorkingFolder)
    if ($DataToolsMsBuildPackageVersion) {
        if ($DataToolsMsBuildPackageVersion -lt "10.0.61026") {
            Throw "Lower versions than 10.0.61026 will NOT work with Publish-DatabaseDeployment. For more information, read the post https://blogs.msdn.microsoft.com/ssdt/2016/10/20/sql-server-data-tools-16-5-release/"            
        }
        $nugetArgs += "-version",$DataToolsMsBuildPackageVersion
    }
    Write-Host $nugetExe ($nugetArgs -join " ") -BackgroundColor White -ForegroundColor DarkGreen
    &$nugetExe $nugetArgs  2>&1
    $SSDTMSbuildFolderNet46 = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net46"
    if (-not (Test-Path $SSDTMSbuildFolderNet46)) {
        $SSDTMSbuildFolderNet40 = "$WorkingFolder\Microsoft.Data.Tools.Msbuild\lib\net40"
        if (-not (Test-Path $SSDTMSbuildFolderNet40)) {
            Throw "It appears that the nuget install hasn't worked, check output above to see whats going on."
        }
    }
    if (Test-Path $SSDTMSbuildFolderNet46) {
        return $SSDTMSbuildFolderNet46
    }
    elseif (Test-Path $SSDTMSbuildFolderNet40) {
        return $SSDTMSbuildFolderNet40
    }
}

