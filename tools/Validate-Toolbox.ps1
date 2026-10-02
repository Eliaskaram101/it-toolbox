# Purpose: Statically checks reference headers, catalog consistency, SHA-256 hashes, and tracked content for privacy concerns without running toolbox commands.
# Run: From the repository root run powershell.exe -NoProfile -File .\tools\Validate-Toolbox.ps1 as a normal user with Git and Windows PowerShell 5.1 or newer available.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$failures = [Collections.Generic.List[string]]::new()
$reviews = [Collections.Generic.List[string]]::new()
function Fail([string]$message) { $failures.Add($message) }
function Review([string]$message) { $reviews.Add($message) }

# Examine Git's tracked working files; never collect machine or tenant data.
$tracked = @(git -C $root -c core.quotePath=false ls-files --cached)
if ($LASTEXITCODE -ne 0 -or $tracked.Count -eq 0) { throw 'No tracked files found; run git add after preparing the repository.' }
if (@($tracked | Where-Object { $_ -match '(?i)(^|/)(work|reports|assessment-outputs?|node_modules|build|dist)/|\.(zip|7z|log|pfx|p12|pem|key|msi|exe|evtx|dmp)$|(^|/)\.env($|\.)' }).Count) {
    Fail 'Tracked files include an archive, generated output, credential file, or local artifact.'
}
$refs = @($tracked | Where-Object { $_ -match '^\d{2}-[^/]+/[^/]+\.(PowerShell|CMD|CMD-or-Run)\.txt$' })
$discovered = @(Get-ChildItem -LiteralPath $root -Directory | Where-Object Name -match '^\d{2}-' | Get-ChildItem -Recurse -File)
foreach ($file in $discovered) {
    $relative = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
    if ($relative -notin $refs) { Fail "Unexpected or untracked category file: $relative" }
}
if ($refs.Count -ne 57) { Fail "Expected 57 references; found $($refs.Count). Update the documented inventory intentionally if adding or removing references." }
if (@($refs | ForEach-Object { ($_ -split '/')[0] } | Select-Object -Unique).Count -ne 10) { Fail 'Expected 10 reference categories.' }

$headers = @{}
foreach ($path in @($refs) + @($tracked | Where-Object { $_ -match '\.ps1$' })) {
    $full = Join-Path $root $path
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { Fail "Missing tracked file: $path"; continue }
    $lines = @(Get-Content -LiteralPath $full -Encoding UTF8)
    $prefix = if ($path -match '\.CMD(?:-or-Run)?\.txt$') { 'REM' } else { '#' }
    if ($lines.Count -lt 2 -or $lines[0] -notmatch "^$prefix Purpose: .+\.$" -or $lines[1] -notmatch "^$prefix Run: .+\.$") {
        Fail "Incorrect Purpose/Run headers: $path"
    } else {
        $headers[$path] = @(($lines[0] -replace "^$prefix Purpose: ", ''), ($lines[1] -replace "^$prefix Run: ", ''))
    }
    if ($path -match '\.CMD-or-Run\.txt$' -and ($lines.Count -lt 2 -or $lines[1] -notmatch 'Windows \+ R.*only')) { Fail "Run must restrict Windows + R to the launch command: $path" }
    if ($path -match '\.PowerShell\.txt$|\.ps1$') {
        $tokens = $null; $parseErrors = $null
        [void][Management.Automation.Language.Parser]::ParseFile($full, [ref]$tokens, [ref]$parseErrors)
        foreach ($parseError in $parseErrors) { Fail "PowerShell syntax error in ${path}: $($parseError.Message)" }
    }
}

$indexPaths = @{}
foreach ($row in Import-Csv -LiteralPath (Join-Path $root 'SCRIPT-INDEX.csv') -Encoding UTF8) {
    $path = "$($row.Category)/$($row.File)"
    if ($indexPaths.ContainsKey($path)) { Fail "Duplicate index entry: $path" }
    $indexPaths[$path] = $true
    if ($path -notin $refs) { Fail "Index entry does not point to a tracked reference: $path"; continue }
    if ($headers.ContainsKey($path) -and ($row.Purpose -cne $headers[$path][0] -or $row.'How to run' -cne $headers[$path][1])) { Fail "Index/header mismatch: $path" }
    $expectedShell = if ($path -match '\.PowerShell\.txt$') { 'PowerShell' } elseif ($path -match '\.CMD-or-Run\.txt$') { 'CMD / Windows + R' } else { 'CMD' }
    if ($row.Shell -cne $expectedShell) { Fail "Incorrect index shell: $path" }
}
foreach ($path in $refs) { if (-not $indexPaths.ContainsKey($path)) { Fail "Reference missing from index: $path" } }

$hashPaths = @{}
foreach ($line in Get-Content -LiteralPath (Join-Path $root 'SHA256SUMS.txt') -Encoding UTF8) {
    if ($line -notmatch '^([0-9a-f]{64})  (.+)$') { Fail 'Malformed SHA-256 manifest entry.'; continue }
    $expected = $Matches[1]; $path = $Matches[2]
    if ($hashPaths.ContainsKey($path)) { Fail "Duplicate hash entry: $path" }
    $hashPaths[$path] = $true
    if ($path -notin $refs) { Fail "Hash entry is not a tracked reference: $path"; continue }
    if ((Get-FileHash -LiteralPath (Join-Path $root $path) -Algorithm SHA256).Hash.ToLowerInvariant() -cne $expected) { Fail "SHA-256 mismatch: $path" }
}
foreach ($path in $refs) { if (-not $hashPaths.ContainsKey($path)) { Fail "Reference missing from hashes: $path" } }

# Build the prohibited term without repeating its literal spelling in this tool.
$brand = -join ([char[]](67, 67, 83, 73))
$prohibition = '- Keep ' + $brand + ' out of scripts, command references, filenames, documentation, examples, configuration, commit messages, and all other project content; this prohibition statement is the only permitted literal occurrence in tracked content.'
$allowedHosts = @('example.com', 'learn.microsoft.com', 'support.microsoft.com', 'myip.opendns.com', 'resolver1.opendns.com')
foreach ($path in $tracked) {
    if ($path -match [regex]::Escape($brand)) { Fail "Prohibited branding in filename: $path" }
    $full = Join-Path $root $path
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { Fail "Missing tracked file: $path"; continue }
    $text = Get-Content -LiteralPath $full -Raw -Encoding UTF8
    $scan = $text
    if ($path -ceq 'AGENTS.md') {
        $exactLines = @($text -split '\r?\n' | Where-Object { $_ -ceq $prohibition })
        if ($exactLines.Count -ne 1) { Fail 'AGENTS.md must contain exactly one approved prohibition statement.' }
        $scan = $text.Replace($prohibition, '')
    }
    if ($scan -match [regex]::Escape($brand)) { Fail "Prohibited branding in content: $path" }
    $lineNumber = 0
    foreach ($line in $scan -split '\r?\n') {
        $lineNumber++
        # Report only locations and concern types, never suspected secret values.
        foreach ($match in [regex]::Matches($line, '(?i)\b(?:[a-z0-9-]+\.)+(?:com|net|org|io|dev|cloud|local|internal|edu|gov|co|us|uk)\b')) {
            if ($match.Value.ToLowerInvariant() -notin $allowedHosts) { Review "${path}:${lineNumber}: unapproved domain or URL host" }
        }
        foreach ($match in [regex]::Matches($line, 'https?://[^\s<>"''\)]+')) {
            $uri = $null
            if ([uri]::TryCreate($match.Value, [UriKind]::Absolute, [ref]$uri) -and $uri.Host.ToLowerInvariant() -notin $allowedHosts) { Review "${path}:${lineNumber}: unapproved URL host" }
            if ($match.Value -match '(?i)[?&](?:sig|token|key|secret|password|tenant|customer|account|device)[^=]*=') { Review "${path}:${lineNumber}: possible private URL parameter" }
        }
        if ($line -match '(?i)\b[\w.+-]+@(?!(?:example\.com)\b)[\w.-]+\.[a-z]{2,}\b|\b(?:\d{1,3}\.){3}\d{1,3}\b|\b[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\b') { Review "${path}:${lineNumber}: possible account, IP address, or tenant/device identifier" }
        if ($line -match '(?i)\b(?:gh[pousr]_[a-z0-9]{20,}|github_pat_[a-z0-9_]{20,}|AKIA[A-Z0-9]{16}|eyJ[a-z0-9_-]{10,}\.[a-z0-9_-]+\.[a-z0-9_-]+)|-{5}BEGIN [A-Z ]*PRIVATE KEY-{5}|(?:password|client_secret|api[_-]?key|access[_-]?token)\s*[:=]\s*[''"][^''"]+[''"]|https?://[^\s/]+:[^\s/]+@') { Review "${path}:${lineNumber}: possible credential or secret" }
    }
}

foreach ($message in $failures) { Write-Host "FAIL: $message" }
foreach ($message in ($reviews | Select-Object -Unique)) { Write-Warning "REVIEW: $message" }
Write-Host "$($refs.Count) toolbox references; $(@($tracked | Where-Object { $_ -match '^tools/.*\.ps1$' }).Count) supporting validation script(s)."
Write-Host "$($failures.Count) failure(s); $(@($reviews | Select-Object -Unique).Count) review warning(s). Static validation only."
if ($failures.Count -gt 0) { exit 1 }
if ($reviews.Count -gt 0) { exit 2 }
exit 0
