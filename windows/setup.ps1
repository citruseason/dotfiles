#Requires -RunAsAdministrator
Set-StrictMode -Version Latest

# ── Colors ───────────────────────────────────────────
function Write-Step  { param([string]$msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$msg) Write-Host "   $msg" -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host "   $msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$msg) Write-Host "   $msg" -ForegroundColor Red }

# ── Chocolatey ───────────────────────────────────────
function Assert-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "   Upgrading Chocolatey ..."
        choco upgrade chocolatey -y 2>$null | Out-Null
        Write-Ok "Chocolatey ready"
        return
    }

    Write-Host "   Installing Chocolatey ..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
        'https://community.chocolatey.org/install.ps1'))

    # Refresh PATH so choco is available immediately
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + `
                [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Err "Chocolatey installation failed."
        exit 1
    }
    Write-Ok "Chocolatey installed"
}

function Install-ChocoPackage {
    param([string]$Id, [string]$Name)

    Write-Host "   Installing $Name ..."
    choco install $Id -y --no-progress 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$Name installed"
    }
    else {
        Write-Warn "$Name installation may have failed (exit code: $LASTEXITCODE)"
    }
}

# ── Steps ────────────────────────────────────────────
function Install-Apps {
    Write-Step "Installing applications via Chocolatey"

    $apps = @(
        @{ Id = "powertoys";     Name = "PowerToys" }
        @{ Id = "1password";     Name = "1Password" }
        @{ Id = "tailscale";     Name = "Tailscale" }
        @{ Id = "googlechrome";  Name = "Google Chrome" }
        @{ Id = "kakaotalk";     Name = "KakaoTalk" }
        @{ Id = "discord";       Name = "Discord" }
        @{ Id = "starship";      Name = "Starship" }
    )

    foreach ($app in $apps) {
        Install-ChocoPackage -Id $app.Id -Name $app.Name
    }

    # Antigravity (not available in package managers)
    $agInstalled = Get-StartApps | Where-Object { $_.Name -match "Antigravity" } -ErrorAction SilentlyContinue
    if ($agInstalled) {
        Write-Ok "Antigravity is already installed"
    }
    else {
        Write-Warn "Antigravity is not available via Chocolatey"
        Write-Warn "Install manually: https://antigravity.withgoogle.com"
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
        Write-Host "   Downloading ..."
        Invoke-WebRequest -Uri "https://d3bjr3tfd36e0x.cloudfront.net/files/appversion/CHAT_PLUS_WIN/ChattingPlus_Setup.msix" `
            -OutFile $installer -UseBasicParsing
        Write-Host "   Installing ..."
        Add-AppxPackage -Path $installer
        Remove-Item $installer -Force -ErrorAction SilentlyContinue
        Write-Ok "ChattingPlus installed"
    }
    catch {
        Write-Warn "ChattingPlus installation failed: $($_.Exception.Message)"
        Write-Warn "Install manually: https://chattingplus.co.kr/down"
    }
}

function Install-WSL {
    Write-Step "Installing WSL + Ubuntu 24.04 LTS"

    try {
        $raw = [System.Text.Encoding]::Unicode.GetString([System.Text.Encoding]::Default.GetBytes(
            (wsl --list --quiet 2>$null | Out-String)
        ))
        if ($raw -match "Ubuntu") {
            Write-Ok "WSL Ubuntu is already installed"
            return
        }
    }
    catch {
        # WSL not installed yet
    }

    wsl --install -d Ubuntu-24.04
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
        -RemoveCommApps `
        -RemoveW11Outlook `
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
        Install-ChocoPackage -Id "intel-dsa" -Name "Intel Driver & Support Assistant"
    }
    elseif ($cpu.Manufacturer -match "AMD|Advanced Micro") {
        Install-ChocoPackage -Id "amd-software-adrenalin-edition" -Name "AMD Software: Adrenalin Edition"
    }

    # GPU
    $gpus = Get-CimInstance -ClassName Win32_VideoController

    foreach ($gpu in $gpus) {
        Write-Host "   GPU: $($gpu.Name)"

        if ($gpu.Name -match "NVIDIA") {
            Install-ChocoPackage -Id "nvidia-app" -Name "NVIDIA App"
        }
        elseif ($gpu.Name -match "AMD|Radeon") {
            Write-Ok "AMD GPU driver managed by AMD Software: Adrenalin Edition"
        }
    }
}

# ── Main ─────────────────────────────────────────────
function Main {
    $script:NeedsReboot = $false

    Write-Host "`n  dotfiles - Windows 11 Setup" -ForegroundColor White
    Write-Host "  ─────────────────────────────────────────────`n" -ForegroundColor DarkGray

    Assert-Chocolatey
    Install-Apps
    Install-ChattingPlus
    Invoke-Debloat
    Install-Drivers
    Install-WSL

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
