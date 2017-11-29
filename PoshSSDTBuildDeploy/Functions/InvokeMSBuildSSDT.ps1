

function Invoke-MsBuildSSDT {
    param ( [string] $DatabaseSolutionFilePath
        , [string] $DataToolsFilePath)
        
        $msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe"
        if (-not (Test-Path $msbuild)) {
            Write-Error "No MSBuild installed. Instal Build Tools using 'Install-VsBuildTools2017' and try again!"
            Throw
        }
    $arg1 = "/p:tv=15.0"
    $arg2 = "/p:SSDTPath=$DataToolsFilePath"
    $arg3 = "/p:SQLDBExtensionsRefPath=$DataToolsFilePath"
    $arg4 = "/p:Configuration=Debug"

    Write-Host $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 -ForegroundColor White -BackgroundColor DarkGreen
    & $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4
}
