# install.ps1 - Installer for git-inject and its documentation
$ScriptName = "git-inject"
$DocName = "git-inject.html"

$SourceScript = Join-Path $PSScriptRoot $ScriptName
$SourceDoc = Join-Path $PSScriptRoot $DocName

# --- Install the Script ---
Write-Host "--- Installing git-inject tool ---" -ForegroundColor Cyan

if (-not (Test-Path $SourceScript)) {
    Write-Error "Could not find $ScriptName in the current directory."
    exit 1
}

# Find a suitable bin directory in PATH
$UserBin = Join-Path $HOME "bin"
if (-not (Test-Path $UserBin)) {
    Write-Host "Creating local bin directory at $UserBin..."
    New-Item -ItemType Directory -Path $UserBin -Force | Out-Null
}

$DestScript = Join-Path $UserBin $ScriptName
try {
    Copy-Item -Path $SourceScript -Destination $DestScript -Force -ErrorAction Stop
    Write-Host " [SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "Installed script to: $DestScript"
}
catch {
    Write-Host " [ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Could not overwrite $DestScript because it is currently in use." -ForegroundColor Yellow
    Write-Host "Please close any open Git Bash, PowerShell, or VS Code instances and try again." -ForegroundColor Gray
    exit 1
}

# --- Check and Update PATH ---
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -split ";" -notcontains $UserBin) {
    Write-Host "Adding $UserBin to your User PATH..." -ForegroundColor Yellow
    $NewPath = "$UserPath;$UserBin".Trim(';')
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Host "PATH updated successfully. You will need to restart your terminal for this to take effect." -ForegroundColor Gray
}

# --- Install the Documentation ---
Write-Host "`n--- Installing documentation ---" -ForegroundColor Cyan

if (-not (Test-Path $SourceDoc)) {
    Write-Warning "Could not find $DocName. Skipping documentation install."
} else {
    # Try to find the official Git HTML path
    $GitDocPath = (git --html-path).Replace('/', '\')

    if ($null -ne $GitDocPath -and (Test-Path $GitDocPath)) {
        $DestDoc = Join-Path $GitDocPath $DocName
        Write-Host "Found Git documentation directory: $GitDocPath"

        try {
            Write-Host "Attempting to install to system Git docs..."
            Copy-Item -Path $SourceDoc -Destination $DestDoc -ErrorAction Stop
            Write-Host " [SUCCESS] " -ForegroundColor Green -NoNewline
            Write-Host "You can now run 'git help inject' to view the documentation."
        }
        catch {
            Write-Host " [FAILED] " -ForegroundColor Yellow -NoNewline
            Write-Host "Permission denied."

            # Local Fallback
            $UserBinDocs = Join-Path $UserBin "docs"
            if (-not (Test-Path $UserBinDocs)) { New-Item -ItemType Directory -Path $UserBinDocs -Force | Out-Null }
            $LocalDestDoc = Join-Path $UserBinDocs $DocName
            Copy-Item -Path $SourceDoc -Destination $LocalDestDoc -Force
            Write-Host "Installed documentation locally to: $LocalDestDoc" -ForegroundColor Gray
            Write-Host "You can open it manually or create an alias." -ForegroundColor Gray
        }
    }
}

# --- Install Man Page for Git Bash ---
$ManName = "git-inject.1"
$SourceMan = Join-Path $PSScriptRoot $ManName
if (Test-Path $SourceMan) {
    Write-Host "`n--- Installing Man Page for Git Bash ---" -ForegroundColor Cyan
    $GitPath = Get-Command git | Select-Object -ExpandProperty Definition
    $GitInstallDir = [System.IO.Path]::GetDirectoryName([System.IO.Path]::GetDirectoryName($GitPath))
    $SystemManDir = Join-Path $GitInstallDir "usr\share\man\man1"

    if (Test-Path $SystemManDir) {
        $DestMan = Join-Path $SystemManDir $ManName
        try {
            Copy-Item -Path $SourceMan -Destination $DestMan -ErrorAction Stop
            Write-Host " [SUCCESS] " -ForegroundColor Green -NoNewline
            Write-Host "Man page installed to $SystemManDir"
        }
        catch {
            Write-Host " [FAILED] " -ForegroundColor Yellow -NoNewline
            Write-Host "Permission denied. (Run as Admin to install man page)."
        }
    }
}

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "Try it out:`n"
Write-Host "`tgit inject"
Write-Host "`tgit help inject"

