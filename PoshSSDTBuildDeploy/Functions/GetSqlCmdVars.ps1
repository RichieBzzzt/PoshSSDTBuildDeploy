
function Get-SqlCmdVars {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $sqlCommandVariableValues,
        [Parameter(Mandatory = $false)]
        [Switch] $FailOnMissingVariables
    )

    # track any missing variables so provide more helpful error messages
    $missingOctopusVariables = @()
    Write-Host "Value of `$FailOnMissingVariables = $FailOnMissingVariables, NullOrEmpty $([string]::IsNullOrEmpty($FailOnMissingVariables)), $($PSBoundParameters.ContainsKey('FailOnMissingVariables'))"

    $keys = $($sqlCommandVariableValues.Keys)
    foreach ($var in $keys) {
        # Attempt to resolve SQLCmd variables via matching powershell variables explicitly defined in the current context
        if (Test-Path variable:$var) {
            Write-Host "Here! again"
            $value = Get-Variable $var -ValueOnly
            Write-Verbose ('Setting SqlCmd variable: {0} = {1}' -f $var, $value)
            $sqlCommandVariableValues[$var] = $value
        }
        else {
            $missingOctopusVariables += $var
        }
    }

    # To try and avoid 'bad' default values getting deployed, block a deployment if we have SqlCmd variables that aren't defined in Octopus
    
    if ($missingOctopusVariables.Count -gt 0) {
        if ($PSBoundParameters.ContainsKey('FailOnMissingVariables') -eq $true) {
            throw ('The following SqlCmd variables are not defined in the Octopus project (but are defined in the publish profile): {0}' -f ($missingOctopusVariables -join " `n"))
        }
        else{
            Write-Host 'The following SqlCmd variables are not defined in the Octopus project (but are defined in the publish profile):'  
            foreach ($missing in $missingOctopusVariables)
            {Write-Host $missing}
        }
    }
}