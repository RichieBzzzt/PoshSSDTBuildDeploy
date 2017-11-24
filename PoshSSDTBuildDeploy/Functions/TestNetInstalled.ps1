Function Test-NetInstalled {
    
        param(
            [Parameter(Position = 1, mandatory = $false)]
            [String] $DotNetVersion
        )
        [Int] $RegEditDotNet | Out-Null
        [bool] $RequiredVersion = $true
        
        $dWord = Get-ChildItem "hklm:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release 
        if ($DotNetVersion) {
            switch ($DotNetVersion) {
                "4.5" { $RegEditDotNet = 378389} 
                "4.5.1" { $RegEditDotNet = 378675}
                "4.5.2" { $RegEditDotNet = 379893}
                "4.6" { $RegEditDotNet = 393295}
                "4.6.1" { $RegEditDotNet = 394254}
                "4.6.2" { $RegEditDotNet = 394802}
                "4.7" { $RegEditDotNet = 460798}
                "4.7.1" { $RegEditDotNet = 461308}
                default {$RegEditDotNet = 0}
            }
            if ($dWord -lt $RegEditDotNet -or $RegEditDotNet -eq 0 ) {
                Write-Error "You must have .NET $DotNetVersion installed on this machine to continue!"
                $RequiredVersion = $false
            }
            else {
                Write-Host "At least $DotNetVersion is installed!" -ForegroundColor White -BackgroundColor Red
            }
        }
    
        switch ($dWord) {
            378389 { $DotNetVersion = "4.5"  }
            378675 { $DotNetVersion = "4.5.1"}
            379893 { $DotNetVersion = "4.5.2" }
            393295 { $DotNetVersion = "4.6"   }
            394254 { $DotNetVersion = "4.6.1" }
            394802 { $DotNetVersion = "4.6.2" }
            460798 { $DotNetVersion = "4.7"   }
            461308 { $DotNetVersion = "4.7.1" }
        }
        $DotNetInfo = @{ DotNetVersion = $DotNetVersion; DWORD = $dWord[0]; RequiredVersion = $RequiredVersion}
        return $DotNetInfo
    }