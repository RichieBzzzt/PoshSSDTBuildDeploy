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
        , [bool] $GenerateDeploymentSummary
        , $ScriptPath 
        , [Switch] $ScriptOnly
        , [Switch] $FailOnAlerts
        , [int] $commandTimeoutInSeconds
        , [hashtable] $dacDeployOptions
        , [ValidateSet("File", "Memory")] [string] $StorageType
    )

    if (($GenerateDeploymentReport -eq $false) -and ($GenerateDeploymentSummary -eq $true)) {
        throw "To include the summary report (`$GenerateDeploymentSummary) you need to include `$GenerateDeploymentReport"
    }
    
    Write-Verbose 'Testing if DACfx was installed...'
    if (-not (Test-Path $dacfxPath)) { throw "No usable version of Dac Fx found at $dacfxPath" }
    if (-not (Test-Path $dacpac)) { throw "$dacpac not found!" }
    if (-not (Test-Path $publishXml)) { throw "$publishXml not found!" }
    if (-not (Test-Path $ScriptPath)) { Throw "Script Path Invalid!" }

    $ScriptPath = Resolve-Path $ScriptPath

    try {
        Write-Verbose 'DacFX found, attempting to load DAC assembly...'
        Add-Type -Path $dacfxPath
        Write-Verbose 'Loaded DAC assembly.'
    }
    catch [System.Management.Automation.RuntimeException] {
        throw ("Exception caught: {0}" -f $_.Exception.GetType().FullName)
    }
    
    if ($PSBoundParameters.ContainsKey('storageType') -eq $true) {
        $dacPackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($Dacpac, [Microsoft.SqlServer.Dac.DacSchemaModelStorageType]::$StorageType)
    }
    else {
        $dacPackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($Dacpac)
    }
    Write-Host ("Loaded dacpac '{0}'." -f $Dacpac) -ForegroundColor White -BackgroundColor DarkMagenta
    
    $dacProfile = [Microsoft.SqlServer.Dac.DacProfile]::Load($publishXml)
    Write-Host ("Loaded publish profile '{0}'." -f $publishXml) -ForegroundColor White -BackgroundColor DarkMagenta

    if ($PSBoundParameters.ContainsKey('targetConnectionString') -eq $false) {
        $publishXmlName = Split-Path $publishXml -leaf
        Write-Verbose "No TargetConnectionString specified, loading value from $publishXmlName" -Verbose
        $TargetConnectionString = $dacProfile.TargetConnectionString 
        $TargetConnectionStringLoadedFromPublishXml = $true
    }
    else {
        $TargetConnectionStringLoadedFromPublishXml = $false
    }
    if ($getSqlCmdVars) {
        if ($PSBoundParameters.ContainsKey('FailOnMissingVars') -eq $true) { 
            Get-SqlCmdVars $dacProfile.DeployOptions.SqlCommandVariableValues -FailOnMissingVariables
        }
        else {
            Get-SqlCmdVars $($dacProfile.DeployOptions.SqlCommandVariableValues)
        }
    }
    If ($PSBoundParameters.ContainsKey('commandTimeoutInSeconds') -eq $true) {
        $dacProfile.DeployOptions.commandTimeout = $commandTimeoutInSeconds
    }

    If ($PSBoundParameters.ContainsKey('dacDeployOptions') -eq $true) {
        $dacpProfile = Set-DacDeployOptions -dacProfile $dacProfile -dacDeployOptions $dacDeployOptions
    }

    $now = Get-Date 
    $timeStamp = Get-Date $now -Format "yyMMdd_HHmmss_f"
    $DatabaseScriptPath = Join-Path $ScriptPath "$($targetDatabaseName).Result.DeployScript_$timeStamp.sql"
    $MasterDbScriptPath = Join-Path $ScriptPath "($targetDatabaseName)_Master.DeployScript_$timeStamp.sql"
    $DeploymentReport = Join-Path $ScriptPath "$targetDatabaseName.Result.DeploymentReport_$timeStamp.xml"
    $DeploymentSummary = Join-Path $ScriptPath "$targetDatabaseName.Result.DeploymentSummary_$timeStamp.txt"

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
                throw "Specify at least one of GenerateDeploymentScript or GenerateDeploymentReport to be true when using ScriptOnly!"
            }
            Write-Host "Generating script..." -ForegroundColor Yellow
            $result = $dacServices.script($dacPackage, $targetDatabaseName, $options)
            Write-Host "Script created!" -ForegroundColor DarkGreen
        }
        else {
            Write-Host "Executing Deployment..." -ForegroundColor Yellow     
            $result = $dacServices.publish($dacPackage, $targetDatabaseName, $options)
            Write-Host "Deployment successful!" -ForegroundColor DarkGreen
        }
    }  
    catch {
        $e = $_.Exception
        $toThrow = $e.Message
        while ($e.InnerException) {
            $e = $e.InnerException
            $toThrow += "`n" + $e.Message
        }
    }
    finally {
        Unregister-Event -SourceIdentifier "msg"
        if ($ToThrow) {
            Throw $ToThrow
        }
        if ($GenerateDeploymentReport -eq $true) {
            $result.DeploymentReport | Out-File $DeploymentReport
            Write-Host "Deployment Report - $DeploymentReport" -ForegroundColor DarkGreen -BackgroundColor White
            $deprep = [xml] (Get-Content -Path $DeploymentReport)
            if ($GenerateDeploymentSummary -eq $true) {
                $OperationSummary = Get-OperationSummary -deprep $deprep
                $OperationTotal = Get-OperationTotal -deprep $deprep
                $Alerts = Get-Alerts -deprep $deprep
                if ($null -ne $Alerts) {
                    $JoinTables = Join-Object -left $OperationSummary -Right $alerts -LeftJoinProperty IssueId -RightJoinProperty IssueId -Type AllInRight -RightProperties IssueValue
                }
                "Deployment for database $targetDatabaseName on $now `n" | Out-File $DeploymentSummary
                $OperationTotal | Out-String | Add-Content $DeploymentSummary
                $OperationSummary | Out-String | Add-Content $DeploymentSummary
                $Alerts | Out-String | Add-Content $DeploymentSummary
                $JoinTables | Out-String | Where-Object { $null -ne $_.IssueId } | Add-Content $DeploymentSummary
            }
        }
        if ($GenerateDeploymentScript -eq $true) {
            Write-Host "Database change script - $DatabaseScriptPath" -ForegroundColor White -BackgroundColor DarkCyan
            if ((Test-Path $MasterDbScriptPath) -eq $true) {
                Write-Host "Master database change script - $($result.MasterDbScript)" -ForegroundColor White -BackgroundColor DarkGreen
            }
        }    
        $deployOptions = $dacProfile.DeployOptions | Select-Object -Property * -ExcludeProperty "SqlCommandVariableValues"
        $deployResult = [pscustomobject]@{
            Dacpac                                     = $dacpac
            PublishXml                                 = $PublishXml
            DeployOptions                              = $deployOptions
            SqlCmdVariableValues                       = $dacProfile.DeployOptions.SqlCommandVariableValues.Keys
            TargetConnectionStringLoadedFromPublishXml = $TargetConnectionStringLoadedFromPublishXml
        }
        if ($GenerateDeploymentScript -eq $true) {
            $deployResult | Add-Member -MemberType NoteProperty  -Name "DatabaseScriptPath" -Value $DatabaseScriptPath
            if ((Test-Path $MasterDbScriptPath) -eq $true) {
                $deployResult | Add-Member -MemberType NoteProperty  -Name "MasterDbScriptPath" -Value $result.MasterDbScript
            }
        }
        if ($GenerateDeploymentScript -eq $true) {
            $deployResult | Add-Member -MemberType NoteProperty  -Name "DeploymentReport" -Value $DeploymentReport
        }
        if ($GenerateDeploymentSummary -eq $true) {
            $deployResult | Add-Member -MemberType NoteProperty  -Name "DeploymentSummary" -Value $DeploymentSummary
        }
        $deployResult
        if ($GenerateDeplymentSummary -eq $true) {
            [pscustomobject]$OperationTotal | Format-Table
            [pscustomobject]$OperationSummary | Format-Table
            [pscustomobject]$Alerts | Format-Table
            [pscustomobject]$JoinTables | Where-Object { $null -ne $_.IssueId } | Format-Table
            if ($PSBoundParameters.ContainsKey('FailOnAlerts') -eq $true) { 
                if ($Alerts.Count -gt 0) {
                    Write-Error "Alerts found, failing. Consult tables above."
                }
            }
        }
    }
}