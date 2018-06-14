Function Get-Alerts {
    [cmdletbinding()]
    param(
        $deprep
    )
    $a = @()
    foreach ($alert in $deprep.DeploymentReport.Alerts.Alert) { 
        $a += $alert | Select-Object @{Label = "AlertName"; Expression = {($Alert.Name)}} -ExpandProperty childnodes
    }
    Return $a
}