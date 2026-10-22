# Homebrew cask. claude-code tracks the stable channel, claude-code@latest
# the latest one; new installs use claude-code@latest.

cim_brew_command() { echo brew; }

# Name of the installed cask; fails when neither is installed
cim_brew_cask() {
    local c
    command_exists brew || return 1
    for c in claude-code@latest claude-code; do
        if brew list --cask "$c" >/dev/null 2>&1; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

cim_brew_installed() { cim_brew_cask >/dev/null; }

cim_brew_detail() { cim_brew_cask; }

cim_brew_install() { brew install --cask claude-code@latest; }

cim_brew_update() { brew upgrade --cask "$(cim_brew_cask)"; }

cim_brew_uninstall() { brew uninstall --cask "$(cim_brew_cask)"; }
