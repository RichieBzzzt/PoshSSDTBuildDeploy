#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

Describe "Invoke-MsBuildSSDT" {
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    $WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
    $WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"    
    $WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"

    It "should build the database and produce a dacpac" {
        Remove-Item $WWI_DACPAC -Force -ErrorAction SilentlyContinue
        $WWI_DACPAC | Should -Not -Exist
        {Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC} | Should -Not -Throw
        $WWI_DACPAC | Should -Exist
    }
    
}