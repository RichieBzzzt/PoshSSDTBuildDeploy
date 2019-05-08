# import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force



Describe "Invoke-MsBuildSSDT" {
    $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
    $WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
    $WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"    
    $WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
if ((Test-Path $WWI_DAC) -eq $false) {
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI
}
if ((Test-Path $WWI_DAC) -eq $false) {
    Write-Output "Oh! It looks like MSBuildDataTools did not download."
}

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
    
}

Describe "Invoke-MsBuildSSDT for SQLCLR Project" {
    $SQLCLR = Join-Path $PSScriptRoot "sqlclr"
    $SQLCLR_SLN = Join-Path $SQLCLR "\sqlclr.sqlproj"
    $SQLCLR_DAC = Join-Path $SQLCLR "\Microsoft.Data.Tools.Msbuild\lib\net46"    
    $SQLCLR_DACPAC = Join-Path $SQLCLR "\bin\Debug\sqlclr.dacpac"
    $SQLCLR_DLL = Join-Path $SQLCLR "\bin\Debug\sqlclr.nonsql.dll"
if ((Test-Path $SQLCLR_DAC) -eq $false) {
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $SQLCLR
}
if ((Test-Path $SQLCLR_DAC) -eq $false) {
    Write-Output "Oh! It looks like MSBuildDataTools did not download."
}

    It "should not build the sqlclr database that and produce a dacpac and dll" {
        Remove-Item $SQLCLR_DACPAC -Force -ErrorAction SilentlyContinue
        Remove-Item $SQLCLR_DLL -Force -ErrorAction SilentlyContinue
        $SQLCLR_DACPAC | Should -Not -Exist
        $SQLCLR_DLL | Should -Not -Exist
        {
            Invoke-MsBuildSSDT -DatabaseSolutionFilePath $SQLCLR -DataToolsFilePath "what"
            if ($LASTEXITCODE -ne 0){
                Throw
            }
        } | Should -Throw
        $SQLCLR_DACPAC | Should -Not -Exist
        $SQLCLR_DLL | Should -Not -Exist
    }

    It "should not build the sqlclr database and produce a dacpac and dll" {
        Remove-Item $SQLCLR_DACPAC -Force -ErrorAction SilentlyContinue
        Remove-Item $SQLCLR_DLL -Force -ErrorAction SilentlyContinue
        $SQLCLR_DACPAC | Should -Not -Exist
        $SQLCLR_DLL | Should -Not -Exist
        {
            Invoke-MsBuildSSDT -DatabaseSolutionFilePath $PSScriptRoot -DataToolsFilePath $SQLCLR_DAC
            if ($LASTEXITCODE -ne 0){
                Throw
            }
        } | Should -Throw
        $SQLCLR_DACPAC | Should -Not -Exist
        $SQLCLR_DLL | Should -Not -Exist
    }

    It "should build the sqlclr database and produce a dacpac and dll" {
        Remove-Item $SQLCLR_DACPAC -Force -ErrorAction SilentlyContinue
        Remove-Item $SQLCLR_DLL -Force -ErrorAction SilentlyContinue
        $SQLCLR_DACPAC | Should -Not -Exist
        $SQLCLR_DLL | Should -Not -Exist
        {Invoke-MsBuildSSDT -DatabaseSolutionFilePath $SQLCLR_SLN -DataToolsFilePath $SQLCLR_DAC} | Should -Not -Throw
        $SQLCLR_DACPAC | Should -Exist
        $SQLCLR_DLL | Should -Exist
    }
}