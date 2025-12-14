# Windows Tuner Utility
Vibe-Coded by me :D, This is a script generated using an AI. While i did form it using additional requirements, I was not the programmer of this tool. This was created because I want something quick and functional. This uses external tools for help, Credits will be at the bottom.

Windows Tuner Utility is a PowerShell-based automation tool for Windows 10/11. It applies recommended privacy and performance settings, runs built-in diagnostic tools, and provides a one-click way to optimize your environment.

---

## Usage

### Option 1: Run the EXE
1. Download the latest release `.exe` from the repository.
2. Run it directly. The utility will:
   - Display a summary of actions.
   - Prompt you to review the script before execution.
   - Execute each task in sequence with progress bars.
   - Write detailed logs to `WindowsTunerVerboseLog.txt` on your Desktop.

### Option 2: Clone and Run the Script
1. Clone the repository:
   git clone ```https://github.com/MyNamesTJ-git/WindowsTunerUtility.git```
    ```cd WindowsTunerUtility```

3. Run the script with PowerShell:
   ```.\WindowsTunerUtility.ps1```

4. Follow the prompts to review and execute tasks.

---

## How It Works

The utility is structured into functions, each responsible for a specific task. The main execution loop runs them in order and displays progress.

- Create-RestorePoint: Creates a system restore point before changes.
- Apply-ShutUp10: Applies O&O ShutUp10++ recommended privacy settings.
- Run-WinUtil: Runs Chris Titus Tech WinUtil recommended preset.
- Add-UltimatePerformancePlan: Adds the Ultimate Performance power plan.
- Apply-RegistryTweaks: Applies registry tweaks for CPU/GPU responsiveness and networking.
- Optimize-GamingSettings: Enables Hardware Accelerated GPU Scheduling, Game Mode, and fullscreen optimizations.
- Install-Scoop: Installs the Scoop package manager if missing.
- Run-DefenderQuickScan: Starts a Windows Defender quick scan.
- Run-DiskCleanup: Executes Disk Cleanup with preset options.
- Run-SystemFileChecker: Runs sfc /scannow to check system files.

Each function logs its outcome to WindowsTunerVerboseLog.txt. At the end, you can choose to prepend revert instructions to the log file. For full details, see the source script: WindowsTunerUtility.ps1.

---

## Credits

This project builds on the work and recommendations of:

- O&O Software – [O&O ShutUp10++ privacy tool](https://www.oo-software.com/en/shutup10).
- Chris Titus Tech – [WinUtil Windows utility presets](https://github.com/ChrisTitusTech/winutil).
- Microsoft – Built-in tools such as PowerShell, Windows Defender, Disk Cleanup, and System File Checker.

---

## License

This project is licensed under the GPL-3.0 License. See the [LICENSE](LICENSE) file for details.
