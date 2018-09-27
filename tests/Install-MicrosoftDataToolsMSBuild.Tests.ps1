#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force
Import-Module Pester -Force

Describe "Install-MicrosoftDataToolsMSBuild" {
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    It "should install MicrosoftDataToolsMSBuild 10.0.61026" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"} | Should -Not -Throw
    }
    it "should throw exception for MicrosoftDataToolsMSBuild 10.0.60809" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.60809"} | Should -Throw "Lower versions than 10.0.61026 will NOT work with Publish-DatabaseDeployment."       
    }
    It "skip install of nuget" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026" -NugetPath "C:\nuget"} | Should -Not -Throw
    }
}