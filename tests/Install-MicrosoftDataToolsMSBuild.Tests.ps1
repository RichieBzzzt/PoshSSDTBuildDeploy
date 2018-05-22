#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

Describe "Tests" {
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    It "should install MicrosoftDataToolsMSBuild 10.0.61026" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"} | Should -Not -Throw
    }
    it "should throw exception for MicrosoftDataToolsMSBuild 10.0.60809" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.60809"} | Should -Throw "Lower versions than 10.0.61026 will NOT work with Publish-DatabaseDeployment."       
    }
}