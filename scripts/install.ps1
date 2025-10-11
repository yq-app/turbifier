# Turbifier Installation Script for Windows (PowerShell)
# Run with: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

# Configuration
$Repo = "yq-app/turbifier"
$BinaryName = "turbifier.exe"
$InstallDir = "$env:ProgramFiles\Turbifier"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-Host ""
Write-ColorOutput Cyan "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
Write-ColorOutput Cyan "┃      Turbifier Installer         ┃"
Write-ColorOutput Cyan "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
Write-Host ""

# Get latest release version
Write-ColorOutput Yellow "→ Fetching latest release..."
try {
    $Release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
    $Version = $Release.tag_name
    Write-ColorOutput Green "✓ Latest version: $Version"
} catch {
    Write-ColorOutput Red "✗ Failed to fetch latest version"
    exit 1
}

Write-Host ""

# Detect architecture
$Arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
    $Arch = "arm64"
}

Write-ColorOutput Cyan "Detected: windows/$Arch"

# Construct download URL
$BinaryFile = "turbifier-windows-$Arch.exe"
$DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$BinaryFile"
$TempFile = "$env:TEMP\$BinaryName"

Write-Host ""
Write-ColorOutput Yellow "→ Downloading $BinaryFile..."

# Download binary
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempFile -UseBasicParsing
    Write-ColorOutput Green "✓ Download complete"
} catch {
    Write-ColorOutput Red "✗ Download failed"
    Write-ColorOutput Red "  Make sure the release exists: $DownloadUrl"
    exit 1
}

# Create install directory
Write-Host ""
Write-ColorOutput Yellow "→ Installing to $InstallDir..."

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# Move binary
try {
    Move-Item -Path $TempFile -Destination "$InstallDir\$BinaryName" -Force
    Write-ColorOutput Green "✓ Binary installed"
} catch {
    Write-ColorOutput Red "✗ Installation failed (try running as Administrator)"
    exit 1
}

# Add to PATH if not already there
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-ColorOutput Yellow "→ Adding to PATH..."
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$UserPath;$InstallDir",
        "User"
    )
    Write-ColorOutput Green "✓ Added to PATH"
    Write-ColorOutput Yellow "  Note: Restart your terminal for PATH changes to take effect"
} else {
    Write-ColorOutput Green "✓ Already in PATH"
}

Write-Host ""
Write-ColorOutput Cyan "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
Write-ColorOutput Cyan "┃   Installation Successful! ✓     ┃"
Write-ColorOutput Cyan "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
Write-Host ""
Write-Host "turbifier is now installed at: " -NoNewline
Write-ColorOutput Green "$InstallDir\$BinaryName"
Write-Host ""
Write-ColorOutput Cyan "Quick Start:"
Write-Host "  1. " -NoNewline; Write-ColorOutput Green "turbifier init           "; Write-Host "- Create configuration"
Write-Host "  2. " -NoNewline; Write-ColorOutput Green "turbifier login <token>  "; Write-Host "- Authenticate"
Write-Host "  3. " -NoNewline; Write-ColorOutput Green "turbifier start          "; Write-Host "- Start verification"
Write-Host ""
Write-ColorOutput Cyan "Need help? "; Write-Host "Run: " -NoNewline; Write-ColorOutput Green "turbifier --help"
Write-Host ""
Write-ColorOutput Yellow "⚠ Remember to restart your terminal if this is your first installation"
Write-Host ""
