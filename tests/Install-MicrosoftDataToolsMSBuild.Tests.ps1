#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

InModuleScope "PoshSSDTBuildDeploy" {
Describe "Install-MicrosoftDataToolsMSBuild" {
    BeforeAll {
        $spacePath = Join-Path $PSScriptRoot "s p a c e s"
        $nuget = Join-Path $spacePath "nuget.exe"
        Remove-Item $nuget -Force -ErrorAction "SilentlyContinue"
    }
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    It "skip install of nuget" {
        Install-NuGet -WorkingFolder $PSScriptRoot 
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026" -NugetPath $PSScriptRoot} | Should -Not -Throw
    }
    It "skip install of nuget" {
        Install-NuGet -WorkingFolder $PSScriptRoot 
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026" -NugetPath $PSScriptRoot} | Should -Not -Throw
        $expected = Join-Path $wwi "Microsoft.Data.Tools.Msbuild\lib\net46"
        $expected | Should -Exist
    }
    It "Will throw if nuget does not exist in specified path" {
        $spaces = Join-Path $PSScriptRoot "s p a c e s"
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026" -NugetPath $($spaces) } | Should -Throw
    }
    It "skip install of nuget; able to use folder path with spaces" {
        $spaces = Join-Path $PSScriptRoot "s p a c e s"
        Install-NuGet -WorkingFolder $spaces
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026" -NugetPath $spaces } | Should -Not -Throw
    }
    It "should install MicrosoftDataToolsMSBuild 10.0.61026" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"} | Should -Not -Throw
    }
    it "should throw exception for MicrosoftDataToolsMSBuild 10.0.60809" {
        {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.60809"} | Should -Throw "Lower versions than 10.0.61026 will NOT work with Publish-DatabaseDeployment."       
    }
    Context "Mock .net version is less than 4.6.1"{

        Mock -CommandName Test-NetInstalled -MockWith {
            return @{ DotNetVersion = "4.6.0"; DWORD = 394253; RequiredVersion = "4.6.1"} }

            {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"} | Should -Throw "Need to install .NET 4.6.1 at least!"       

    }

    Context "Mock .net version is 4.6.1"{

        Mock -CommandName Test-NetInstalled -MockWith {
            return @{ DotNetVersion = "4.6.1"; DWORD = 394255; RequiredVersion = "4.6.1"} }

            {Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI -DataToolsMsBuildPackageVersion "10.0.61026"} | Should -Not -Throw       

    }
}
}