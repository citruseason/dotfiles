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
        @{ Id = "Kakao.KakaoTalk";       Name = "KakaoTalk" }
        @{ Id = "Discord.Discord";       Name = "Discord" }
        @{ Id = "Google.Antigravity";    Name = "Antigravity" }
        @{ Id = "Starship.Starship";     Name = "Starship" }
    )

    foreach ($app in $apps) {
        Install-WingetPackage -Id $app.Id -Name $app.Name
    }
}

function Install-ChattingPlus {
    Write-Step "Installing ChattingPlus (채팅플러스)"

    $found = Get-AppxPackage | Where-Object { $_.Name -match "Chatting|채팅" } -ErrorAction SilentlyContinue
    if (-not $found) {
        $found = Get-StartApps | Where-Object { $_.Name -match "채팅|Chatting" } -ErrorAction SilentlyContinue
    }
    if ($found) {
        Write-Ok "ChattingPlus is already installed"
        return
    }

    try {
        $installer = "$env:TEMP\ChattingPlus_Setup.msix"
        Write-Host "   Downloading ..." -NoNewline
        Invoke-WebRequest -Uri "https://d3bjr3tfd36e0x.cloudfront.net/files/appversion/CHAT_PLUS_WIN/ChattingPlus_Setup.msix" `
            -OutFile $installer -UseBasicParsing
        Write-Ok " done"

        Write-Host "   Installing ..." -NoNewline
        Add-AppxPackage -Path $installer
        Remove-Item $installer -Force -ErrorAction SilentlyContinue
        Write-Ok " done"
    }
    catch {
        Write-Warn "ChattingPlus installation failed: $($_.Exception.Message)"
        Write-Warn "Install manually: https://chattingplus.co.kr/down"
    }
}

function Install-WSL {
    Write-Step "Installing WSL + Ubuntu 24.04 LTS"

    try {
        $distros = (wsl --list --quiet 2>$null) | Where-Object { $_ -match "Ubuntu" }
        if ($distros) {
            Write-Ok "WSL Ubuntu is already installed"
            return
        }
    }
    catch {
        # WSL not installed yet
    }

    wsl --install -d Ubuntu-24.04 --no-launch
    $script:NeedsReboot = $true
    Write-Warn "Reboot required to complete WSL installation"
}

function Invoke-Debloat {
    Write-Step "Running Win11Debloat"

    $debloat = [scriptblock]::Create((irm "https://debloat.raphi.re/"))
    & $debloat `
        -RunDefaults `
        -Silent `
        -RemoveGamingApps `
        -DisableTelemetry `
        -DisableBing `
        -DisableSuggestions `
        -DisableLockscreenTips `
        -DisableEdgeAds `
        -DisableSettings365Ads `
        -DisableDesktopSpotlight `
        -DisableCopilot `
        -DisableRecall `
        -DisableWidgets `
        -HideChat `
        -HideTaskview `
        -TaskbarAlignLeft `
        -RevertContextMenu `
        -ShowKnownFileExt `
        -ShowHiddenFolders `
        -DisableMouseAcceleration `
        -DisableStickyKeys `
        -DisableFastStartup `
        -ExplorerToThisPC

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
    Install-ChattingPlus
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
