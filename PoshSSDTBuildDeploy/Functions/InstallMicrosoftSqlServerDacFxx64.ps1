

function Install-MicrosoftSqlServerDacFxx64 {
    [cmdletbinding()]
    param ( 
        [parameter(Mandatory)]
        [string] $WorkingFolder, 
        [string] $DacFxx64Version,
        [string] $NuGetPath
    )

    Write-Verbose "Verbose Folder  (with Verbose) : $WorkingFolder" 
    Write-Verbose "DataToolsVersion : $DacFxx64Version" 
    Write-Warning "If DacFxx64Version is blank latest will be used"
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
    #putting the $NugetExe and $WorkingFolder in double-quotes in case there are spaces in the paths.
    $nugetInstallDacFx = "&`"$NugetExe`" install Microsoft.SqlServer.DacFx.x64 -ExcludeVersion -OutputDirectory `"$WorkingFolder`""
    if ($DacFxx64Version) {
        if ($DacFxx64Version -lt "130.3485.1") {
            Throw "Lower versions than 130.3485.1 will NOT work with Publish-DatabaseDeployment. For more information, read the post https://blogs.msdn.microsoft.com/ssdt/2016/10/20/sql-server-data-tools-16-5-release/"            
        }
        $nugetInstallDacFx += " -version '$DacFxx64Version'"
    }
    Write-Host $nugetInstallDacFx -BackgroundColor White -ForegroundColor DarkGreen
    $execNuget = Invoke-Expression $nugetInstallDacFx 2>&1 
    Write-Host $execNuget
    $dacFxFolderNet46 = "$WorkingFolder\Microsoft.SqlServer.DacFx.x64\lib\net46"
    if (-not (Test-Path $dacFxFolderNet46)) {
        $dacFxFolderNet40 = "$WorkingFolder\Microsoft.SqlServer.DacFx.x64\lib\net40"
        if (-not (Test-Path $dacFxFolderNet40)) {
            Throw "It appears that the nuget install hasn't worked, check output above to see whats going on."
        }
    }
    if (Test-Path $dacFxFolderNet46) {
        return $dacFxFolderNet46
    }
    elseif (Test-Path $dacFxFolderNet40) {
        return $dacFxFolderNet40
    }
}

