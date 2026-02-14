#Requires -RunAsAdministrator
Set-StrictMode -Version Latest

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

    Write-Host "   Upgrading App Installer ..."
    winget upgrade --id Microsoft.AppInstaller --silent --source winget `
        --accept-package-agreements --accept-source-agreements 2>$null
    Write-Ok "winget ready"
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name)

    $listOutput = winget list --id $Id --source winget --accept-source-agreements 2>&1 | Out-String
    if ($listOutput -match [regex]::Escape($Id)) {
        Write-Ok "$Name is already installed"
        return
    }

    Write-Host "   Installing $Name ..."
    winget install --id $Id --silent --source winget `
        --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$Name installed"
    }
    else {
        Write-Warn "$Name installation may have failed (exit code: $LASTEXITCODE)"
    }
}

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
    choco install $Id -y
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$Name installed"
    }
    else {
        Write-Warn "$Name installation may have failed (exit code: $LASTEXITCODE)"
    }
}

# ── Steps ────────────────────────────────────────────
function Install-Apps {
    Write-Step "Installing applications"

    # winget
    $wingetApps = @(
        @{ Id = "Microsoft.PowerToys";   Name = "PowerToys" }
        @{ Id = "AgileBits.1Password";   Name = "1Password" }
        @{ Id = "tailscale.tailscale";   Name = "Tailscale" }
        @{ Id = "Kakao.KakaoTalk";       Name = "KakaoTalk" }
        @{ Id = "Discord.Discord";       Name = "Discord" }
        @{ Id = "Starship.Starship";     Name = "Starship" }
    )

    foreach ($app in $wingetApps) {
        Install-WingetPackage -Id $app.Id -Name $app.Name
    }

    # Chrome: winget 해시 불일치 문제로 choco 사용
    Write-Host "   Installing Google Chrome ..."
    choco install googlechrome -y --ignore-checksums
    if ($LASTEXITCODE -eq 0) { Write-Ok "Google Chrome installed" }
    else { Write-Warn "Google Chrome installation may have failed (exit code: $LASTEXITCODE)" }

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

    # Prevent debloat script from clearing the screen
    function Clear-Host {}

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

function Set-StarshipConfig {
    Write-Step "Configuring Starship prompt"

    $configDir = "$env:USERPROFILE\.config"
    if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }

    $configFile = "$configDir\starship.toml"
    @'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$character"""

[directory]
style = "blue"

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vimcmd_symbol = "[❮](green)"

[git_branch]
format = "[$branch]($style)"
style = "bright-black"

[git_status]
format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
style = "cyan"
conflicted = "​"
untracked = "​"
modified = "​"
staged = "​"
renamed = "​"
deleted = "​"
stashed = "≡"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "bright-black"

[cmd_duration]
format = "[$duration]($style) "
style = "yellow"

[python]
format = "[$virtualenv]($style) "
style = "bright-black"
detect_extensions = []
detect_files = []
'@ | Out-File -FilePath $configFile -Encoding utf8 -Force

    Write-Ok "Starship config written to $configFile"
}

function Set-TaskbarLayout {
    Write-Step "Configuring taskbar layout"

    # Show search icon on taskbar (1 = icon only, 2 = search box)
    $searchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 1 -Force
    Write-Ok "Search icon enabled"

    # Taskbar pinned apps: Explorer, Chrome, Discord, KakaoTalk
    $xml = @'
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer"/>
        <taskbar:DesktopApp DesktopApplicationLinkPath="%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk"/>
        <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"/>
        <taskbar:DesktopApp DesktopApplicationLinkPath="%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Kakao\KakaoTalk\KakaoTalk.lnk"/>
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@

    $layoutFile = "$env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml"
    $xml | Out-File -FilePath $layoutFile -Encoding utf8 -Force

    # Also place in default profile for new users
    $defaultLayout = "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
    $xml | Out-File -FilePath $defaultLayout -Encoding utf8 -Force

    # Apply via registry policy
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "StartLayoutFile" -Value $layoutFile -Force
    Set-ItemProperty -Path $regPath -Name "LockedStartLayout" -Value 1 -Type DWord -Force

    # Restart explorer to apply
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # Unlock so user can modify later
    Set-ItemProperty -Path $regPath -Name "LockedStartLayout" -Value 0 -Type DWord -Force
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

    Write-Ok "Taskbar layout configured (Explorer, Chrome, Discord, KakaoTalk)"
}

# ── Main ─────────────────────────────────────────────
function Main {
    $script:NeedsReboot = $false

    Write-Host "`n  dotfiles - Windows 11 Setup" -ForegroundColor White
    Write-Host "  ─────────────────────────────────────────────`n" -ForegroundColor DarkGray

    Assert-Winget
    Assert-Chocolatey
    Install-Apps
    Install-ChattingPlus
    Invoke-Debloat
    Install-Drivers
    Set-StarshipConfig
    Set-TaskbarLayout
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
