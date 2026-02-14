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

    # Upgrade App Installer (winget) to latest version
    Write-Host "   Upgrading App Installer ..."
    winget upgrade --id Microsoft.AppInstaller --silent --source winget `
        --accept-package-agreements --accept-source-agreements 2>$null

    # Reset sources to fix "Failed when searching source: msstore" error
    Write-Host "   Resetting winget sources ..."
    winget source reset --force --disable-interactivity 2>$null
    winget settings --enable BypassCertificatePinningForMicrosoftStore 2>$null
    winget settings --enable InstallerHashOverride 2>$null
    Write-Ok "winget ready"
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name, [switch]$IgnoreHash)

    $listOutput = winget list --id $Id --source winget --accept-source-agreements 2>&1 | Out-String
    if ($listOutput -match [regex]::Escape($Id)) {
        Write-Ok "$Name is already installed"
        return
    }

    Write-Host "   Installing $Name ..."
    $args = @("install", "--id", $Id, "--silent", "--source", "winget",
              "--accept-package-agreements", "--accept-source-agreements")
    if ($IgnoreHash) { $args += "--ignore-security-hash" }
    & winget @args
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$Name installed"
    }
    else {
        Write-Warn "$Name installation may have failed (exit code: $LASTEXITCODE)"
    }
}

# ── Direct Download Install ──────────────────────────
function Install-DirectDownload {
    param([string]$Name, [string]$Url, [string]$FileName, [string]$InstallArgs)

    $installer = "$env:TEMP\$FileName"
    try {
        Write-Host "   Downloading $Name ..."
        Invoke-WebRequest -Uri $Url -OutFile $installer -UseBasicParsing
        Write-Host "   Installing $Name ..."
        if ($InstallArgs) {
            Start-Process -FilePath $installer -ArgumentList $InstallArgs -Wait
        }
        else {
            Start-Process -FilePath $installer -Wait
        }
        Write-Ok "$Name installed"
    }
    catch {
        Write-Warn "$Name installation failed: $($_.Exception.Message)"
    }
    finally {
        Remove-Item $installer -Force -ErrorAction SilentlyContinue
    }
}

# ── Steps ────────────────────────────────────────────
function Install-Apps {
    Write-Step "Installing applications via winget"

    $apps = @(
        @{ Id = "Microsoft.PowerToys";   Name = "PowerToys";      IgnoreHash = $false }
        @{ Id = "AgileBits.1Password";   Name = "1Password";      IgnoreHash = $false }
        @{ Id = "tailscale.tailscale";   Name = "Tailscale";      IgnoreHash = $false }
        @{ Id = "Google.Chrome";         Name = "Google Chrome";   IgnoreHash = $true  }
        @{ Id = "Kakao.KakaoTalk";       Name = "KakaoTalk";      IgnoreHash = $false }
        @{ Id = "Discord.Discord";       Name = "Discord";        IgnoreHash = $false }
        @{ Id = "Google.Antigravity";    Name = "Antigravity";    IgnoreHash = $false }
        @{ Id = "Starship.Starship";     Name = "Starship";       IgnoreHash = $false }
    )

    foreach ($app in $apps) {
        if ($app.IgnoreHash) {
            Install-WingetPackage -Id $app.Id -Name $app.Name -IgnoreHash
        }
        else {
            Install-WingetPackage -Id $app.Id -Name $app.Name
        }
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
        Install-WingetPackage -Id "Intel.IntelDriverAndSupportAssistant" -Name "Intel Driver & Support Assistant"
    }
    elseif ($cpu.Manufacturer -match "AMD|Advanced Micro") {
        $amdInstalled = Get-StartApps | Where-Object { $_.Name -match "AMD Software" } -ErrorAction SilentlyContinue
        if ($amdInstalled) {
            Write-Ok "AMD Software is already installed"
        }
        else {
            Install-DirectDownload `
                -Name "AMD Auto-Detect Driver" `
                -Url "https://drivers.amd.com/drivers/installer/24.10/beta/amd-software-auto-detect.exe" `
                -FileName "amd-software-auto-detect.exe" `
                -InstallArgs "/S"
        }
    }

    # GPU
    $gpus = Get-CimInstance -ClassName Win32_VideoController

    foreach ($gpu in $gpus) {
        Write-Host "   GPU: $($gpu.Name)"

        if ($gpu.Name -match "NVIDIA") {
            $nvInstalled = Get-StartApps | Where-Object { $_.Name -match "NVIDIA App" } -ErrorAction SilentlyContinue
            if ($nvInstalled) {
                Write-Ok "NVIDIA App is already installed"
            }
            else {
                try {
                    $page = Invoke-WebRequest -Uri "https://www.nvidia.com/en-us/software/nvidia-app/" -UseBasicParsing
                    $dlUrl = ($page.Links | Where-Object { $_.href -match "us\.download\.nvidia\.com.*NVIDIA_app.*\.exe" } | Select-Object -First 1).href
                    if ($dlUrl) {
                        Install-DirectDownload `
                            -Name "NVIDIA App" `
                            -Url $dlUrl `
                            -FileName "NVIDIA_App_Setup.exe" `
                            -InstallArgs "-s -noreboot -noeula -nofinish -nosplash"
                    }
                    else {
                        Write-Warn "NVIDIA App download URL not found"
                        Write-Warn "Install manually: https://www.nvidia.com/en-us/software/nvidia-app/"
                    }
                }
                catch {
                    Write-Warn "NVIDIA App installation failed: $($_.Exception.Message)"
                    Write-Warn "Install manually: https://www.nvidia.com/en-us/software/nvidia-app/"
                }
            }
        }
        elseif ($gpu.Name -match "AMD|Radeon") {
            # AMD GPU driver is handled by the AMD Auto-Detect tool above
            Write-Ok "AMD GPU driver managed by AMD Software"
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
