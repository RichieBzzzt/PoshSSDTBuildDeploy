
Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

$test1xml = Join-Path $PSScriptRoot "deprep\deprep_test1.xml"
$fred = Get-ChildItem $test1xml
$deprep = [xml] (Get-Content -Path $fred)
it "Function does nto throw." {
{Get-OperationSummary -deprep $deprep} | Should -Not -Throw
}

context "Custom PS Object for Summary is created." {
    $testoutput = Get-OperationSummary -deprep $deprep
}
It "test object summary exists" {
{$testoutput} | Should -Not -BeNullOrEmpty
}