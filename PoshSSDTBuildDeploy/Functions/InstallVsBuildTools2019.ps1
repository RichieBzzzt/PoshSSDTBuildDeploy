function Install-VsBuildTools2019 {
    param ( [string] $WorkingFolder
)
    $download = "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=16#"
    $MSBuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\16.0\Bin"
    if (!(Test-Path $MSBuildPath)) {
        Write-Warning "no msbuild. Am attempting to install."
        $MSBuildInstaller = Join-Path -Path $WorkingFolder -ChildPath "vs_BuildTools.exe"
        Invoke-WebRequest -Uri $download -OutFile  $MSBuildInstaller 
        If ((Test-Path $MSBuildInstaller)) {
            "File downloaded!"
        }
        else {
            "Oh dear!"
        }
        "attempting to install..."
        try {
            $args = " --quiet --norestart --wait --add Microsoft.VisualStudio.Workload.MSBuildTools"
            $installVs2017BuildTools = Start-Process $MSBuildInstaller -ArgumentList $args -Wait -PassThru -WorkingDirectory $WorkingFolder -NoNewWindow
        }
        catch {
            $_.Exception
        }
        if ($installVs2017BuildTools.ExitCode -eq 0) {
            Write-Host "Install Successful!" -ForegroundColor DarkGreen -BackgroundColor White
        }
        else {
            Write-Error "Something went wrong in installing Visual Studio Build Tools."
        }
    }
    else{
        Write-Host "VS Build Tools 2019 Installed!" -ForegroundColor White -BackgroundColor DarkCyan
    }
}