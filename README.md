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
└── README.md
```

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

## Next iterations

- Local Administrators drift audit
- Domain post-install workflow
- Application deployment helpers
- Printer/GPO diagnostics
- Structured CSV/JSON output

## Security

All examples are sanitized and designed to be adapted to a lab or authorized environment. Review scripts before using them in production.
