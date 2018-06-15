#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

Describe "Publish-DatabaseDeployment" {    
    
    function Get-DbId ($databaseName, $serverInstanceName) {
        @(Invoke-Sqlcmd -Query "select db_id('$databaseName') as DbId" -ServerInstance $serverInstanceName) | Select-Object -First 1 -ExpandProperty DbId
    }

    BeforeAll {
        $instanceName = "poshssdtbuilddeploy"
        sqllocaldb.exe create $instanceName 13.0 -s
        sqllocaldb.exe info $instanceName
    
        $serverInstance = "(localdb)\$instanceName"
        $svrConnstring = "SERVER=$serverInstance;Integrated Security=True;Database=master"
        $WWI_NAME = "WideWorldImporters"
        $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
        $WWI_SLN = Join-Path $WWI "\WideWorldImportersDW.sqlproj"
        $WWI_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
        $WWI_DACFX = Join-Path $WWI_DAC "\Microsoft.SqlServer.Dac.dll"
        $WWI_DACPAC = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.dacpac"
        $WWI_PUB = Join-Path $WWI "\bin\Debug\WideWorldImportersDW.publish.xml"
        $DeploymentReportPathPattern = Join-path $WWI "*DeploymentReport_*.xml"
        $DeploymentScriptPathPattern = Join-path $WWI "*DeployScript_*.sql"
        $DeploymentSummaryPathPattern = Join-path $WWI "*DeploymentSummary_*.txt"
    
        Remove-Item $WWI_DACPAC -Force -ErrorAction SilentlyContinue
        Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_SLN -DataToolsFilePath $WWI_DAC
    }

    BeforeEach {
        Remove-Item $DeploymentReportPathPattern -ErrorAction SilentlyContinue
        Remove-Item $DeploymentScriptPathPattern -ErrorAction SilentlyContinue  
        Remove-Item $DeploymentSummaryPathPattern -ErrorAction SilentlyContinue  
        Invoke-Sqlcmd -Query "drop database if exists $WWI_NAME" -ServerInstance $serverInstance  
    }

    it "Deploy the database and DeploymentScript is not generated and DeploymentReport is not generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeploymentReport $false -ScriptPath $WWI } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -Not -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Not -Exist
        $DeploymentReportPathPattern | Should -Not -Exist
        $DeploymentSummaryPathPattern | Should -Not -Exist
    }
    it "Deploy the database and DeploymentScript is not generated and DeploymentReport is not generated and Missing Variable is written to Host" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeploymentReport $false -ScriptPath $WWI -getSqlCmdVars } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -Not -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Not -Exist
        $DeploymentReportPathPattern | Should -Not -Exist
        $DeploymentSummaryPathPattern | Should -Not -Exist
    }

    it "Deploy the database and DeploymentScript is generated and DeploymentReport is not generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeploymentReport $false -ScriptPath $WWI } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -Not -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Exist
        $DeploymentReportPathPattern | Should -Not -Exist
        $DeploymentSummaryPathPattern | Should -Not -Exist
    }
    it "Deploy the database and DeploymentScript is not generated and DeploymentReport is generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeploymentReport $true -ScriptPath $WWI } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -Not -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Not -Exist
        $DeploymentReportPathPattern | Should -Exist
        $DeploymentSummaryPathPattern | Should -Exist
    }
    it "Deploy the database and DeploymentScript is generated and DeploymentReport is generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeploymentReport $true -ScriptPath $WWI } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -Not -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Exist
        $DeploymentReportPathPattern | Should -Exist
        $DeploymentSummaryPathPattern | Should -Exist
    }
    it "Database is not deployed and DeploymentScript is generated and DeploymentReport is not generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeploymentReport $false -ScriptPath $WWI -ScriptOnly } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Exist
        $DeploymentReportPathPattern | Should -Not -Exist
        $DeploymentSummaryPathPattern | Should -Not -Exist
    }
    it "Database is not deployed and DeploymentScript is not generated and DeploymentReport is generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeploymentReport $true -ScriptPath $WWI -ScriptOnly } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Not -Exist
        $DeploymentReportPathPattern | Should -Exist
        $DeploymentSummaryPathPattern | Should -Exist
    }
    it "Database is not deployed and DeploymentScript is generated and DeploymentReport is generated" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $true -GenerateDeploymentReport $true -ScriptPath $WWI -ScriptOnly } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Exist
        $DeploymentReportPathPattern | Should -Exist
        $DeploymentSummaryPathPattern | Should -Exist
    }  
    it "throws exception if not at least one of GenerateDeploymentScript or GenerateDeploymentReport is true when using ScriptOnly" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath $WWI -ScriptOnly} |
            Should -Throw "Specify at least one of GenerateDeploymentScript or GenerateDeploymentReport to be true when using ScriptOnly!"
    }
    it "throws exception if Script Path is Invalid" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeployMentReport $false -ScriptPath "X:\bob" } |
            Should -Throw "Script Path Invalid"
    }
    it "Throws exception that variable is not included in session" {
        {Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeploymentReport $false -ScriptPath $WWI -getSqlCmdVars -FailOnMissingVars } | 
            Should -Throw
    }
    it "Deploy the database and DeploymentScript is not generated and DeploymentReport is not generated and DeployTag is updated to PesterTest" {
        {$DeployTag = "PesterTest"
        Write-Host $DeployTag
            Publish-DatabaseDeployment -dacfxPath $WWI_DACFX -dacpac $WWI_DACPAC -publishXml $WWI_PUB -targetConnectionString $svrConnstring -targetDatabaseName $WWI_NAME -GenerateDeploymentScript $false -GenerateDeploymentReport $false -ScriptPath $WWI -getSqlCmdVars } | Should -Not -Throw
        Get-DbId -databaseName $WWI_NAME -serverInstanceName $serverInstance | Should -Not -BeNullOrEmpty
        $DeploymentScriptPathPattern | Should -Not -Exist
        $DeploymentReportPathPattern | Should -Not -Exist
        $DeploymentSummaryPathPattern | Should -Not -Exist
    }
}