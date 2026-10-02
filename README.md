# IT Toolbox

Created by Elias Karam

A practical library of 57 Windows command and PowerShell references for troubleshooting, system administration, and environment assessments.

## Browse the toolbox

| Category folder | Files | What you will find |
| --- | ---: | --- |
| 01-Identity-and-Local-Access | 9 | Device registration, local access, domain users, security tokens, user sessions, Windows Hello |
| 02-Active-Directory-and-M365 | 5 | Entra Connect Sync, Exchange Online, domain controller diagnostics, Group Policy, time synchronization |
| 03-Hardware-Storage-and-Backup | 9 | Disk health, media types, volume capacity, hardware identification, VSS, CHKDSK, memory testing |
| 04-Windows-Updates | 3 | Installed hotfixes, missing-update assessment, Windows Update component reset |
| 05-Windows-Repair-and-Maintenance | 5 | DISM and SFC, temporary files, process memory, reboot reminders, execution policy |
| 06-Network-and-DNS | 7 | Network configuration, DNS queries, TCP connectivity, listening ports, SMB shares |
| 07-Power-and-Battery | 4 | Battery reports, SleepStudy, sleep timeouts, Modern Standby settings |
| 08-Applications-and-Desktop | 5 | Program inventory, printer drivers, classic Outlook, OneDrive, Explorer shell |
| 09-Security-and-Remote-Management | 8 | Defender, BitLocker, services, scheduled tasks, certificates, remote-management agents |
| 10-Windows-Setup-and-Licensing | 2 | Windows setup and edition-key commands |

## File conventions

Every command reference begins with two commented instruction lines:

1. **Purpose:** One sentence describing what the command or script does.
2. **Run:** One sentence explaining the shell, permissions, and steps needed to run it.

| Filename ending | Where to run it | Comment style |
| --- | --- | --- |
| `.PowerShell.txt` | PowerShell, using the version specified in the Run line | `#` |
| `.CMD.txt` | Command Prompt (`cmd.exe`) | `REM` |
| `.CMD-or-Run.txt` | Command Prompt, or Windows + R as directed | `REM` |

Files use the `.txt` extension so they open for inspection rather than executing when opened.
For longer PowerShell scripts, the Run line specifies saving the content as a `.ps1` file.
Command references use UTF-8 with BOM and Windows line endings.

## Using a command

1. Open the reference and read its Purpose and Run lines.
2. Replace account, domain, server, or URL placeholders with the intended values.
3. Open the specified shell in the correct user context; use **Run as administrator** when required.
4. Paste the reference into that shell, or save and run the script as its instructions specify.
5. For references that specify separate sections, inspect each result before continuing.

Windows + R accepts a single launch command. Paste only the command identified by the Run line, without the comment headers or additional lines.
User-context checks should run as the affected user. Elevating with a different account can change the identity or profile being inspected.
Module availability, Windows version, device capabilities, and permissions determine which commands are supported on a particular system.

## Configuration and task requirements

- **ScreenConnect installation:** Supply your approved MSI download URL through `-InstallerUrl`; the script requires this parameter and has no preconfigured deployment server.
- **ITSPlatform removal:** Verify the exact installed component names, paths, and uninstall strings before execution; name patterns target `ITSPlatform`.
- **Reboot reminder:** Verify the parsed `quser` session ID and that the reminder is appropriate; the message does not independently detect a pending reboot.
- **Windows Update reset:** Run the sections deliberately and choose unused backup names if the `.old` folders already exist.
- **Optional account and power changes:** Commented commands run only after you deliberately remove their comment markers.
- **Setup and power compatibility:** OOBE commands and Modern Standby settings depend on the Windows build and device support; some actions require a restart.
- **Windows Pro edition key:** A generic edition key does not supply an activation license or perform a Windows-version upgrade.

The toolbox contains both inspection commands and actions that repair, reset, install, remove, or change settings.
Each reference describes its intended behavior and execution requirements.

An unavailable command, unsupported platform, failed query, or incomplete collection is an unknown or failed result, not evidence of a healthy system. Review errors and prerequisites before interpreting output. The agent removal reference suppresses some errors and needs explicit post-removal verification; the reboot reminder requires checking both the session and whether a reboot is pending.

## Reference files

- **SCRIPT-INDEX.csv:** Searchable catalog of all 57 references, including categories, shells, purposes, and execution instructions.
- **SHA256SUMS.txt:** SHA-256 hashes for the 57 command and script files, with paths relative to the toolbox folder.

## Local validation

The 57 toolbox references are separate from the supporting validation script in `tools/`.
From the repository root, use a normal user session with Git and Windows PowerShell 5.1 or newer:

```powershell
powershell.exe -NoProfile -File .\tools\Validate-Toolbox.ps1
```

Validation reads tracked working files and checks headers, PowerShell syntax without execution, index coverage and matching instructions, reference counts, SHA-256 hashes, and prohibited branding. It flags unexpected domains, likely secrets, and possible account or tenant identifiers for human review without deleting content or displaying suspected values. Stage intended additions with `git add` before validating so they are included. Exit codes are 0 for success, 1 for validation failures, and 2 for review warnings.

This is static validation and does not run any toolbox reference, install software, connect to a tenant, or assess the host computer. Privacy checks are heuristics; review new content for organization names, identifiers, and secrets before sharing. Generated reports and deployment logs can contain sensitive environment details and must stay outside tracked content. Repository maintenance rules are in `AGENTS.md`.

Reference bytes are preserved by `.gitattributes`; keep UTF-8 BOM and CRLF when editing references, then regenerate the affected manifest hashes using `Get-FileHash -Algorithm SHA256` and synchronize index instructions.

## Microsoft documentation

- [CMD REM comments](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/rem)
- [PowerShell WMI and CIM](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi)
- [Group Policy results](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/gpresult)
- [Windows Time service queries](https://learn.microsoft.com/en-us/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings)
- [TCP connectivity diagnostics](https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection)
- [Defender protection status](https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus)
- [BitLocker status](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde-status)
- [Certificate provider](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/about/about_certificate_provider)
- [Windows edition upgrade methods](https://learn.microsoft.com/en-us/windows/deployment/upgrade/windows-edition-upgrades)
- [Reset OneDrive](https://support.microsoft.com/en-us/onedrive/reset-onedrive)
- [Classic Outlook safe mode](https://support.microsoft.com/en-us/outlook/classic-outlook-not-responding-stuck-at-processing-stopped-working-or-freezes)
