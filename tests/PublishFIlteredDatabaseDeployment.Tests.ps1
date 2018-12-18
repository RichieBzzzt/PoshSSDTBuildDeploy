#import module from repo
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

function Get-Schema ($databaseName, $serverInstanceName, $schema) {
    @(Invoke-Sqlcmd -Query "select name as schemaName from $databasename.sys.schemas where name = `'$schema`' " -ServerInstance $serverInstanceName) | Select-Object -ExpandProperty schemaName
}
Describe "Publish-FilteredDatabaseDeployment" {    
    BeforeAll {
        $instanceName = "poshssdtbuilddeploy"
        sqllocaldb.exe create $instanceName 13.0 -s
        sqllocaldb.exe info $instanceName
    
        $serverInstance = "(localdb)\$instanceName"
        $FD_NAME = "FilteringDemo"
        $svrConnstring = "SERVER=$serverInstance;Integrated Security=True;Database=$FD_Name"
        $WWI = Join-Path $PSScriptRoot "wwi-dw-ssdt"
        $FD_DAC = Join-Path $WWI "\Microsoft.Data.Tools.Msbuild\lib\net46"
        $FD_DACFX = Join-Path $FD_DAC "\Microsoft.SqlServer.Dac.Extensions.dll"
        $FD_DACPAC = Join-Path $PSScriptRoot "\FilteringDemo\FilteringDemo.dacpac"
        $FD_DACPAC_BROKEN = Join-Path $PSScriptRoot "\FilteringDemo\FilteringDemoBroken.dacpac"
        $FD_SCHEMA = "Production"   
    }

    BeforeEach{
        Invoke-Sqlcmd -Query "drop database if exists $FD_NAME" -ServerInstance $serverInstance    
        Invoke-Sqlcmd -Query "create database $FD_NAME" -ServerInstance $serverInstance
    }
     it "Output the objects that will not be included, but does not deploy." {
        {Publish-FilteredDatabaseDeployment -dacfxPath $FD_DACFX -dacpac $FD_DACPAC -targetConnectionString $svrConnstring -targetDatabaseName $FD_NAME -PrintOutExcludedObjects -schemaToInclude "$FD_SCHEMA"} | Should -Not -Throw
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "Production" | Should -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "UnProduction" | Should -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "dbo" | Should -Not -BeNullOrEmpty
    }
    it "Output the objects that will not be included, and does deploy." {
        {Publish-FilteredDatabaseDeployment -dacfxPath $FD_DACFX -dacpac $FD_DACPAC -targetConnectionString $svrConnstring -targetDatabaseName $FD_NAME -PrintOutExcludedObjects -schemaToInclude "$FD_SCHEMA" -PublishChangesToTarget} | Should -Not -Throw
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "Production" | Should -Not -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "UnProduction" | Should -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "dbo" | Should -Not -BeNullOrEmpty
    }
    it "No output, does not deploy." {
        {Publish-FilteredDatabaseDeployment -dacfxPath $FD_DACFX -dacpac $FD_DACPAC -targetConnectionString $svrConnstring -targetDatabaseName $FD_NAME -schemaToInclude "$FD_SCHEMA"} | Should -Not -Throw
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "Production" | Should -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "UnProduction" | Should -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "dbo" | Should -Not -BeNullOrEmpty
    }
    it "No output, does deploy." {
        {Publish-FilteredDatabaseDeployment -dacfxPath $FD_DACFX -dacpac $FD_DACPAC -targetConnectionString $svrConnstring -targetDatabaseName $FD_NAME -schemaToInclude "$FD_SCHEMA" -PublishChangesToTarget} | Should -Not -Throw
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "Production" | Should -Not -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "UnProduction" | Should -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "dbo" | Should -Not -BeNullOrEmpty
    }
    it "Missing table for foreign key, will not throw as not publishing changes" {
        {Publish-FilteredDatabaseDeployment -dacfxPath $FD_DACFX -dacpac $FD_DACPAC_BROKEN -targetConnectionString $svrConnstring -targetDatabaseName $FD_NAME -schemaToInclude "$FD_SCHEMA"} | Should -Not -Throw
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "Production" | Should -Not -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "UnProduction" | Should -Not -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "dbo" | Should -Not -BeNullOrEmpty
    }
    it "Missing table for foreign key, will not throw as publishing changes" {
        {Publish-FilteredDatabaseDeployment -dacfxPath $FD_DACFX -dacpac $FD_DACPAC_BROKEN -targetConnectionString $svrConnstring -targetDatabaseName $FD_NAME -schemaToInclude "$FD_SCHEMA" -PublishChangesToTarget} | Should -Not -Throw
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "Production" | Should -Not -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "UnProduction" | Should -Not -BeNullOrEmpty
        Get-Schema -databaseName $FD_NAME -serverInstanceName $serverInstance -schema "dbo" | Should -Not -BeNullOrEmpty
    }
}
