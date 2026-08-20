[CmdletBinding()]
param(
    [int]$MaxEvents = 300
)

$logName = 'Microsoft-Windows-GroupPolicy/Operational'

Get-WinEvent -LogName $logName -MaxEvents $MaxEvents |
    Where-Object { $_.Id -in 4016,5016 } |
    ForEach-Object {
        [pscustomobject]@{
            TimeCreated = $_.TimeCreated
            EventId     = $_.Id
            Message     = ($_.Message -replace '\r?\n',' ')
        }
    } |
    Sort-Object TimeCreated -Descending |
    Format-Table -Wrap -AutoSize
