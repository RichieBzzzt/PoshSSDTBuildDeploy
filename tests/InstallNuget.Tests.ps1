Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force


InModuleScope "PoshSSDTBuildDeploy" {

    describe "InstallNuget" {
        context "The nuget URL is good" {
            it "Should return the path to Nuget " {
                #Arrange
                $WorkingFolder = $TestDrive
                $NugetPath = Join-Path $TestDrive "nuget.exe"

                Write-Host "Nuget path is: $NugetPath"

                mock Invoke-Webrequest {
                    New-Item -ItemType File -Path $NugetPath
                }
                
                #Act / Assert
                (Install-NuGet -WorkingFolder $WorkingFolder)[0] | Should -Be $NugetPath
            }
        }

        context "The nuget URL is bad" {
            it "Should fail because of a 404 " {
                #Arrange
                mock Test-DownloadUri {
                    Return 404
                }
                
                $WorkingFolder = "TestDrive:\"
                #Act / Assert
                {Install-NuGet -WorkingFolder $WorkingFolder} | Should -Throw "It appears that download Nuget link no longer works. "
            }
        }
    }
}


