[CmdletBinding()]
param(
    [ValidateRange(1, 3650)]
    [int]$InactiveDays = 60,
    [string]$SearchBase
)

try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Error "The ActiveDirectory PowerShell module is required. Install RSAT-AD-PowerShell and try again. $($_.Exception.Message)"
    return
}

$cutoff = (Get-Date).AddDays(-$InactiveDays)

$params = @{
    Filter      = '*'
    Properties  = @('LastLogonDate','Enabled','OperatingSystem','DistinguishedName')
    ErrorAction = 'Stop'
}

if ($SearchBase) {
    $params.SearchBase = $SearchBase
}

try {
    $computers = Get-ADComputer @params
}
catch {
    Write-Error "Unable to query Active Directory. Verify that the host can reach a domain controller and that Active Directory Web Services are available. $($_.Exception.Message)"
    return
}

$results = $computers |
    Where-Object {
        $_.Enabled -and (
            -not $_.LastLogonDate -or $_.LastLogonDate -lt $cutoff
        )
    } |
    Select-Object Name, OperatingSystem, LastLogonDate, DistinguishedName |
    Sort-Object LastLogonDate

if (-not $results) {
    Write-Host "No enabled computer accounts older than $InactiveDays days (or without LastLogonDate) were found."
    return
}

$results | Format-Table -AutoSize
