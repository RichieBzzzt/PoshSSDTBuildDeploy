try {
    Get-InstalledModule Pester -ErrorAction Stop | Out-Null
}
catch {
    write-host "Pester Module not found. Trying to install..."
    Install-Module Pester -Force -Scope CurrentUser
}

Invoke-Pester .\*.Tests.ps1