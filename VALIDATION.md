# Validation Record

This file records hands-on validation of the published repository workflow.

The goal is simple: if the repository says a workflow works, it should be exercised from a clean lab baseline and the observed behavior should be documented.

## Validation run — 2026-08-20

### Environment

- Hypervisor: VMware lab VM
- Operating system: Windows Server 2022 Standard Evaluation
- OS build: 20348
- Shell: Windows PowerShell 5.1
- Initial state: clean server installation
- Initial Git state: not installed
- Initial `winget` state: not installed
- Built-in `curl.exe`: available, version 7.79.1.0
- Git for Windows used during validation: 2.55.0.windows.3
- Repository branch: `main`

The baseline was intentionally created before installing Git, RSAT or Active Directory Domain Services.

## Clean baseline checks

| Check | Result |
|---|---|
| Windows Server boots normally | PASS |
| IPv4 networking available | PASS |
| DNS resolution available | PASS |
| Windows PowerShell 5.1 available | PASS |
| Git preinstalled | NO |
| `winget` preinstalled | NO |
| `curl.exe` available | YES |
| `RSAT-AD-PowerShell` preinstalled | NO |
| `AD-Domain-Services` preinstalled | NO |

### Finding: Git bootstrap

A clean Windows Server 2022 installation in this test did not include Git or `winget`.

Git for Windows was installed with its official installer. After installation, a **new PowerShell session** was required for the updated `PATH` to be visible.

This was not considered an installer failure.

## Repository checkout

The repository was cloned into:

```text
C:\GitHub\windows-infra-automation
```

Validation after clone:

```text
branch: main
working tree: clean
```

The repository contained the expected Active Directory, GPO and documentation files.

## Group Policy diagnostic validation

Script:

```text
gpo/get-gpo-processing-summary.ps1
```

### Standalone-server test

The Group Policy Operational log was confirmed to exist and be enabled:

```text
Microsoft-Windows-GroupPolicy/Operational
Enabled: True
Record count observed: 111
```

The log contained normal Group Policy lifecycle events, including IDs such as `4001`, `4126`, `5117`, `5312`, `5313`, `5320`, `6338`, `6339` and `8001`.

The published script intentionally filters only events:

```text
4016
5016
```

On the clean standalone server, no matching `4016/5016` events were present. Running:

```powershell
gpupdate /force
```

completed successfully for both computer and user policy, but still did not produce matching `4016/5016` events.

### Finding

The original script completed successfully but returned no visible output when no matching events existed.

The script was updated to:

- validate `MaxEvents`
- handle event-log read failures explicitly
- report when no `4016/5016` events are present

This clarifies that a successful `gpupdate` does not imply that those specific extension-processing event IDs will exist.

### Result

**PASS** — script executes safely on Windows Server 2022 and handles the no-matching-events condition explicitly.

## Active Directory script validation

Script:

```text
active-directory/find-stale-computers.ps1
```

### RSAT-only test

`RSAT-AD-PowerShell` was installed successfully:

```powershell
Install-WindowsFeature RSAT-AD-PowerShell
```

The `ActiveDirectory` module imported, but on the standalone server it reported that no default server running Active Directory Web Services could be found.

Executing the original stale-computer script produced the expected real-world failure:

```text
ADServerDownException
ActiveDirectoryServer:1355
```

### Finding

Having the PowerShell module installed is not sufficient. The script also requires connectivity to a domain controller running Active Directory Web Services.

The script was updated to:

- validate `InactiveDays`
- report a clear error if the Active Directory module is unavailable
- report a clear connectivity/ADWS error if `Get-ADComputer` cannot query AD
- explicitly report when no stale accounts match

## Lab Active Directory validation

The same disposable VM was promoted into an isolated lab forest solely to validate AD query behavior.

Lab values were fictitious and are not production values.

Lab configuration:

```text
Domain: infralab.local
NetBIOS: INFRALAB
DC: LAB-DC01
```

Health checks:

- `Get-ADDomain` — PASS
- `Get-ADForest` — PASS
- ADWS service — Running
- DNS service — Running
- NTDS service — Running
- `dcdiag /test:advertising` — PASS
- `dcdiag /test:dns` — PASS

A dedicated test OU was created with three enabled computer accounts whose `LastLogonDate` values were empty.

Running:

```powershell
.\active-directory\find-stale-computers.ps1 `
  -InactiveDays 60 `
  -SearchBase "OU=TestComputers,DC=infralab,DC=local"
```

returned all three accounts, as expected from the script logic:

```powershell
-not $_.LastLogonDate -or $_.LastLogonDate -lt $cutoff
```

### Protected timestamp test finding

An attempt to directly set `lastLogonTimestamp` with `Set-ADObject` was rejected by Active Directory because the attribute is managed by SAM.

The test procedure did **not** bypass or force modification of that protected attribute.

A second domain-member VM was intentionally not added solely to manufacture recent-logon data.

### Validation scope

Validated directly:

- Active Directory module dependency
- behavior when no domain controller is available
- ADWS connectivity requirement
- successful real AD query
- `SearchBase` behavior
- enabled accounts with missing `LastLogonDate`
- read-only operation
- parameter/error-handling paths added after testing

Not directly exercised in this run:

- the time-boundary case where a real computer account has a recent `LastLogonDate` and must be excluded
- the time-boundary case where a real historical `LastLogonDate` is older than the threshold

Those conditions remain represented by the straightforward cutoff comparison in the script, but were not artificially modified in AD for this validation.

## Current status

**PASS WITH DOCUMENTED SCOPE**

The current published workflows are reproducible from a clean Windows Server 2022 baseline for the behaviors exercised above. The repository now documents its prerequisites, clean-server bootstrap behavior, AD connectivity requirement, known validation scope and observed failure modes.

## Revalidation policy

Repeat clean-VM validation when changes affect any of the following:

- Windows Server prerequisites
- Git/bootstrap instructions
- PowerShell execution requirements
- Active Directory module dependencies
- AD query/filter logic
- Group Policy event IDs or event-log handling
- destructive/remediation behavior
