# Windows Infrastructure Automation

Practical **PowerShell automation patterns for Windows infrastructure operations**, focused on repeatability, diagnostics and safe administration.

This repository contains sanitized examples inspired by real operational work across **Active Directory, Group Policy, Windows Server and workstation management**.

> No production domains, credentials, hostnames or company-specific data are included.

## What this repository demonstrates

- Active Directory inventory and lifecycle checks
- Group Policy processing diagnostics
- Windows event-log analysis
- Local administrator auditing
- Repeatable workstation/server operations
- Defensive PowerShell scripting patterns

## Architecture

```text
Administrator / Scheduled Task
            |
            v
      PowerShell tooling
       /      |       \
      v       v        v
 Active     GPO /    Windows
Directory  Event Log  Hosts
      \       |        /
       \      |       /
        v     v      v
      Reports / Actions
```

## Repository structure

```text
windows-infra-automation/
├── active-directory/
│   └── find-stale-computers.ps1
├── gpo/
│   └── get-gpo-processing-summary.ps1
├── docs/
│   └── architecture.md
├── VALIDATION.md
└── README.md
```

## Quick start — Windows Server 2022

The current scripts were clean-VM tested on **Windows Server 2022 Standard Evaluation** with **Windows PowerShell 5.1**.

### 1. Install Git

A clean Windows Server 2022 installation does not include Git or `winget` by default. Install Git for Windows from the official Git for Windows distribution, then open a new PowerShell session so the updated `PATH` is loaded.

Validated Git version during the documented test run:

```text
git version 2.55.0.windows.3
```

Confirm:

```powershell
git --version
```

### 2. Clone the repository

```powershell
New-Item -ItemType Directory -Path C:\GitHub -Force | Out-Null
Set-Location C:\GitHub

git clone https://github.com/jmiconi/windows-infra-automation.git
Set-Location C:\GitHub\windows-infra-automation
```

### 3. Allow scripts for the current PowerShell process

This does not change the machine-wide execution policy:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

### 4. Run the Group Policy diagnostic

```powershell
.\gpo\get-gpo-processing-summary.ps1
```

The script reads the `Microsoft-Windows-GroupPolicy/Operational` log and filters extension-processing events `4016` and `5016`.

On a clean standalone server there may be no matching extension events. In that case the script reports that no matching events were found instead of returning silently.

To generate a normal policy refresh for testing:

```powershell
gpupdate /force
```

A successful policy refresh does **not** guarantee that events `4016` or `5016` will exist; those IDs depend on Group Policy client-side extension processing.

### 5. Install the Active Directory PowerShell module

The Active Directory inventory script requires `RSAT-AD-PowerShell`:

```powershell
Install-WindowsFeature RSAT-AD-PowerShell

Get-WindowsFeature RSAT-AD-PowerShell
Import-Module ActiveDirectory
```

Installing the module alone is not enough to query AD. The host must also be able to reach an Active Directory domain controller with Active Directory Web Services available.

### 6. Run the stale-computer inventory

Against an authorized Active Directory environment:

```powershell
.\active-directory\find-stale-computers.ps1 -InactiveDays 60
```

Limit the query to a specific OU when appropriate:

```powershell
.\active-directory\find-stale-computers.ps1 `
  -InactiveDays 60 `
  -SearchBase "OU=TestComputers,DC=example,DC=local"
```

The script is read-only. It reports enabled computer accounts whose `LastLogonDate` is either missing or older than the requested threshold.

If Active Directory cannot be reached, the script returns a clear connectivity/ADWS error rather than continuing with an unhandled `Get-ADComputer` exception.

## Example: stale computer inventory

`active-directory/find-stale-computers.ps1` identifies inactive computer accounts without deleting or modifying them. The default behavior is deliberately **read-only**.

## Example: GPO processing diagnostics

`gpo/get-gpo-processing-summary.ps1` reads the Group Policy operational log and surfaces extension processing times, useful when investigating slow logons or policy refreshes.

## Engineering principles

- Read-only by default
- Explicit parameters instead of hard-coded environment values
- Useful console output before automation is made destructive
- Event logs as first-class diagnostic evidence
- Separation between discovery, decision and remediation
- Validate documented procedures from a clean VM before claiming reproducibility

## Validation

See [`VALIDATION.md`](VALIDATION.md) for the clean Windows Server 2022 validation record, tested versions, observed failure modes and current validation scope.

## Next iterations

- Local Administrators drift audit
- Domain post-install workflow
- Application deployment helpers
- Printer/GPO diagnostics
- Structured CSV/JSON output

## Security

All examples are sanitized and designed to be adapted to a lab or authorized environment. Review scripts before using them in production.
