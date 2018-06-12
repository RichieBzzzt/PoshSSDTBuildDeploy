
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

$test1xml = Join-Path $PSScriptRoot "deprep\deprep_test1.xml"
$fred = Get-ChildItem $test1xml
$deprep = [xml] (Get-Content -Path $fred)
it "Function to return operation total does not throw." {
{Get-OperationTotal -deprep $deprep} | Should -Not -Throw
}

context "Custom PS Object is created." {
    $testoutput = Get-OperationTotal -deprep $deprep
}
It "test total object exists" {
{$testoutput} | Should -Not -BeNullOrEmpty
}
