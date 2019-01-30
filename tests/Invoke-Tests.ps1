try{

    Import-PackageProvider PowerShellGet -MinimumVersion 1.0.0.1 -Force

    }
  catch{
  Write-Error "cannot run Import-PackageProvider PowerShellGet -Force"
  Throw
  }

try {
    Get-InstalledModule Pester -MinimumVersion 4.3.1 -ErrorAction Stop | Out-Null
}
catch {
    write-host "Pester Module not found. Trying to install..."
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
}
try{
    Install-Module Pester -MinimumVersion 4.3.1 -Force -SkipPublisherCheck -Scope CurrentUser
}
catch {
    Install-Module Pester -MinimumVersion 4.3.1 -Force -Scope CurrentUser
}
$ErrorActionPreference = "Stop"
$outputFile = 'TestRun.xml'
Invoke-Pester .\**\*.Tests.ps1 -PassThru -outputFile $outputFile -OutputFormat NUnitXml -EnableExit