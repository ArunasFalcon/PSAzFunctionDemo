using namespace System.Net

param($Request, $TriggerMetadata)

$count = $Request.Query.count
$par = $Request.Query.par
Write-Host "Count: $count"
Write-Host "Par: $par"

if ($par -eq 0)
{
    $par = 1
}

$guids = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

$count = $Request.Query.count -1
$uri = "https://demoasiofhwisouefgh.azurewebsites.net/api/guidtest?par=$par&count=$count&code=x1zmx5ObnrW8mgcqg4psJDXSGCduGMdh7IcWQHrhw73MzdYgBUBi9A=="

$guid = [guid]::NewGuid()
$guid = "$guid`n"

if ($count -gt 0)
{
    1..$par | ForEach-Object -Parallel {
        $lGuids = $using:guids
        $lUri = $using:uri
        $response = Invoke-RestMethod -Method Get -Uri $lUri
        $lGuids.Add($response)
    }
}

$guidlist = $guids | Join-String

$body = $guidlist + "$guid"

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
