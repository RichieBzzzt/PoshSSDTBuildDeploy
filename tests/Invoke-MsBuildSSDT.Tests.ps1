#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

Describe "Invoke-MsBuildSSDT" {
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    $WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
    $WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"    
    $WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"

    It "should not build the database and produce a dacpac" {
        Remove-Item $WWI_DACPAC -Force -ErrorAction SilentlyContinue
        $WWI_DACPAC | Should -Not -Exist
        {
            Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI -DataToolsFilePath "what"
            if ($LASTEXITCODE -ne 0){
                Throw
            }
        } | Should -Throw
        $WWI_DACPAC | Should -Not -Exist
    }

    It "should not build the database and produce a dacpac" {
        Remove-Item $WWI_DACPAC -Force -ErrorAction SilentlyContinue
        $WWI_DACPAC | Should -Not -Exist
        {
            Invoke-MsBuildSSDT -DatabaseSolutionFilePath $PSScriptRoot -DataToolsFilePath $WWI_DAC
            if ($LASTEXITCODE -ne 0){
                Throw
            }
        } | Should -Throw
        $WWI_DACPAC | Should -Not -Exist
    }

    It "should build the database and produce a dacpac" {
        Remove-Item $WWI_DACPAC -Force -ErrorAction SilentlyContinue
        $WWI_DACPAC | Should -Not -Exist
        {Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC} | Should -Not -Throw
        $WWI_DACPAC | Should -Exist
    }

    It "Specify MSBuild path" {
        Remove-Item $WWI_DACPAC -Force -ErrorAction SilentlyContinue
        $WWI_DACPAC | Should -Not -Exist
        {Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC -msBuild "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"} | Should -Not -Throw
        $WWI_DACPAC | Should -Exist
    }
    
}