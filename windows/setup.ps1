#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Colors ───────────────────────────────────────────
function Write-Step  { param([string]$msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$msg) Write-Host "   $msg" -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host "   $msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$msg) Write-Host "   $msg" -ForegroundColor Red }

# ── Winget ───────────────────────────────────────────
function Assert-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Err "winget not found. Please update App Installer from Microsoft Store."
        exit 1
    }
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name)

    $installed = winget list --id $Id --exact --accept-source-agreements 2>&1
    if ($installed -match $Id) {
        Write-Ok "$Name is already installed"
        return
    }

    Write-Host "   Installing $Name ..." -NoNewline
    winget install --id $Id --exact --silent `
        --accept-package-agreements --accept-source-agreements | Out-Null
    Write-Ok " done"
}

# ── Steps ────────────────────────────────────────────
function Install-Apps {
    Write-Step "Installing applications via winget"

    $apps = @(
        @{ Id = "Microsoft.PowerToys";   Name = "PowerToys" }
        @{ Id = "AgileBits.1Password";   Name = "1Password" }
        @{ Id = "tailscale.tailscale";   Name = "Tailscale" }
    )

    foreach ($app in $apps) {
        Install-WingetPackage -Id $app.Id -Name $app.Name
    }
}

function Install-WSL {
    Write-Step "Installing WSL + Ubuntu 24.04 LTS"

    $wslStatus = wsl --status 2>&1
    if ($LASTEXITCODE -eq 0 -and $wslStatus -notmatch "no installed distributions") {
        $distros = wsl --list --quiet 2>&1
        if ($distros -match "Ubuntu") {
            Write-Ok "WSL Ubuntu is already installed"
            return
        }
    }

    wsl --install -d Ubuntu-24.04 --no-launch
    $script:NeedsReboot = $true
    Write-Warn "Reboot required to complete WSL installation"
}

function Invoke-Debloat {
    Write-Step "Running Win11Debloat (default settings)"
    & ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -RunDefaults -Silent
    Write-Ok "Win11Debloat completed"
}

function Install-Drivers {
    Write-Step "Detecting hardware and installing drivers"

    # CPU
    $cpu = Get-CimInstance -ClassName Win32_Processor
    Write-Host "   CPU: $($cpu.Name)"

    if ($cpu.Manufacturer -match "Intel") {
        Install-WingetPackage -Id "Intel.IntelDriverAndSupportAssistant" -Name "Intel Driver & Support Assistant"
    }
    elseif ($cpu.Manufacturer -match "AMD|Advanced Micro") {
        Write-Warn "AMD chipset drivers are not available via winget"
        Write-Warn "Download manually: https://www.amd.com/en/support"
    }

    # GPU
    $gpus = Get-CimInstance -ClassName Win32_VideoController

    foreach ($gpu in $gpus) {
        Write-Host "   GPU: $($gpu.Name)"

        if ($gpu.Name -match "NVIDIA") {
            Install-WingetPackage -Id "Nvidia.GeForceExperience" -Name "NVIDIA GeForce Experience"
        }
        elseif ($gpu.Name -match "AMD|Radeon") {
            Install-WingetPackage -Id "AMD.AMDSoftware" -Name "AMD Software: Adrenalin Edition"
        }
    }
}

# ── Main ─────────────────────────────────────────────
function Main {
    $script:NeedsReboot = $false

    Write-Host "`n  dotfiles - Windows 11 Setup" -ForegroundColor White
    Write-Host "  ─────────────────────────────────────────────`n" -ForegroundColor DarkGray

    Assert-Winget
    Install-Apps
    Invoke-Debloat
    Install-WSL
    Install-Drivers

    Write-Host "`n" -NoNewline
    if ($script:NeedsReboot) {
        Write-Warn "Setup complete. Please reboot to finish WSL installation."
    }
    else {
        Write-Ok "Setup complete!"
    }
    Write-Host ""
}

Main
