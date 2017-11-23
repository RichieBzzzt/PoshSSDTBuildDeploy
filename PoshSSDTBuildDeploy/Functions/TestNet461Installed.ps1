Function Test-Net461Installed {
    Write-Verbose "Checking to see if .NET 4.6.1" -Verbose
    $what = Get-ChildItem "hklm:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release 
   if ($what -lt 394254)
   {
       Write-Error "You must have .NET 4.6.1 installed on this machine to continue!"
       Throw
   }
   else {
       Write-Host "At least 4.6.1 is installed!" -ForegroundColor White -BackgroundColor DarkGreen
   }
}
