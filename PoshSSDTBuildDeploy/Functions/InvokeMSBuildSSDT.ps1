

function Invoke-MsBuildSSDT {
    param ( [string] $DatabaseSolutionFilePath
        , [string] $DataToolsFilePath
        , [string]$MSBuildVersionNumber)

    if ([string]::IsNullOrEmpty($MSBuildVersionNumber)) {
        $MSBuildVersionNumber = "15.0"
    }
    if ($MSBuildVersionNumber -eq "15.0") {
        $filepath = "C:\Program Files (x86)\Microsoft Visual Studio\2017"
        $folders = Get-ChildItem $filepath
        $MsBuildInstalled = 0
        foreach ($folder in $folders) {
            $MsbuildPath = Join-Path $filepath "$folder\MSBuild\15.0\Bin"
            if ((Test-Path $MsbuildPath) -eq $true) {
                Write-Host "MsBuild found!" -ForegroundColor Green -BackgroundColor Yellow
                $MsBuild = Join-Path $MsbuildPath "msbuild.exe"
                $MsBuildInstalled = 1
                break
            }
        }
        if ($MsBuildInstalled -eq 0) {
            Write-Error "Install Visual Studio Tools 2017 MSBuild Tools to continue!"
            Throw
        }
    }
    else {
        $msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
    }
    if (-not (Test-Path $msbuild)) {
        Write-Error "No MSBuild installed. Install Build Tools using 'Install-VsBuildTools2017', set -MSBuildVersionNumber to 15.0 and try again!"
        Throw
    }
    $arg1 = "/p:tv=$MSBuildVersionNumber"
    $arg2 = "/p:SSDTPath=$DataToolsFilePath"
    $arg3 = "/p:SQLDBExtensionsRefPath=$DataToolsFilePath"
    $arg4 = "/p:Configuration=Debug"

    Write-Host $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 -ForegroundColor White -BackgroundColor DarkGreen

    & $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 2>&1
}
