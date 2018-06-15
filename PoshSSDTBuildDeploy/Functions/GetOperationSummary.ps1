Function Get-OperationSummary {
    [cmdletbinding()]
    param(
        $deprep
    )
    $OS = @()
    foreach ($operation in $deprep.DeploymentReport.Operations.Operation) { 
        foreach ($item in $operation.Item) {
            $OS += $operation | Select-Object @{Label = "OperationName"; Expression = {($operation.Name)}}, @{Label = "ItemValue"; Expression = {($Item.Value)}}, @{Label = "ItemType"; Expression = {($Item.Type)}}, @{Label = "IssueId"; Expression = {($Item.Issue.Id)}} 
        }
        foreach ($Issue in $item.Issue) {
            Write-Host $Issue.Id -ForegroundColor Green
        }
    }
    Return $OS 
}