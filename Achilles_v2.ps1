

# --- 1. CONFIGURATION ---
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "PRJKT ACHILLES || Automated System Hardening"
$global:ESC = [char]27
$global:ScriptPath = $PSScriptRoot
$script:HueOffset = 0

# --- FILE NAMES (Ensure these match your files) ---
$File_Check  = "hardening-check.ps1"
$File_Fix    = "hardeningFix.ps1"
$File_Revert = "hardening_revert.ps1"

# --- 2. AUTO-FIX PERMISSIONS ---
# This block attempts to unblock your external files so Windows trusts them
try {
    $files = @($File_Check, $File_Fix, $File_Revert)
    foreach ($f in $files) {
        $path = Join-Path $global:ScriptPath $f
        if (Test-Path $path) {
            Unblock-File -Path $path -ErrorAction SilentlyContinue
        }
    }
} catch { }

# --- 3. GRAPHICS ENGINE ---

function Get-RainbowRGB {
    param([int]$Offset)
    $h = $Offset % 360
    $s = 1.0; $v = 1.0
    $c = $v * $s
    $x = $c * (1 - [Math]::Abs(($h / 60) % 2 - 1))
    $m = $v - $c
    $r=0; $g=0; $b=0
    
    if     ($h -lt 60)  { $r=$c; $g=$x; $b=0 }
    elseif ($h -lt 120) { $r=$x; $g=$c; $b=0 }
    elseif ($h -lt 180) { $r=0; $g=$c; $b=$x }
    elseif ($h -lt 240) { $r=0; $g=$x; $b=$c }
    elseif ($h -lt 300) { $r=$x; $g=0; $b=$c }
    else                { $r=$c; $g=0; $b=$x }
    
    return @([int](($r+$m)*255), [int](($g+$m)*255), [int](($b+$m)*255))
}

function Write-Gradient {
    param([string]$Text, [int[]]$StartRGB, [int[]]$EndRGB, [switch]$NewLine)
    $len = $Text.Length; if ($len -eq 0) { return }
    $out = ""
    for ($i = 0; $i -lt $len; $i++) {
        $r = [int]($StartRGB[0] + ($EndRGB[0] - $StartRGB[0]) * ($i / $len))
        $g = [int]($StartRGB[1] + ($EndRGB[1] - $StartRGB[1]) * ($i / $len))
        $b = [int]($StartRGB[2] + ($EndRGB[2] - $StartRGB[2]) * ($i / $len))
        $out += "$global:ESC[38;2;$r;$g;${b}m" + $Text[$i]
    }
    $out += "$global:ESC[0m"
    if ($NewLine) { Write-Host $out } else { Write-Host $out -NoNewline }
}

function Get-TechPattern {
    param([int]$Length)
    if ($Length -le 0) { return "" }
    $chars = @('0', '1', '.', ':', '+', '-', ' ') 
    $out = ""; for ($i=0; $i -lt $Length; $i++) {
        if ((Get-Random -Min 0 -Max 10) -gt 6) { $out += $chars[(Get-Random -Min 0 -Max $chars.Count)] } else { $out += " " }
    }
    return $out
}

function Draw-Header {
    Clear-Host
    Write-Host "`n"
    
    $PrimaryColor = Get-RainbowRGB -Offset $script:HueOffset
    $SecondaryColor = Get-RainbowRGB -Offset ($script:HueOffset + 60)

    # --- ASSETS ---
    $Logo = @(
        "        _____________________        ",
        "       |  _________________  |       ",
        "       | |   _.--'''--._   | |       ",
        "       | | .'  _     _  '. | |       ",
        "       | |/   (O)___(O)   \| |       ",
        "       | |   /    ^    \   | |       ",
        "       | |   \  \___/  /   | |       ",
        "       | |    '.     .'    | |       ",
        "       | |      '---'      | |       ",
        "       | |   CAIRO UNIV.   | |       ",
        "       | |_________________| |       ",
        "       |_____________________|       "
    )
    $Banner = @(
        " ___  ___     _  _  _____    _   ___ _  _ ___ _    _    ___ ___ ",
        "| _ \| _ \ _ | || |/ /_ _|  /_\ / __| || |_ _| |  | |  | __/ __|",
        "|  _/|   /| || || ' < | |  / _ \ (__| __ || || |__| |__| _|\__ \",
        "|_|  |_|_\ \__/ |_|\_\|_| /_/ \_\___|_||_|___|____|____|___|___/"
    )
    $Helmet = @(
        "          ,    ",
        "       ,;^'    ",
        "     ,;::;     ",
        "   ,;:::;  _   ",
        "  /::::/  | |  ",
        " /____|   |_|  ",
        " \    |   | |  ",
        "  `.  |   | |  ",
        "    `-|___|_|  "
    )

    # --- RENDER ---
    $w = $Host.UI.RawUI.WindowSize.Width; if ($w -eq $null) { $w = 100 } 

    foreach ($line in $Logo) {
        $pad = [Math]::Max(0, [int](($w - $line.Length) / 2))
        $pat = Get-TechPattern -Length ($pad - 2)
        Write-Host $pat -NoNewline -ForegroundColor DarkGray
        Write-Gradient -Text $line -StartRGB @(0,51,102) -EndRGB @(218,165,32) 
        Write-Host $pat -ForegroundColor DarkGray
    }
    Write-Host "`n"

    foreach ($line in $Banner) {
        $pad = [Math]::Max(0, [int](($w - $line.Length) / 2))
        $pat = Get-TechPattern -Length ($pad - 2)
        Write-Host $pat -NoNewline -ForegroundColor DarkGray
        Write-Gradient -Text $line -StartRGB $PrimaryColor -EndRGB $SecondaryColor
        Write-Host $pat -ForegroundColor DarkGray
    }
    Write-Host "`n"

    foreach ($line in $Helmet) {
        $pad = [Math]::Max(0, [int](($w - $line.Length) / 2))
        $pat = Get-TechPattern -Length ($pad - 2)
        Write-Host $pat -NoNewline -ForegroundColor DarkGray
        Write-Gradient -Text $line -StartRGB $SecondaryColor -EndRGB $PrimaryColor
        Write-Host $pat -ForegroundColor DarkGray
    }

    Write-Host "`n"
    
    $TitleText = "Automated system hardening checklist tool"
    $padT = [Math]::Max(0, [int](($w - $TitleText.Length) / 2))
    Write-Host (" " * $padT) -NoNewline
    Write-Gradient -Text $TitleText -StartRGB @(0,255,255) -EndRGB @(0,100,255) -NewLine
    
    $SloganText = "No Pact, just protection"
    $padS = [Math]::Max(0, [int](($w - $SloganText.Length) / 2))
    Write-Host (" " * $padS) -NoNewline
    Write-Gradient -Text $SloganText -StartRGB @(150,150,150) -EndRGB @(80,80,80) -NewLine

    Write-Host "`n"
    $TeamNames = "Omar | Fares | Marwan | Mousa"
    $padN = [Math]::Max(0, [int](($w - $TeamNames.Length) / 2))
    Write-Host (" " * $padN) -NoNewline
    Write-Gradient -Text $TeamNames -StartRGB @(0,255,100) -EndRGB @(0,100,255) -NewLine

    $bar = "=" * ($w - 1)
    Write-Gradient -Text $bar -StartRGB @(50,50,50) -EndRGB @(100,100,100) -NewLine
}

# --- 4. MODULE LAUNCHER (FIXED) ---

function Run-ExternalScript {
    param([string]$FileName)
    
    $FullPath = Join-Path $global:ScriptPath $FileName
    
    Write-Host "`n [!] LAUNCHING MODULE: " -NoNewline -ForegroundColor Yellow
    Write-Host $FileName -ForegroundColor White
    Write-Host " " + ("-" * 50) -ForegroundColor DarkGray
    
    if (Test-Path $FullPath) {
        # FIX: We use Start-Process with -ExecutionPolicy Bypass to force the script to run
        # regardless of the system's strict signing policies.
        $proc = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$FullPath`"" -Wait -NoNewWindow -PassThru
        
        if ($proc.ExitCode -ne 0) {
             Write-Host "`n [NOTE] Module exited with code $($proc.ExitCode)." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "`n [ERROR] File not found: $FileName" -ForegroundColor Red
        Write-Host " Please ensure '$FileName' is in the same folder." -ForegroundColor Gray
    }
    
    Write-Host "`n" + ("-" * 50) -ForegroundColor DarkGray
    Write-Host " [OK] Module execution finished. Press Any Key." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# --- 5. MAIN LOOP ---
while ($true) {
    Draw-Header
    
    function Menu-Item {
        param($k, $t, $c) 
        $w = $Host.UI.RawUI.WindowSize.Width; if ($w -eq $null) { $w = 100 }
        $s = "[$k] $t"
        $padVal = [Math]::Max(0, [int](($w - $s.Length)/2))
        $pad = " " * $padVal
        Write-Host $pad -NoNewline
        Write-Host "[$k]" -NoNewline -ForegroundColor White
        Write-Host " $t" -ForegroundColor $c
    }

    Menu-Item "1" "VULNERABILITY SCAN (Check)" "Cyan"
    Menu-Item "2" "EXECUTE HARDENING (Fix)" "Green"
    Menu-Item "3" "REVERT CHANGES (Undo)" "Red"
    Write-Host ""
    Menu-Item "Q" "DISCONNECT" "Gray"
    
    Write-Host "`n"
    $p = " COMMAND > "
    $w = $Host.UI.RawUI.WindowSize.Width; if ($w -eq $null) { $w = 100 }
    $padP = " " * [Math]::Max(0, [int](($w - $p.Length) / 2))
    Write-Host $padP -NoNewline; Write-Host $p -NoNewline -ForegroundColor Yellow
    
    $script:HueOffset += 30
    
    $choice = Read-Host
    switch ($choice) {
        "1" { Run-ExternalScript $File_Check }
        "2" { Run-ExternalScript $File_Fix }
        "3" { Run-ExternalScript $File_Revert }
        "q" { exit }
        "Q" { exit }
    }
}