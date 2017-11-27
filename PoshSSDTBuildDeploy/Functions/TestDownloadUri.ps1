Function Test-DownloadUri {
    <#
.SYNOPSIS
Tests that a url is valid
.DESCRIPTION
Returns a status code from an http request of a url. Used to verify that download links work.
.PARAMETER Uri
The url that we are checking is valid
.INPUTS
N/A
.OUTPUTS
  Status code from an http response or null if link is invalid
.EXAMPLE
$uri = "www.google.com"
$status = Test-DownloadUri -uri $uri
 if ($status -ne 200)
 {Write-Error "oh dear"}
.NOTES
  N/A
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $uri
    )
    $httpRequest = [System.Net.WebRequest]::Create($uri)
    try {
        $httpResponse = $httpRequest.GetResponse()
        $httpStatus = $httpResponse.StatusCode
        If ($httpStatus -eq 200) { 
            Write-Verbose "Download link is OK." -Verbose 
        }
        Else {
            Write-Error "Download link no longer works."
        }
        $httpResponse.Close()
        Return $httpStatus
    }
    catch {
        Write-Error "Download link no longer works."
        Return $null
    }
}
