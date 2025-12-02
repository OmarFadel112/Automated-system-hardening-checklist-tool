# HardeningAudit_Final.ps1
# Comprehensive System Hardening Audit
# Covers: Network, Disk, System, Services, Logging, and Peripherals

# --- 1. DATA STRUCTURE ---
$results = @()

function Add-Result {
    param (
        [string]$Id,
        [string]$Description,
        [string]$Status,
        [string]$Remediation
    )
    
    # We use $script: scope to ensure the function writes to the main array
    $script:results += [pscustomobject]@{
        Id          = $Id
        Description = $Description
        Status      = $Status
        Remediation = $Remediation
    }
}

# --- 2. SECURITY CHECKS ---

# [Network] Windows Firewall
function Check-Firewall {
    try {
        $fw = (Get-NetFirewallProfile -Profile Domain,Public,Private)
        if ($fw.Enabled -notcontains $false) { 
            Add-Result "NET-01" "Windows Firewall Enabled" "Pass" "None" 
        } else { 
            Add-Result "NET-01" "Windows Firewall Enabled" "Fail" "Enable via: Set-NetFirewallProfile -Enabled True" 
        }
    } catch {
        Add-Result "NET-01" "Windows Firewall Enabled" "Warn" "Error reading firewall state"
    }
}

# [Storage] BitLocker Encryption
function Check-BitLocker {
    try {
        $bitlocker = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
        if ($bitlocker.ProtectionStatus -eq "On") {
            Add-Result "DSK-01" "BitLocker Encryption (C:)" "Pass" "None"
        } else {
            Add-Result "DSK-01" "BitLocker Encryption (C:)" "Fail" "Enable BitLocker on OS drive"
        }
    } catch {
        Add-Result "DSK-01" "BitLocker Encryption (C:)" "Warn" "BitLocker module not available or admin rights missing"
    }
}

# [System] User Account Control (UAC)
function Check-UAC {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    try {
        $uac = Get-ItemProperty $path -Name "EnableLUA" -ErrorAction Stop
        if ($uac.EnableLUA -eq 1) {
            Add-Result "SYS-01" "User Account Control (UAC)" "Pass" "None"
        } else {
            Add-Result "SYS-01" "User Account Control (UAC)" "Fail" "Set EnableLUA to 1 in Registry"
        }
    } catch {
        Add-Result "SYS-01" "User Account Control (UAC)" "Warn" "Could not read Registry key"
    }
}

# [Services] Deprecated Protocols (Telnet)
function Check-Telnet {
    if (Get-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -ErrorAction SilentlyContinue | Where-Object {$_.State -eq "Enabled"}) {
        Add-Result "SRV-01" "Disable Telnet Client" "Fail" "Uninstall Telnet Client feature"
    } else {
        Add-Result "SRV-01" "Disable Telnet Client" "Pass" "None"
    }
}

# [Endpoint Protection] Windows Defender
function Check-Defender {
    try {
        $defender = Get-MpComputerStatus -ErrorAction Stop
        if ($defender.RealTimeProtectionEnabled -eq $true) {
            Add-Result "AV-01" "Defender Real-Time Protection" "Pass" "None"
        } else {
            Add-Result "AV-01" "Defender Real-Time Protection" "Fail" "Enable Real-Time Protection"
        }
    } catch {
        Add-Result "AV-01" "Defender Real-Time Protection" "Warn" "Could not query Defender status"
    }
}

# [Identity] Guest Account
function Check-GuestAccount {
    try {
        $guest = Get-LocalUser -Name "Guest" -ErrorAction Stop
        if ($guest.Enabled -eq $false) {
            Add-Result "ID-01" "Guest Account Disabled" "Pass" "None"
        } else {
            Add-Result "ID-01" "Guest Account Disabled" "Fail" "Disable Guest account"
        }
    } catch {
        Add-Result "ID-01" "Guest Account Disabled" "Warn" "Could not find Guest account"
    }
}

# [Remote Access] RDP Network Level Authentication
function Check-RDP-NLA {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    try {
        $rdp = Get-ItemProperty $path -Name "UserAuthentication" -ErrorAction Stop
        if ($rdp.UserAuthentication -eq 1) {
            Add-Result "NET-02" "RDP Network Level Auth (NLA)" "Pass" "None"
        } else {
            Add-Result "NET-02" "RDP Network Level Auth (NLA)" "Fail" "Enable NLA in System Properties"
        }
    } catch {
        Add-Result "NET-02" "RDP Network Level Auth (NLA)" "Warn" "Could not read RDP settings"
    }
}

# [Infrastructure] NTP Time Sync
function Check-NTP {
    try {
        $time = Get-Service "w32time"
        if ($time.Status -eq "Running") {
            Add-Result "NTP-01" "NTP Service (Time Sync)" "Pass" "None"
        } else {
            Add-Result "NTP-01" "NTP Service (Time Sync)" "Fail" "Start service 'w32time'"
        }
    } catch {
        Add-Result "NTP-01" "NTP Service (Time Sync)" "Warn" "Could not check time service"
    }
}

# [Services] Print Spooler (Attack Surface Reduction)
function Check-Spooler {
    try {
        $spooler = Get-Service "Spooler" -ErrorAction SilentlyContinue
        if ($spooler.Status -ne "Running") {
            Add-Result "SRV-02" "Print Spooler Disabled" "Pass" "None"
        } else {
            Add-Result "SRV-02" "Print Spooler Disabled" "Fail" "Stop and Disable 'Spooler' service"
        }
    } catch {
        Add-Result "SRV-02" "Print Spooler Disabled" "Pass" "Service not found (Good)"
    }
}

# [Logging] Command Line Auditing
function Check-AuditLogs {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    try {
        $audit = Get-ItemProperty $path -Name "ProcessCreationIncludeCmdLine_Enabled" -ErrorAction Stop
        if ($audit.ProcessCreationIncludeCmdLine_Enabled -eq 1) {
            Add-Result "LOG-01" "Audit Command Line" "Pass" "None"
        } else {
            Add-Result "LOG-01" "Audit Command Line" "Fail" "Enable 'Include command line in process creation events'"
        }
    } catch {
        Add-Result "LOG-01" "Audit Command Line" "Fail" "Enable 'Include command line in process creation events'"
    }
}

# [Peripherals] USB Storage Lock
function Check-USBStorage {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR"
    try {
        $usb = Get-ItemProperty $path -Name "Start" -ErrorAction Stop
        # 4 = Disabled (Locked), 3 = Enabled (Unlocked)
        if ($usb.Start -eq 4) {
            Add-Result "DEV-01" "USB Storage Blocked" "Pass" "None"
        } else {
            Add-Result "DEV-01" "USB Storage Blocked" "Fail" "Set HKLM...USBSTOR\Start to 4"
        }
    } catch {
        Add-Result "DEV-01" "USB Storage Blocked" "Warn" "USBSTOR Registry key not found"
    }
}

# --- 3. EXECUTION PIPELINE ---

Write-Host "Starting Comprehensive Audit..." -ForegroundColor Cyan

Check-Firewall
Check-BitLocker
Check-UAC
Check-Telnet
Check-Defender
Check-GuestAccount
Check-RDP-NLA
Check-NTP
Check-Spooler
Check-AuditLogs
Check-USBStorage

# --- 4. REPORT GENERATION ---

$htmlHeader = @"
<html><head><title>System Hardening Report</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; padding: 20px; background-color: #f9f9f9; }
    h2 { color: #333; }
    table { border-collapse: collapse; width: 100%; box-shadow: 0 2px 15px rgba(0,0,0,0.1); background-color: white; }
    th { background-color: #0078D4; color: #ffffff; text-align: left; padding: 12px 15px; }
    td { padding: 12px 15px; border-bottom: 1px solid #dddddd; color: #333; }
    tr:nth-of-type(even) { background-color: #f3f3f3; }
    .Pass { color: #107C10; font-weight: bold; } /* Green */
    .Fail { color: #D83B01; font-weight: bold; } /* Red-Orange */
    .Warn { color: #FFB900; font-weight: bold; } /* Yellow-Gold */
</style></head><body>
<h2>System Hardening Audit Report</h2>
<table><tr><th>ID</th><th>Check</th><th>Status</th><th>Remediation</th></tr>
"@

$htmlRows = $results | ForEach-Object {
    "<tr><td>$($_.Id)</td><td>$($_.Description)</td><td class='$($_.Status)'>$($_.Status)</td><td>$($_.Remediation)</td></tr>"
}

$htmlFooter = "</table></body></html>"

$finalReport = $htmlHeader + ($htmlRows -join "") + $htmlFooter
$reportPath = Join-Path $PSScriptRoot "FullAuditReport.html"

$finalReport | Out-File -FilePath $reportPath -Encoding UTF8
Invoke-Item $reportPath