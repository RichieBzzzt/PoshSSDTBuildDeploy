Function Install-NuGet {
        <#
    .SYNOPSIS
    Installs NuGet from the web.
    .DESCRIPTION
    Checks that NuGet is installed in given folder location. If it isn't it is downloaded from the web.
    .PARAMETER WorkingFolder
    Location that Nuget.exe is/isn't.
    .PARAMETER  NugetInstalluri
    The url used to download Nuget. 
    .INPUTS
    N/A
    .OUTPUTS
    NugetExe: the path to Nuget, irrespective of whether it was downloaded or already existed.
    .EXAMPLE
    $NuGetPath = Install-NuGet -WorkingFolder $PsScriptRoot -NuGetInstallUri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    .NOTES
      N/A
    #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [string] $WorkingFolder,
            [Parameter(Mandatory = $true)]
            [string] $NuGetInstallUri
        )
        Write-Verbose "Working Folder   : $WorkingFolder" -Verbose
        $NugetExe = "$WorkingFolder\nuget.exe"
        if (-not (Test-Path $NugetExe)) {
            Write-Verbose "Cannot find nuget at path $WorkingFolder\nuget.exe" -Verbose
            If (($LinkStatus = Test-DownloadUri -uri $NuGetInstallUri) -ne 200) {
                Throw "It appears that download Nuget link no longer works. "    
            }
            $sourceNugetExe = $NuGetInstallUri
            Write-Verbose "$sourceNugetExe -OutFile $NugetExe" -Verbose
            Invoke-WebRequest $sourceNugetExe -OutFile $NugetExe
            if (-not (Test-Path $NugetExe)) { 
                Throw "It appears that the nuget download hasn't worked."
            }
            Else {
                Write-Verbose "Nuget Downloaded!" -Verbose
            }
        }
        Return $NugetExe
    }
    