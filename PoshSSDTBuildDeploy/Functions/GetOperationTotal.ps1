Function Get-OperationTotal {
    [cmdletbinding()]
    param(
        $deprep
    )
    $OT = @()
    foreach ($operation in $deprep.DeploymentReport.Operations.Operation) { 
        $OT += $operation | Select-Object @{Label = "OperationName"; Expression = {($operation.Name)}}, @{Label = "count"; Expression = {$operation.Item.Value.Count.ToString()}}
    } 
    Return $OT
}