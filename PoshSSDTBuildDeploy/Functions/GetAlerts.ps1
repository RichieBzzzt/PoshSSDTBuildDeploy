# Internal function: do not use
Function Get-Alerts {
    [cmdletbinding()]
    param(
        $deprep
    )
    $a = @()
    foreach ($alert in $deprep.DeploymentReport.Alerts.Alert) {
        foreach ($Issue in $alert.Issue) {
            $a += $alert | Select-Object @{Label = "AlertName"; Expression = {($Alert.Name)}}, @{Label = "IssueValue"; Expression = {($Issue.Value)}}, @{Label = "IssueId"; Expression = {($Issue.Id)}}  
        } 
    }
    Return $a
}