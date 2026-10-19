# config.nu
#
# Installed by:
# version = "0.112.2"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.buffer_editor = "nvim"
# Set WTTR_CITY in your user environment for a private default weather location.
$env.WTTR_CITY = ($env.WTTR_CITY? | default "")
$env.YAZI_FILE_ONE = "C:/Program Files/Git/usr/bin/file.exe"
$env.BAT_PAGER = "ov -F"

# Disable startup message
$env.config.show_banner = false

use ~/.config/nushell/scripts/git-completions.nu *
use ~/.config/nushell/scripts/cargo-completions.nu *
use ~/.config/nushell/scripts/uv-completions.nu *

# Aliases
alias vi = nvim
alias vim = nvim
alias lsa = ls -a
alias wslh = wsl --cd "~" -e nu

zoxide init nushell | save -f ~/.zoxide.nu
source ~/.config/zoxide/.zoxide.nu
