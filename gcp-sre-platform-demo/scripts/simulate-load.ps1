param (
    [Parameter(Mandatory=$true)]
    [string]$ServiceUrl,
    [int]$Requests = 100,
    [int]$DelayMs = 100
)

Write-Host "Starting load simulation"
Write-Host "Target: $ServiceUrl"
Write-Host "Requests: $Requests"
Write-Host "Delay: $DelayMs ms"
Write-Host "---------------------------"

$success = 0
$errors = 0

for ($i = 1; $i -le $Requests; $i++) {
    try {
        $response = Invoke-WebRequest -Uri $ServiceUrl -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            $success++
        }
    } catch {
    $errors++
    #Write-Host "Error:" $_.Exception.Message
}
    Start-Sleep -Milliseconds $DelayMs
}

Write-Host "---------------------------"
Write-Host "Simulation complete"
Write-Host "Successful requests: $success"
Write-Host "Errors: $errors"