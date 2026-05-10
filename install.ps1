# install.ps1 - Installer for git-inject and its documentation
$ScriptName = "git-inject"
$DocName = "git-inject.html"

$SourceScript = Join-Path $PSScriptRoot $ScriptName
$SourceDoc = Join-Path $PSScriptRoot $DocName

# UI Helpers
function Write-Header { param($Text) Write-Host "`n==> " -ForegroundColor Cyan -NoNewline; Write-Host $Text -ForegroundColor White }
function Write-Success { param($Text) Write-Host "  [OK] " -ForegroundColor Green -NoNewline; Write-Host $Text }
function Write-ErrorMsg { param($Text) Write-Host "  [FAIL] " -ForegroundColor Red -NoNewline; Write-Host $Text }
function Write-Warn { param($Text) Write-Host "  [!] " -ForegroundColor Yellow -NoNewline; Write-Host $Text }

# Install the Script
Write-Header "Installing $ScriptName tool"

if (-not (Test-Path $SourceScript)) {
    Write-ErrorMsg "Could not find $ScriptName in the current directory."
    exit 1
}

# Find a suitable bin directory in PATH
$UserBin = Join-Path $HOME "bin"
if (-not (Test-Path $UserBin)) {
    Write-Host "  Creating local bin directory at $UserBin..."
    New-Item -ItemType Directory -Path $UserBin -Force | Out-Null
}

$DestScript = Join-Path $UserBin $ScriptName
try {
    Copy-Item -Path $SourceScript -Destination $DestScript -Force -ErrorAction Stop
    Write-Success "Installed script to: $DestScript"
}
catch {
    Write-ErrorMsg "Could not overwrite $DestScript because it is currently in use."
    Write-Host "     Please close any open Git Bash, PowerShell, or VS Code instances and try again." -ForegroundColor Gray
    exit 1
}

# Check and Update PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -split ";" -notcontains $UserBin) {
    Write-Header "Updating User PATH"
    Write-Host "  Adding $UserBin to your User PATH..."
    $NewPath = "$UserPath;$UserBin".Trim(';')
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Success "PATH updated successfully."
    Write-Host "     You will need to restart your terminal for this to take effect." -ForegroundColor Gray
}

# Install the Documentation
Write-Header "Installing documentation"

if (-not (Test-Path $SourceDoc)) {
    Write-Warn "Could not find $DocName. Skipping documentation install."
} else {
    # Try to find the official Git HTML path
    $GitDocPath = (git --html-path).Replace('/', '\')

    if ($null -ne $GitDocPath -and (Test-Path $GitDocPath)) {
        $DestDoc = Join-Path $GitDocPath $DocName
        Write-Host "  Found Git documentation directory: $GitDocPath"

        try {
            Write-Host "  Attempting to install to system Git docs..."
            Copy-Item -Path $SourceDoc -Destination $DestDoc -ErrorAction Stop
            Write-Success "Installed documentation to system Git docs."
            Write-Host "     You can now run 'git help inject' to view the documentation." -ForegroundColor Gray
        }
        catch {
            Write-Warn "Permission denied for system Git docs."

            # Local Fallback
            $UserBinDocs = Join-Path $UserBin "docs"
            if (-not (Test-Path $UserBinDocs)) { New-Item -ItemType Directory -Path $UserBinDocs -Force | Out-Null }
            $LocalDestDoc = Join-Path $UserBinDocs $DocName
            Copy-Item -Path $SourceDoc -Destination $LocalDestDoc -Force
            Write-Success "Installed documentation locally to: $LocalDestDoc"
            Write-Host "     You can open it manually or create an alias." -ForegroundColor Gray
        }
    }
}

# Install Man Page for Git Bash
$ManName = "git-inject.1"
$SourceMan = Join-Path $PSScriptRoot $ManName
if (Test-Path $SourceMan) {
    Write-Header "Installing Man Page for Git Bash"
    $GitPath = Get-Command git | Select-Object -ExpandProperty Definition
    $GitInstallDir = [System.IO.Path]::GetDirectoryName([System.IO.Path]::GetDirectoryName($GitPath))
    $SystemManDir = Join-Path $GitInstallDir "usr\share\man\man1"

    if (Test-Path $SystemManDir) {
        $DestMan = Join-Path $SystemManDir $ManName
        try {
            Copy-Item -Path $SourceMan -Destination $DestMan -ErrorAction Stop
            Write-Success "Man page installed to $SystemManDir"
        }
        catch {
            Write-Warn "Permission denied. (Run as Admin to install man page)."
        }
    }
}

Write-Host "`nDone! Installation complete." -ForegroundColor Green

Write-Host "`nTry it out:" -ForegroundColor White
Write-Host "  git inject" -ForegroundColor Cyan
Write-Host "  git help inject" -ForegroundColor Cyan
