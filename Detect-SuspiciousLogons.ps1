# Suspicious Logon Detection

$TimeWindowMinutes = 5
$Threshold = 5

$events = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = (Get-Date).AddMinutes(-$TimeWindowMinutes)
}

$count = $events.Count

Write-Host "Failed logons detected: $count"
Write-Host ""

if ($count -ge $Threshold) {
    Write-Host "ALERT: Potential suspicious logon activity detected."
    Write-Host "Threshold: $Threshold failed logons within $TimeWindowMinutes minutes."
    Write-Host ""
    Write-Host "Investigation details:"
    Write-Host ""

    foreach ($event in $events) {
        $message = $event.Message

        $account = if ($message -match "Account Name:\s+(.+)") {
            $matches[1].Trim()
        } else {
            "Unknown"
        }

        $reason = if ($message -match "Failure Reason:\s+(.+)") {
            $matches[1].Trim()
        } else {
            "Unknown"
        }

        Write-Host "Time:   $($event.TimeCreated)"
        Write-Host "Account: $account"
        Write-Host "Reason: $reason"
        Write-Host "Event:  $($event.Id)"
        Write-Host "-----------------------------"
    }
}
else {
    Write-Host "No suspicious burst detected."
}