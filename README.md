
# ACHILLES

### Automated System Hardening Checklist Tool

**ACHILLES** is a PowerShell-based system hardening automation tool that establishes, verifies, and continuously restores a system’s **Root of Trust** using globally recognized security standards.

It converts security frameworks into **actionable checks**, **automated remediation**, and **clear compliance reporting**.

---

## Key Features

* ✅ Standards-based system hardening
* 🔍 Automated security audits (Pass / Fail)
* 🛠️ One-click remediation
* 📄 HTML compliance reports
* 🔄 Drift detection & recovery
* 🪟 Native Windows PowerShell support

---
Deploy & Operate ACHILLES 
______________
Deployment & Operation Guide
Supported Systems
•	Windows 10 / 11
•	Windows Server
•	PowerShell 5.1+
⚠️ Administrator privileges required
______________
Step 1 — Clone or Download

git clone https://github.com/OmarFadel112/Automated-system-hardening-checklist-tool.git

cd Automated-system-hardening-checklist-tool

______________
Step 2 — Allow Script Execution

Set-ExecutionPolicy RemoteSigned

Why this is required:

PowerShell blocks unsigned scripts by default.

RemoteSigned allows:

•	Local scripts → run without signing

•	Downloaded scripts → must be signed

This is the minimum safe execution policy for PowerShell automation.
______________
Security Note
ACHILLES modifies system-level registry keys and security policies. Some changes (e.g., USB storage, firewall rules, encryption) may impact normal system behavior.
---
## Why ACHILLES Exists

Security breaches are rarely caused by broken software — they are caused by **misconfiguration**.

* Default settings are insecure
* Manual hardening does not scale
* Hardened systems drift over time

ACHILLES solves this by enforcing **repeatable, auditable, and automated hardening**.

---

## Hardening Philosophy

Hardening is **not a one-time checklist**.

ACHILLES treats hardening as a **closed-loop lifecycle**:

1. Establish a secure baseline
2. Continuously audit the system
3. Detect configuration drift
4. Automatically remediate deviations
5. Restore the Root of Trust

---

## Hardening Domains

ACHILLES organizes security controls into **four critical domains** to ensure complete coverage.

### 1️⃣ Identity & Access

* Disable guest and anonymous accounts
* Enforce least privilege (UAC)
* Control user access paths

**Mapped Standards**

* NIST AC-2
* ISO 27001 A.9.2
* DISA STIGs

---

### 2️⃣ Data & Physical Security

* Enforce full disk encryption (BitLocker)
* Protect data at rest from physical compromise

**Mapped Standards**

* NIST 800-171 (3.13.11)
* CIS Benchmarks

---

### 3️⃣ Attack Surface Reduction

* Enable host-based firewalls
* Disable legacy and unnecessary services
* Block removable storage (USB)

**Mapped Standards**

* NIST CM-7 (Least Functionality)
* ISO 27001 A.12.6.1

---

### 4️⃣ Visibility & Auditing

* Compliance status reporting
* Logging and audit readiness
* Clear security posture visibility

---

## Standards & Frameworks

ACHILLES strictly aligns with:

* **NIST SP 800-53**
* **ISO/IEC 27001**
* **DISA STIGs**
* **CIS Benchmarks**

No assumptions. No guessing. Only prescriptive guidance.

---

## Automation Workflow

ACHILLES uses a **PowerShell-based checklist automation engine**.

### Workflow Overview

1. **Audit**

   * Scans the system against the defined baseline

2. **Report**

   * Generates an HTML compliance report (Pass / Fail)

3. **Remediate**

   * Automatically applies secure configurations
   * Restores the trusted baseline

---

## Example Use Cases

* Windows endpoint hardening
* Pre-deployment system validation
* Compliance preparation (ISO / NIST / CIS)
* Drift detection after updates
* Blue team / SOC baseline enforcement

---

## Requirements

* Windows OS
* PowerShell 5.1+
* Administrative privileges

---

## Disclaimer

ACHILLES applies **system-level security changes**.
Always review controls and test in a non-production environment before deployment.

---

## Project Status

This project is under active development and intended for:

* Cybersecurity learning
* Internal hardening automation
* Blue team and defensive security use cases

---

## License

This project is licensed under the MIT License.

Copyright (c) 2025 Mousa M. Mousa, Omar Fadel, Marwan Ramadan, Fares Sobhy.


