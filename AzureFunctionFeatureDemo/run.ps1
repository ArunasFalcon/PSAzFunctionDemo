using namespace System.Net

param($Request, $TriggerMetadata)

$count = $Request.Query.count
$par = $Request.Query.par
$code = $Request.Query.code
Write-Host "Count: $count"
Write-Host "Par: $par"

if ($par -lt 1)
{
    $par = 1
}

$url = $Request.Url
$calluri = New-Object -TypeName System.Uri -ArgumentList $url
$scheme = $calluri.Scheme
$hname = $calluri.Host
$path = $calluri.AbsolutePath
$fulluri = "${scheme}://$hname$path"
$reqmethod = $Request.Method

$guids = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

$count = $Request.Query.count -1
$uri = "${fulluri}?par=$par&count=$count&code=$code"

$guid = [guid]::NewGuid()
$localip = $env:WEBSITE_INFRASTRUCTURE_IP
$guid = "${localip}: $guid`n"

if ($count -gt 0)
{
    1..$par | ForEach-Object -Parallel {
        $lGuids = $using:guids
        $lUri = $using:uri
        $lMethod = $using:reqmethod
        $response = Invoke-RestMethod -Method $lMethod -Uri $lUri
        $lGuids.Add($response)
    }
}

$guidlist = $guids | Join-String

$body = $guidlist + "$guid"

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
