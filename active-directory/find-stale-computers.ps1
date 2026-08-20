[CmdletBinding()]
param(
    [int]$InactiveDays = 60,
    [string]$SearchBase
)

Import-Module ActiveDirectory -ErrorAction Stop

$cutoff = (Get-Date).AddDays(-$InactiveDays)

$params = @{
    Filter     = '*'
    Properties = @('LastLogonDate','Enabled','OperatingSystem','DistinguishedName')
}

if ($SearchBase) {
    $params.SearchBase = $SearchBase
}

Get-ADComputer @params |
    Where-Object {
        $_.Enabled -and (
            -not $_.LastLogonDate -or $_.LastLogonDate -lt $cutoff
        )
    } |
    Select-Object Name, OperatingSystem, LastLogonDate, DistinguishedName |
    Sort-Object LastLogonDate |
    Format-Table -AutoSize
