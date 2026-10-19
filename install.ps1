# Run from any shell: powershell.exe -NoProfile -ExecutionPolicy Bypass -File ~/.config/install.ps1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$expected = Join-Path $HOME '.config'
if ([IO.Path]::GetFullPath($root).TrimEnd('\') -ne [IO.Path]::GetFullPath($expected).TrimEnd('\')) {
    throw 'Clone this repository into $HOME/.config before running install.ps1.'
}
$backupRoot = Join-Path $HOME ('.dotfiles-backups/install-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))

function Backup-Existing([string]$Path, [string]$Name) {
    if (Test-Path -LiteralPath $Path) {
        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        Move-Item -LiteralPath $Path -Destination (Join-Path $backupRoot $Name)
        Write-Host "Backed up $Path to $backupRoot/$Name"
    }
}

function Set-Loader([string]$Path, [string]$Content, [string]$BackupName) {
    if ((Test-Path -LiteralPath $Path) -and ([IO.File]::ReadAllText($Path) -eq $Content)) {
        return
    }
    Backup-Existing $Path $BackupName
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    [IO.File]::WriteAllText($Path, $Content, (New-Object Text.UTF8Encoding $false))
    Write-Host "Installed loader: $Path"
}

# A junction preserves Neovim's default Windows discovery and nvim-data paths.
# No administrator privileges or global XDG_CONFIG_HOME changes are required.
$nvimSource = Join-Path $root 'nvim'
$nvimPath = Join-Path $env:LOCALAPPDATA 'nvim'
if (!(Test-Path -LiteralPath (Join-Path $nvimSource 'init.lua'))) {
    throw 'Clone your separate Neovim repository into ~/.config/nvim first.'
}
$existing = Get-Item -LiteralPath $nvimPath -Force -ErrorAction SilentlyContinue
$correctLink = $existing -and ($existing.LinkType -eq 'Junction') -and (@($existing.Target)[0] -eq $nvimSource)
if (!$correctLink) {
    # Refuse unexpected links rather than moving/following them.
    if ($existing -and ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Unexpected link at $nvimPath; inspect it before rerunning."
    }
    Backup-Existing $nvimPath 'nvim'
    New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA | Out-Null
    New-Item -ItemType Junction -Path $nvimPath -Target $nvimSource | Out-Null
    Write-Host "Linked $nvimPath -> $nvimSource"
}

# WezTerm discovers ~/.config/wezterm/wezterm.lua automatically. This loader
# also supports older launchers and existing WEZTERM_CONFIG_FILE references.
$weztermLoader = @'
-- Compatibility loader. Edit ~/.config/wezterm/wezterm.lua instead.
local wezterm = require("wezterm")
return dofile(wezterm.home_dir .. "/.config/wezterm/wezterm.lua")
'@ + "`n"
Set-Loader (Join-Path $HOME '.wezterm.lua') $weztermLoader 'wezterm.lua'

# Keep Nushell's default config directory, history and plugin registry intact.
$nuRoot = Join-Path $env:APPDATA 'nushell'
Set-Loader (Join-Path $nuRoot 'config.nu') "# Managed by ~/.config/install.ps1`nsource ~/.config/nushell/config.nu`n" 'config.nu'
Set-Loader (Join-Path $nuRoot 'env.nu') "# Managed by ~/.config/install.ps1`nsource ~/.config/nushell/env.nu`n" 'env.nu'
Set-Loader (Join-Path $nuRoot 'autoload/_fzf_integration.nu') "# Managed by ~/.config/install.ps1`nsource ~/.config/nushell/autoload/_fzf_integration.nu`n" '_fzf_integration.nu'
Write-Host 'Done. Open a new Nushell session to load the configs.'
