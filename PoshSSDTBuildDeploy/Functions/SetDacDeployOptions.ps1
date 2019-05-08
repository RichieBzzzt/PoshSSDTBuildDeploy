Function Set-DacDeployOptions {

    [cmdletbinding()]
    param(
        [Microsoft.SqlServer.Dac.DacProfile]$dacProfile
        , [hashtable] $dacDeployOptions
    )
    foreach ($key in $dacDeployOptions.Keys) {
        try {
            $oldValueType = $dacProfile.DeployOptions.$key.GetType()
            $oldValue = $dacProfile.DeployOptions.$key
            $NewValueType = $dacDeployOptions[$key].GetType()
            if ($NewValueType -ne $oldValueType) {
                Write-Host "Type of new value of $($key) does not match type of old value. Old value is $($oldValueType) whereas new type is $($newValueType). This may cause errors or values not to be set." -ForegroundColor Magenta -BackgroundColor Yellow
                Throw
            }
            $dacProfile.DeployOptions.$key = $dacDeployOptions[$key]
            Write-Host "Altered value of $($key) from $($oldValue) to $($dacProfile.DeployOptions.$key)"
        }
        catch {
            Write-Host $_.Exception
            throw
        }
        
    }
    Return $dacProfile
}