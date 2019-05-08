function Install-VsBuildTools2017 {
    param ( [string] $WorkingFolder,
        [switch] $msBuildTools,
        [switch] $nugetPackageManager,
        [switch] $Net471TargetPack
    )
    $InstallComponent = @{
        "Microsoft.VisualStudio.Workload.MSBuildTools"      = $false
        "Microsoft.VisualStudio.Component.NuGet.BuildTools" = $false
        "Microsoft.Net.Component.4.7.1.TargetingPack" = $false
    }
    if ($PSBoundParameters.ContainsKey('msBuildTools') -eq $true) {
        $MSBuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"
        if (!(Test-Path $MSBuildPath)) {
            Write-Warning "no msbuild."
            $InstallComponent.set_Item("Microsoft.VisualStudio.Workload.MSBuildTools", $true)
        }
    }
    if ($PSBoundParameters.ContainsKey('Net471TargetPack') -eq $true) {
        $Net471Path = "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.7.1"
        if (!(Test-Path $Net471Path)) {
            Write-Warning "no .NET 4.7.1 Target Pack."
            $InstallComponent.set_Item("Microsoft.Net.Component.4.7.1.TargetingPack", $true)
        }
    }
    if ($PSBoundParameters.ContainsKey('nugetPackageManager') -eq $true) {
        $nugetPackageManagerPath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\IDE\CommonExtensions\Microsoft\NuGet\"
        if (!(Test-Path $nugetPackageManagerPath)) {
            Write-Warning "no nuget package manager."
            $InstallComponent.set_Item("Microsoft.VisualStudio.Component.NuGet.BuildTools", $true)
        }
    }
    if ($InstallComponent.Values -contains $true) {
        $download = "https://download.visualstudio.microsoft.com/download/pr/100285490/e64d79b40219aea618ce2fe10ebd5f0d/vs_BuildTools.exe"
        $MSBuildInstaller = Join-Path -Path $WorkingFolder -ChildPath "vs_BuildTools.exe"
        Invoke-WebRequest -Uri $download -OutFile  $MSBuildInstaller 
        If ((Test-Path $MSBuildInstaller)) {
            "File downloaded!"
        }
        else {
            "Oh dear!"
        }

        $args = " --quiet --norestart --wait"
        
        Foreach ($component in ($InstallComponent.GetEnumerator() | Where-Object { $_.Value -eq $true })) {
            $args += " --add $($component.name)"  
        }

        Write-Host "attempting to run build tools installer with args $($args)"
        
        try {
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
    else {
        Write-Host "VS Build Tools 2017 Installed!" -ForegroundColor White -BackgroundColor DarkCyan
    }
}