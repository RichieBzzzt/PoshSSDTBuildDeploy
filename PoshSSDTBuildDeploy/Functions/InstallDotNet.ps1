
function Install-DotNet {
    param ( [string] $WorkingFolder,
        [string] $uri,
        [string] $DotNetVersion
    )

    $splitArray = $uri -split "/"
    $fileName = $splitArray[-1]
    
    Write-Verbose "Am attempting to install .NET $($DotNetVersion)" -Verbose
    $netInstaller = Join-Path -Path $WorkingFolder -ChildPath $fileName
    try {
        Invoke-WebRequest -Uri $uri -OutFile $netInstaller 
    }
    catch {
        Throw $_.Exception
    }
    If ((Test-Path $netInstaller)) {
        "File $fileName downloaded!"
    }
    else {
        "Oh dear!"
    }
    "attempting to install .Net $($DotNetVersion) from $($fileName)..."
    try {
        $args = " /q /norestart"
        $installNet471BuildTools = Start-Process $netInstaller -ArgumentList $args -Wait -PassThru -WorkingDirectory $WorkingFolder -NoNewWindow
    }
    catch {
        $fail = $_.Exception
        Write-Error $fail
    }
    if ($installNet471BuildTools.ExitCode -eq 0) {
        Write-Host "Install Successful! Run Test-NetInstalled to verify!" -ForegroundColor DarkGreen -BackgroundColor White
    }
    else {
        Write-Host "Something went wrong in installing .NET $($DotNetVersion) $($fileName)"
        Write-Error $fail
        throw
    }
}
