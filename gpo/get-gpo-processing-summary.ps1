[CmdletBinding()]
param(
    [ValidateRange(1, 10000)]
    [int]$MaxEvents = 300
)

$logName = 'Microsoft-Windows-GroupPolicy/Operational'

try {
    $events = Get-WinEvent -LogName $logName -MaxEvents $MaxEvents -ErrorAction Stop |
        Where-Object { $_.Id -in 4016,5016 } |
        ForEach-Object {
            [pscustomobject]@{
                TimeCreated = $_.TimeCreated
                EventId     = $_.Id
                Message     = ($_.Message -replace '\r?\n',' ')
            }
        } |
        Sort-Object TimeCreated -Descending
}
catch {
    Write-Error "Unable to read the Group Policy operational log '$logName'. $($_.Exception.Message)"
    return
}

if (-not $events) {
    Write-Host "No Group Policy extension processing events (4016/5016) were found in the last $MaxEvents events."
    return
}

$events | Format-Table -Wrap -AutoSize
