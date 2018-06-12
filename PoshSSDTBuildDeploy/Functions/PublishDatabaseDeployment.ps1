Function Publish-DatabaseDeployment {
    [cmdletbinding()]
    param(
        $dacfxPath
        , $dacpac
        , $publishXml
        , $targetConnectionString
        , $targetDatabaseName
        , [Switch] $getSqlCmdVars
        , [Switch] $FailOnMissingVars
        , [bool] $GenerateDeploymentScript
        , [bool] $GenerateDeploymentReport 
        , $ScriptPath 
        , [Switch] $ScriptOnly
    )
    if ($ScriptPath) {
        if (-not (Test-Path $ScriptPath)) {
            Throw "Script Path Invalid!"            
        }
    }
    Write-Verbose 'Testing if DACfx was installed...'
    Write-Verbose $dacfxPath
    if (!$dacfxPath) {
        throw 'No usable version of Dac Fx found.'
    }
    else {
        try {
            Write-Verbose 'DacFX found, attempting to load DAC assembly...'
            Add-Type -Path $dacfxPath
            Write-Verbose 'Loaded DAC assembly.'
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
    if ($getSqlCmdVars) {
        if ($PSBoundParameters.ContainsKey('FailOnMissingVars') -eq $true) { 
            Get-SqlCmdVars $dacProfile.DeployOptions.SqlCommandVariableValues -FailOnMissingVariables
        }
        elseif ($PSBoundParameters.ContainsKey('FailOnMissingVars') -eq $false) {
            Get-SqlCmdVars $($dacProfile.DeployOptions.SqlCommandVariableValues)
        }
    }
    $timeStamp = (Get-Date).ToString("yyMMdd_HHmmss_f")    
    $DatabaseScriptPath = Join-Path $ScriptPath "$($targetDatabaseName)_DeployScript_$timeStamp.sql"
    $MasterDbScriptPath = Join-Path $ScriptPath "($targetDatabaseName)_Master.DeployScript_$timeStamp.sql"
    $DeploymentReport = Join-Path $ScriptPath "$targetDatabaseName.Result.DeploymentReport_$timeStamp.xml"

    $dacServices = New-Object Microsoft.SqlServer.Dac.DacServices $targetConnectionString
    $options = @{
        GenerateDeploymentScript = $GenerateDeploymentScript
        GenerateDeploymentReport = $GenerateDeploymentReport
        DatabaseScriptPath       = $DatabaseScriptPath
        MasterDbScriptPath       = $MasterDbScriptPath
        DeployOptions            = $dacProfile.DeployOptions
    }
    try {
        Register-ObjectEvent -InputObject $dacServices -EventName "Message" -Source "msg" -Action { Write-Host $EventArgs.Message.Message } | Out-Null  
        if ($ScriptOnly) {
            if (($GenerateDeploymentScript -eq $false) -and ($GenerateDeploymentReport -eq $false)) {
                $ToThrow = "Specify at least one of GenerateDeploymentScript or GenerateDeploymentReport to be true when using ScriptOnly!"
            }
            else {
                Write-Host "Generating script..." -ForegroundColor Yellow
                $result = $dacServices.script($dacPackage, $targetDatabaseName, $options)
                Write-Host "Script created!" -ForegroundColor DarkGreen
            }
        }
        else {
            Write-Host "Executing Deployment..." -ForegroundColor Yellow     
            $result = $dacServices.publish($dacPackage, $targetDatabaseName, $options)
            Write-Host "Deployment successful!" -ForegroundColor DarkGreen
        }
    }  
    catch [Microsoft.SqlServer.Dac.DacServicesException] {
        $toThrow = ('Deployment failed: ''{0}'' Reason: ''{1}''' -f $_.Exception.Message, $_.Exception.InnerException.Message)
    }
    finally {
        Unregister-Event -SourceIdentifier "msg"
        if ($toThrow) {
            Throw $toThrow
        }
        if ($GenerateDeploymentReport -eq $true) {
            $result.DeploymentReport | Out-File $DeploymentReport
            Write-Host "Deployment Report - $DeploymentReport" -ForegroundColor DarkGreen -BackgroundColor White
            $deprep = [xml] (Get-Content -Path $DeploymentReport)
            $OperationSummary = Get-OperationSummary -deprep $deprep
            $OperationTotal = Get-OperationTotal -deprep $deprep
            
        }
        if ($GenerateDeploymentScript -eq $true) {
            Write-Host "Database change script - $DatabaseScriptPath" -ForegroundColor White -BackgroundColor DarkCyan
            if ((Test-Path $MasterDbScriptPath) -eq $true) {
                Write-Host "Master database change script - $($result.MasterDbScript)" -ForegroundColor White -BackgroundColor DarkGreen
            }
        }
    
        $deployOptions = $dacProfile.DeployOptions | Select-Object -Property * -ExcludeProperty "SqlCommandVariableValues"
        [pscustomobject]@{
            Dacpac               = $dacpac
            PublishXml           = $PublishXml
            DatabaseScriptPath   = $DatabaseScriptPath
            MasterDbScriptPath   = $($result.MasterDbScript)
            DeploymentReport     = $DeploymentReport
            DeployOptions        = $deployOptions
            SqlCmdVariableValues = $dacProfile.DeployOptions.SqlCommandVariableValues.Keys
        } | Format-List

        [pscustomobject]$OperationTotal

        [pscustomobject]$OperationSummary | Format-List
    }
}