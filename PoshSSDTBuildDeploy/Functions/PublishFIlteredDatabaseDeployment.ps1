Function Publish-FilteredDatabaseDeployment {
    [cmdletbinding()]
    param(
        $dacfxPath
        , $dacpac
        , $targetConnectionString
        , $targetDatabaseName
        , $schemaToInclude
        , [Switch] $PublishChangesToTarget
        , [Switch] $PrintOutExcludedObjects
    )

    Write-Verbose 'Testing if DACfx Extensions was installed...'
    $dacfxPath = Resolve-Path $dacfxPath
    $dacpac = Resolve-Path $dacpac
    if (-not (Test-Path $dacfxPath)) { throw "No usable version of Dac Fx found at $dacfxPath" }
    if (-not (Test-Path $dacpac)) { throw "$dacpac not found!" }
    
    try {
        Write-Verbose 'DacFX found, attempting to load DAC assembly...'
        Add-Type -Path $dacfxPath
        Write-Verbose 'Loaded DAC assembly.'
    }
    catch [System.Management.Automation.RuntimeException] {
        throw ("Exception caught: {0}" -f $_.Exception.GetType().FullName)
    }
    
    $sourceDacpac = New-Object Microsoft.SqlServer.Dac.Compare.SchemaCompareDacpacEndpoint($dacpac);
    Write-Verbose ("Loaded dacpac '{0}'." -f $Dacpac)
    
    $targetDatabase = New-Object Microsoft.SqlServer.Dac.Compare.SchemaCompareDatabaseEndpoint($targetConnectionString)
    $comparison = New-Object Microsoft.SqlServer.Dac.Compare.SchemaComparison($sourceDacpac, $targetDatabase)
    $comparisonResult = $comparison.Compare()
    
    $comparisonResult.Differences | ForEach-Object {
        if ( $_.SourceObject.name.parts[0] -ne $schemaToInclude) {
            if ($PSBoundParameters.ContainsKey('PrintOutExcludedObjects') -eq $true) {
                Write-Host "Excluding Object $($_.SourceObject.name)"
            }
            $comparisonResult.Exclude($_) | Out-Null
        }
    }

    if ($PSBoundParameters.ContainsKey('PublishChangesToTarget') -eq $true) {
        $publishResult = $comparisonResult.PublishChangesToTarget()

        if ($publishResult.Success) {
            Write-Host "Deployment successful!"
        }
        else {
            Write-Host "Deployment Failed!"
            if ($publishResult.Errors) {
                Throw $publishResult.Errors
            }
        }
    }
}
