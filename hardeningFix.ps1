# HardeningFix.ps1
# Applies security fixes to the system
# WARNING: This modifies system configurations!

Write-Host "Starting System Remediation..." -ForegroundColor Cyan

# 1. Enable Windows Firewall (All Profiles)
function Fix-Firewall {
    Write-Host "Enabling Windows Firewall..." -NoNewline
    try {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Host "Error: $_"
    }
}

# 2. Block USB Storage
function Fix-USBStorage {
    Write-Host "Blocking USB Storage Drivers..." -NoNewline
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR"
    try {
        # Set 'Start' to 4 (Disabled)
        Set-ItemProperty -Path $path -Name "Start" -Value 4 -ErrorAction Stop
        Write-Host " [DONE]" -ForegroundColor Green
        Write-Host "   -> NOTE: You may need to restart for this to apply." -ForegroundColor Gray
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# 3. Disable Guest Account
function Fix-GuestAccount {
    Write-Host "Disabling Guest Account..." -NoNewline
    try {
        Disable-LocalUser -Name "Guest" -ErrorAction Stop
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [Skipped] (Account not active or found)" -ForegroundColor Yellow
    }
}

# 4. Disable Print Spooler
function Fix-Spooler {
    Write-Host "Stopping Print Spooler..." -NoNewline
    try {
        Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "Spooler" -StartupType Disabled
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# 5. Enable Audit Logs (THIS WAS MISSING BEFORE)
function Fix-AuditLogs {
    Write-Host "Enabling Command Line Auditing..." -NoNewline
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    try {
        if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 -ErrorAction Stop
        Write-Host " [DONE]" -ForegroundColor Green
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
    }
}

# --- EXECUTION ---

Fix-Firewall
Fix-GuestAccount
Fix-AuditLogs
Fix-Spooler
Fix-USBStorage 

Write-Host "`nRemediation Complete. Please re-run Check to verify." -ForegroundColor Cyan