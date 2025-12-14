Clear-Host

# ──────────────────────────────
# Color Definitions
# ──────────────────────────────
$lilac = "Magenta"
$lightBlue = "Cyan"

# ──────────────────────────────
# Log File Setup
# ──────────────────────────────
$desktop = [Environment]::GetFolderPath("Desktop")
$logFile = Join-Path $desktop "WindowsTunerVerboseLog.txt"
"Windows Tuner Verbose Log" | Out-File $logFile

# ──────────────────────────────
# Startup Review Flow
# ──────────────────────────────
$summary = @"
Windows Tuner will:
 - Create a restore point
 - Apply O&O ShutUp10++ recommended privacy settings
 - Run Chris Titus Tech WinUtil recommended preset
 - Add the Ultimate Performance power plan
 - Apply registry performance tweaks (CPU/GPU priority, responsiveness)
 - Optimize gaming settings (HAGS, Game Mode, fullscreen optimizations)
 - Install Scoop package manager
 - Run Windows Defender quick scan
 - Run Disk Cleanup
 - Run System File Checker
"@

Write-Host $summary -ForegroundColor $lilac
$response = Read-Host "Do you want to review the full script before execution? (Y/N)"

if ($response -eq "Y" -or $response -eq "y") {
    $scriptPath = $MyInvocation.MyCommand.Path
    Get-Content $scriptPath | more
    $execute = Read-Host "Do you want to execute the script now? (Y/N)"
    if ($execute -ne "Y" -and $execute -ne "y") { exit }
}
elseif ($response -eq "N" -or $response -eq "n") {
    $execute = Read-Host "Do you want to execute the script now? (Y/N)"
    if ($execute -ne "Y" -and $execute -ne "y") { exit }
}
else { exit }

# ──────────────────────────────
# Dependency Scan & Auto-Install
# ──────────────────────────────
Write-Host "Checking dependencies..." -ForegroundColor $lightBlue

# Check for O&O ShutUp10++
$ooPath = "OOSU10.exe"
if (-not (Test-Path $ooPath)) {
    Write-Host "    │ O&O ShutUp10++ not found. Downloading..." -ForegroundColor $lilac
    Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $ooPath
    "Downloaded O&O ShutUp10++ (latest build)." | Add-Content $logFile
} else {
    Write-Host "    │ O&O ShutUp10++ found." -ForegroundColor $lilac
    "O&O ShutUp10++ already present." | Add-Content $logFile
}

# Check for Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "    │ Scoop not found. Installing..." -ForegroundColor $lilac
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    "Installed Scoop package manager." | Add-Content $logFile
} else {
    Write-Host "    │ Scoop found." -ForegroundColor $lilac
    "Scoop already present." | Add-Content $logFile
}

# Log Scoop version if available
try {
    $scoopVersion = scoop --version
    "Detected Scoop version: $scoopVersion" | Add-Content $logFile
} catch {
    "Could not detect Scoop version." | Add-Content $logFile
}

# Check for Chris Titus Tech WinUtil alias
if (-not (Get-Alias winutil -ErrorAction SilentlyContinue)) {
    Write-Host "    │ WinUtil alias not found. Creating..." -ForegroundColor $lilac
    Set-Alias winutil "Invoke-WebRequest"
    "Created WinUtil alias." | Add-Content $logFile
} else {
    Write-Host "    │ WinUtil alias found." -ForegroundColor $lilac
    "WinUtil alias already present." | Add-Content $logFile
}

# ──────────────────────────────
# Layout Rendering Functions
# ──────────────────────────────
function Show-TitleBox {
    Write-Host "    ┌─────────────────────────────┐" -ForegroundColor $lightBlue
    Write-Host "    │        Windows Tuner        │" -ForegroundColor $lightBlue
    Write-Host "    └─────────────────────────────┘" -ForegroundColor $lightBlue
}
function Show-LogsHeader { Write-Host "    ┌─ Verbose Logs ──────────────┐" -ForegroundColor $lightBlue }
function Show-LogsFooter { Write-Host "    └─────────────────────────────┘" -ForegroundColor $lightBlue }
function Render-ProgressBar($current, $total, $taskName) {
    $percent = [math]::Round(($current / $total) * 100)
    $progressBarWidth = 20
    $filled = [math]::Floor(($percent / 100) * $progressBarWidth)
    $empty = $progressBarWidth - $filled
    $bar = ("=" * $filled) + ">" + ("-" * ($empty - 1))
    Write-Host "    ┌─ Progress ──────────────────┐" -ForegroundColor $lightBlue
    Write-Host ("    │   Task $current/$total [$bar] $percent% │") -ForegroundColor $lilac
    Write-Host "    └─────────────────────────────┘" -ForegroundColor $lightBlue
}

# ──────────────────────────────
# Task Functions
# ──────────────────────────────
function Create-RestorePoint {
    try {
        Checkpoint-Computer -Description "PreAutoTune" -RestorePointType "MODIFY_SETTINGS"
        Write-Host "    │ [✔] Restore point created successfully." -ForegroundColor $lilac
        "Restore point created successfully." | Add-Content $logFile
    }
    catch {
        Write-Host "    │ [✗] Failed to create restore point. Exiting script." -ForegroundColor Red
        "Failed to create restore point. Script exited." | Add-Content $logFile
        exit
    }
}
function Apply-ShutUp10 {
    Start-Process -FilePath "OOSU10.exe" -ArgumentList "/applyrecommended" -Wait
    "Applied O&O ShutUp10++ recommended settings." | Add-Content $logFile
}
function Run-WinUtil {
    Set-Alias winutil "Invoke-WebRequest"
    winutil https://christitus.com/win | Invoke-Expression
    "Ran Chris Titus Tech WinUtil recommended preset." | Add-Content $logFile
}
function Add-UltimatePerformancePlan {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    Start-Process "control.exe" -ArgumentList "powercfg.cpl"
    "Added Ultimate Performance power plan." | Add-Content $logFile
}
function Apply-RegistryTweaks {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 8
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 6
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 10
    "Applied registry performance tweaks." | Add-Content $logFile
}
function Optimize-GamingSettings {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2
    "Optimized gaming settings (HAGS, Game Mode, fullscreen optimizations)." | Add-Content $logFile
}
function Install-Scoop {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    "Installed Scoop package manager." | Add-Content $logFile
}
function Run-DefenderQuickScan {
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList "Start-MpScan -ScanType QuickScan" -Wait
        Write-Host "    │ [✔] Windows Defender quick scan started." -ForegroundColor $lilac
        "Ran Windows Defender quick scan." | Add-Content $logFile
    }
    catch {
        Write-Host "    │ [✗] Failed to start Defender quick scan: $_" -ForegroundColor Red
        "Failed to start Defender quick scan: $_" | Add-Content $logFile
    }
}
function Run-DiskCleanup {
    try {
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
        Write-Host "    │ [✔] Disk Cleanup executed." -ForegroundColor $lilac
        "Ran Disk Cleanup (cleanmgr)." | Add-Content $logFile
    }
    catch {
        Write-Host "    │ [✗] Disk Cleanup failed: $_" -ForegroundColor Red
        "Disk Cleanup failed: $_" | Add-Content $logFile
    }
}
function Run-SystemFileChecker {
    try {
        Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait
        Write-Host "    │ [✔] System File Checker executed." -ForegroundColor $lilac
        "Ran System File Checker (sfc /scannow)." | Add-Content $logFile
    }
    catch {
        Write-Host "    │ [✗] System File Checker failed: $_" -ForegroundColor Red
        "System File Checker failed: $_" | Add-Content $logFile
    }
}

# ──────────────────────────────
# Main Execution
# ──────────────────────────────
Show-TitleBox
Show-LogsHeader

$tasks = @(
    @{Name="Create Restore Point"; Action={Create-RestorePoint}},
    @{Name="Apply O&O ShutUp10 Recommended"; Action={Apply-ShutUp10}},
    @{Name="Run CTT WinUtil Recommended"; Action={Run-WinUtil}},
    @{Name="Add Ultimate Performance Power Plan"; Action={Add-UltimatePerformancePlan}},
    @{Name="Apply Registry Performance Tweaks"; Action={Apply-RegistryTweaks}},
    @{Name="Optimize Gaming Settings"; Action={Optimize-GamingSettings}},
    @{Name="Install Scoop & Alias WinUtil"; Action={Install-Scoop}},
    @{Name="Run Windows Defender Quick Scan"; Action={Run-DefenderQuickScan}},
    @{Name="Run Disk Cleanup"; Action={Run-DiskCleanup}},
    @{Name="Run System File Checker"; Action={Run-SystemFileChecker}}
)

$totalTasks = $tasks.Count
$currentTaskIndex = 0
$startTime = Get-Date

foreach ($task in $tasks) {
    $currentTaskIndex++
    try {
        & $task.Action
        if ($task.Name -ne "Create Restore Point") {
            Write-Host ("    │ [✔] {0} completed." -f $task.Name) -ForegroundColor $lilac
        }
    }
    catch {
        Write-Host ("    │ [✗] {0} failed: $_" -f $task.Name) -ForegroundColor Red
        ("{0} failed: $_" -f $task.Name) | Add-Content $logFile
    }
    Render-ProgressBar $currentTaskIndex $totalTasks $task.Name
}

Show-LogsFooter

# ──────────────────────────────
# Append Revert Instructions Prompt
# ──────────────────────────────
$printRevert = Read-Host "Print Revert Instructions to top of log file at $logFile ? (Y/N)"

if ($printRevert -eq "Y" -or $printRevert -eq "y") {
    $revertInstructions = @"
Revert Instructions (one-liners):

- Restore Point: Use System Restore from Control Panel to roll back.
- ShutUp10++: Re-run OOSU10.exe and choose 'Undo recommended settings'.
- WinUtil: Re-run Chris Titus Tech WinUtil and select 'Defaults'.
- Ultimate Performance Plan: powercfg -delete e9a42b02-d5df-448d-aa00-03f14749eb61
- Registry Tweaks: Reset values in HKLM paths to Windows defaults (Win32PrioritySeparation=2, SystemResponsiveness=20, etc.)
- HAGS: Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 1
- Game Mode: Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0
- Fullscreen Optimizations: Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 0
- Scoop: Remove-Item -Recurse -Force "$env:USERPROFILE\scoop"
- Defender Quick Scan: No revert needed; it only scans.
- Disk Cleanup: No revert needed; it only deletes temp files.
- System File Checker: No revert needed; it only repairs system files.
"@

    $existing = Get-Content $logFile
    $revertInstructions + "`r`n" + ($existing -join "`r`n") | Set-Content $logFile
}

# ──────────────────────────────
# Completion Footer
# ──────────────────────────────
$elapsed = (Get-Date) - $startTime
Write-Host "    ┌─────────────────────────────┐" -ForegroundColor $lightBlue
Write-Host ("    │   All tasks finished!       │") -ForegroundColor $lightBlue
Write-Host ("    │   Total time: $($elapsed)   │") -ForegroundColor $lilac
Write-Host "    └─────────────────────────────┘" -ForegroundColor $lightBlue
