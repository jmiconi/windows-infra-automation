# Architecture

The repository separates infrastructure work into three stages:

1. **Discovery** — collect state from Active Directory, Windows hosts or event logs.
2. **Decision** — filter, classify and report what requires attention.
3. **Remediation** — only after validation, perform an explicit authorized change.

```text
          +------------------+
          |  Operator / Job  |
          +--------+---------+
                   |
                   v
          +------------------+
          | PowerShell Layer |
          +---+----------+---+
              |          |
        +-----+--+    +--+--------+
        |   AD   |    | Event Logs|
        +-----+--+    +--+--------+
              |          |
              +-----+----+
                    |
                    v
              Structured output
```

## Why this design

Operational scripts become safer when inventory and diagnosis are separated from modification. The examples therefore avoid hidden environment dependencies and destructive defaults.
