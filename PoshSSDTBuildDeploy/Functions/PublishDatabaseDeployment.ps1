Function Publish-DatabaseDeployment {

    param(
        $dacfxPath
        , $dacpac
        , $publishXml
        , $targetConnectionString
        , $targetDatabaseName
    )
    Write-Verbose 'Testing if DACfx was installed...' -Verbose
    Write-Verbose $dacfxPath -Verbose
    if (!$dacfxPath) {
        throw 'No usable version of Dac Fx found.'
    }
    else {
        try {
            Write-Verbose 'DacFX found, attempting to load DAC assembly...' -Verbose
            Add-Type -Path $dacfxPath
            Write-Verbose 'Loaded DAC assembly.' -Verbose
        }
        catch [System.Management.Automation.RuntimeException] {
            throw "Exception caught: " + $_.Exception.GetType().FullName
        }
    }
    if (Test-Path $dacpac) {
        $dacPackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($Dacpac)
        Write-Host ('Loaded dacpac ''{0}''.' -f $Dacpac) -ForegroundColor White -BackgroundColor DarkMagenta
    }
    else {
        Write-Verbose "$dacpac not found!" -Verbose
        throw
    }
    if (Test-Path $publishXml) {
        $dacProfile = [Microsoft.SqlServer.Dac.DacProfile]::Load($publishXml)
        Write-Host ('Loaded publish profile ''{0}''.' -f $publishXml) -ForegroundColor White -BackgroundColor DarkMagenta
    }
    else {
        Write-Verbose "$publishXml not found!" -Verbose
        throw
    }
    $dacServices = New-Object Microsoft.SqlServer.Dac.DacServices $targetConnectionString
    try {
        Write-Host "Executing Deployment..." -ForegroundColor Yellow
        Register-ObjectEvent -InputObject $dacServices -EventName "Message" -Source "msg" -Action { Write-Host $EventArgs.Message.Message } | Out-Null       
        $dacServices.Deploy($dacPackage, $targetDatabaseName, $true, $dacProfile.DeployOptions, $null)
        Write-Host "Deployment successful!" -ForegroundColor DarkGreen
    }  
    catch [Microsoft.SqlServer.Dac.DacServicesException] {
        $toThrow = ('Deployment failed: ''{0}'' Reason: ''{1}''' -f $_.Exception.Message, $_.Exception.InnerException.Message)
    }
    finally {
        Unregister-Event -SourceIdentifier "msg"
        if ($toThrow) {
            Throw $toThrow
        }
    }
}