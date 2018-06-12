Function Get-OperationSummary {
    [cmdletbinding()]
    param(
        $deprep
    )
$OS = @()
foreach ($operation in $deprep.DeploymentReport.Operations.Operation) { 
    $OS += $operation | Select-Object @{Label = "OperationName"; Expression = {($operation.Name)}} -ExpandProperty childnodes
}
Return $OS 
}