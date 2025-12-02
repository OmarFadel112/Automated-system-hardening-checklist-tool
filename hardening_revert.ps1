# HardeningRevert.ps1
# RESTORES default settings (Undoes the hardening)

Write-Host "Restoring System Defaults..." -ForegroundColor Cyan

# 1. Unblock USB Storage
function Revert-USBStorage {
    Write-Host "Restoring USB Storage Drivers..." -NoNewline
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR"
    try {
        # Value 3 = Enabled (Default Windows behavior)
        Set-ItemProperty -Path $path -Name "Start" -Value 3 -ErrorAction Stop
        Write-Host " [DONE]" -ForegroundColor Green
        Write-Host "   -> USB drives are now accessible." -ForegroundColor Gray
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# 2. Disable Firewall (Restores to pre-hardened state)
function Revert-Firewall {
    Write-Host "Disabling Windows Firewall..." -NoNewline
    try {
        # Warning: This makes the PC vulnerable again
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# 3. Enable Print Spooler
function Revert-Spooler {
    Write-Host "Enabling Print Spooler..." -NoNewline
    try {
        Set-Service -Name "Spooler" -StartupType Automatic
        Start-Service -Name "Spooler"
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# 4. Enable Guest Account (If it was disabled)
function Revert-GuestAccount {
    Write-Host "Enabling Guest Account..." -NoNewline
    try {
        Enable-LocalUser -Name "Guest" -ErrorAction Stop
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [Skipped] (Guest account not found)" -ForegroundColor Yellow
    }
}

# 5. Disable Audit Logging (The missing piece)
function Revert-AuditLogs {
    Write-Host "Disabling Command Line Auditing..." -NoNewline
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    try {
        # Value 0 = Disabled
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 0 -ErrorAction Stop
        }
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# --- EXECUTION ---

Revert-Firewall
Revert-USBStorage
Revert-GuestAccount
Revert-Spooler
Revert-AuditLogs

Write-Host "`nSystem restored to default (insecure) settings." -ForegroundColor Cyan