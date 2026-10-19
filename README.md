# Windows dotfiles

Version-controlled configuration for WezTerm and Nushell. Neovim lives beside
these files but is an **independent Git repository**, intentionally ignored here.
No global XDG variables are needed.

## Layout

```text
~/.config/                     # dotfiles repository
  wezterm/wezterm.lua          # real WezTerm config
  nushell/config.nu           # Nushell settings, aliases, completions, zoxide
  nushell/env.nu
  nushell/autoload/           # fzf integration
  nushell/scripts/            # git, cargo, uv completions and weather command
  zoxide/.zoxide.nu           # sourced zoxide integration
  nvim/                      # SEPARATE repository, not tracked by dotfiles
  install.ps1
```

## Reproduce on Windows (from Nushell)

Install Git, Neovim (a version supported by current LazyVim), WezTerm,
Nushell (0.116.1 used when migrated), zoxide, and fzf. Make sure `nu.exe`,
`nvim`, `git`, `zoxide`, and `fzf` are on PATH. Neovim plugins may additionally
need a compiler, ripgrep, fd, Node.js, Python, and language-specific tooling.
The current configs use the fonts **ABC Areal Mono**, **Iosevka Custom**,
and **Iosevka Nerd Font Mono** (Neovide); install them or change the font settings.
`ov` is the configured bat pager; `bat`/`ov`, `yazi`, WSL and uv/cargo are only
needed for the corresponding commands. Yazi's file utility setting expects
Git for Windows at `C:/Program Files/Git`.

Clone the public dotfiles repository and the independent Neovim repository:

```nu
git clone https://github.com/Vorwes/dotfiles.git ~/.config
git clone https://github.com/Vorwes/nvim.git ~/.config/nvim
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ~/.config/install.ps1
```

If `~/.config` already exists, **back it up/merge it first**; Git cannot clone into
a nonempty directory. Do not delete unrelated application configs.

The installer must be run from `~/.config`. It is safe to rerun, backs up replaced
files/directories to `~/.dotfiles-backups/install-*`, and does not require admin
rights. It installs:

- A Windows junction: `%LOCALAPPDATA%/nvim` -> `~/.config/nvim`. Neovim still
  discovers its normal config path, with plugins/data in `%LOCALAPPDATA%/nvim-data`.
- A tiny `~/.wezterm.lua` compatibility loader for existing launchers and inherited
  `WEZTERM_CONFIG_FILE` values. WezTerm normally discovers
  `~/.config/wezterm/wezterm.lua` directly. Explicit `--config-file` or environment
  overrides pointing elsewhere must be removed/updated manually.
- Thin loaders in `%APPDATA%/nushell/config.nu`, `env.nu`, and
  `autoload/_fzf_integration.nu`. History, vendor directories, plugin registration,
  and other autoload files stay in the Windows Nushell directory, outside Git.

Open a new Nushell session after installation, and restart WezTerm if necessary.
Run Neovim and allow LazyVim to install its plugins; `lazy-lock.json` in the
separate Neovim repo pins the plugin revisions. This repo does not install apps,
fonts, language servers, or existing Nushell plugins automatically.

## Private settings

Keep secrets and personal overrides outside these repositories. `WTTR_CITY` is
read from the user environment, rather than publishing your default city. In
Nushell, `$env.WTTR_CITY = "YOUR_CITY"` sets it for the current session. Use Windows
Environment Variables settings to persist it for new sessions.

The separate, ignored YASB config uses `api_key: env`; its weather credential is
stored in the Windows user environment as `YASB_WEATHER_API_KEY`, not in `.config`.
That credential is not reproduced by cloning this repository. After changing
Windows user variables, restart/sign out as needed so apps inherit them.

Ignored files are not automatically safe to share: application caches, logs and
IDs may still contain personal information. Publish the Git repositories, not a
ZIP of the entire `.config` directory. Never use `git add -f` for private files.

## Git / GitHub

These are two independent public repositories, **not** submodules:

- Dotfiles: https://github.com/Vorwes/dotfiles
- Neovim: https://github.com/Vorwes/nvim

After making changes, commit and push each repository separately:

```nu
cd ~/.config
git status
git add .
git commit -m "Update Windows terminal and shell configuration"
git push

cd ~/.config/nvim
git status
git add .
git commit -m "Update Neovim configuration"
git push
```

Review staged files before publishing. If you fork these repositories, point
`origin` to your own forks before pushing. The dotfiles `.gitignore` uses an allowlist so unrelated
`.config` applications, credentials, history, and Neovim are not accidentally
published. Existing `starship.toml`, desktop/window-manager settings and other
application folders are intentionally not included in this migration.

## Checks

```nu
nu --config ($env.APPDATA | path join nushell config.nu) --env-config ($env.APPDATA | path join nushell env.nu) -c 'print $env.config.buffer_editor; source ~/.config/nushell/autoload/_fzf_integration.nu; print "nushell-config-ok"'
nvim --headless '+lua print("NVIM_STARTUP_OK")' +qa
wezterm show-keys
```

## Recovery

The initial migration snapshot is under `~/.dotfiles-backups/pre-migration-*`.
Later installer backups are under `~/.dotfiles-backups/install-*`. To restore
Neovim's old physical directory, close Neovim, remove only the junction with
PowerShell `cmd /c rmdir "$env:LOCALAPPDATA\nvim"` (no `/s`), then copy the backup
`nvim` directory there. Restore the original WezTerm/Nushell files from the same
snapshot if reverting those apps. Never recursively delete a junction's contents.
