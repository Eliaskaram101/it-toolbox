# Repository instructions

These instructions apply only to this repository and its descendants. IT Toolbox is a standalone library of 57 Windows command and PowerShell references in 10 category folders. References remain text files for inspection; supporting validation tools are counted separately.

## Branding and privacy

- Keep CCSI out of scripts, command references, filenames, documentation, examples, configuration, commit messages, and all other project content; this prohibition statement is the only permitted literal occurrence in tracked content.
- Exclude the employer's full name, organization-specific domains, deployment URLs, signatures, and other identifying details.
- Do not include client names, real client domains, tenant identifiers, customer accounts, device identifiers, credentials, secrets, or client-specific outputs, even in this private repository.
- Use clearly identified generic placeholders such as example.com, user@example.com, and server01. Keep ordinary software and vendor names where they explain commands.
- Deployment scripts must require approved configuration from the person running them, without an organization-specific default. Preserve the ScreenConnect installer's mandatory InstallerUrl parameter.

## Command documentation

- Every new or modified script or command reference starts with exactly two introductory commented lines: `Purpose:` followed by one accurate sentence, then `Run:` followed by one sentence explaining execution.
- Use `#` comments for PowerShell, `REM` comments for CMD, and valid comments for other script languages. State the correct shell, user context, elevation, required parameters, and essential prerequisites.
- Windows + R instructions must specify that only the launch command goes into Run, never the comments or entire file.
- Describe deletion, uninstallation, resets, permission or setting changes, and restart requirements explicitly.
- README files, this file, CSV indexes, hash lists, and other non-script documents do not require these headers. Executable validation scripts do.

## Maintenance

- Keep category folders directly at the repository root. Put additions in the appropriate category and retain descriptive `.PowerShell.txt`, `.CMD.txt`, or `.CMD-or-Run.txt` filenames.
- Keep each reference self-contained. Do not silently change command behavior during organization or documentation work.
- Update SCRIPT-INDEX.csv when references are added, renamed, moved, or removed. Keep its Purpose and How to run fields consistent with reference headers.
- Regenerate affected SHA-256 entries whenever reference contents change. Preserve reference encoding and line endings; `.gitattributes` prevents automatic conversion of hashed text files.
- Do not treat an unavailable command, unsupported platform, or failed collection as a healthy result. Explain uncertainties and failure modes.
- Remove duplicates only when the retained reference genuinely covers the same task, and explain each removal in the completion response.
- Keep the README focused on this standalone library and include `Created by Elias Karam` without a professional title.
- Do not add a CHANGES file, editing-history narrative, original-file provenance columns, or references to prompts or archive revisions. Preserve existing Git history.
- Do not track source archives, duplicate toolbox copies, scratch files, internal preparation records, logs, generated assessment outputs, credentials, or build artifacts.
- Run `powershell.exe -NoProfile -File .\tools\Validate-Toolbox.ps1` from the repository root before committing. Review every warning; the validator cannot identify every organization name or secret.
- Review the final tracked content and staged diff. Do not claim Windows runtime testing when only static validation was performed.
