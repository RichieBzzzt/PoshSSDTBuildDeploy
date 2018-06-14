Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force

$test1xml = Join-Path $PSScriptRoot "deprep\deprep_test2.xml"
$fred = Get-ChildItem $test1xml
$deprep = [xml] (Get-Content -Path $fred)
it "Function Get-Alerts does not throw." {
{Get-Alerts -deprep $deprep} | Should -Not -Throw
}

context "Custom PS Object for Summary is created." {
    $testoutput = Get-Alerts -deprep $deprep
}
It "test object alerts exists" {
{$testoutput} | Should -Not -BeNullOrEmpty
}