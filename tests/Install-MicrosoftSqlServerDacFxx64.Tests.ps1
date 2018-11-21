#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force
Import-Module Pester -Force
Describe "Install-MicrosoftSqlServerDacFxx64" {
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    It "skip install of nuget" {
        Install-NuGet -WorkingFolder $PSScriptRoot 
        {Install-MicrosoftSqlServerDacFxx64 -WorkingFolder $WWI -DacFxx64Version "150.4200.1" -NugetPath $PSScriptRoot} | Should -Not -Throw
    }
    It "skip install of nuget; able to use folder path with spaces" {
        $spaces = Join-Path $PSScriptRoot "s p a c e s"
        Install-NuGet -WorkingFolder $spaces
        {Install-MicrosoftSqlServerDacFxx64 -WorkingFolder $WWI -DacFxx64Version "150.4200.1" -NugetPath $spaces } | Should -Not -Throw
    }
    It "should install MicrosoftSqlServerDacFxx64 150.4200.1" {
        {Install-MicrosoftSqlServerDacFxx64 -WorkingFolder $WWI -DacFxx64Version "150.4200.1"} | Should -Not -Throw
    }
    it "should throw exception for MicrosoftSqlServerDacFxx64 10.0.60809" {
        {Install-MicrosoftSqlServerDacFxx64 -WorkingFolder $WWI -DacFxx64Version "130.3450.1"} | Should -Throw "Lower versions than 130.3485.1 will NOT work with Publish-DatabaseDeployment."       
    }
}