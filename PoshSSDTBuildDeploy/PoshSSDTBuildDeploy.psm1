foreach ($function in (Get-ChildItem "$PSScriptRoot\functions\*.ps1"))
{
	$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}

foreach ($function in (Get-ChildItem "$PSScriptRoot\functions\*.bat"))
{
	$ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($function))), $null, $null)
}