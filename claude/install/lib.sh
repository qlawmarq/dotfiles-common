#!/bin/bash
# ============================================================
# Claude Code CLI install methods
#
# Shared by dotfiles-macos and dotfiles-linux: the claude module's
# cli step sources cli.sh, which sources this file. Requires the
# parent repository's lib/utils.sh (print_*, confirm, command_exists)
# and lib/menu.sh (smart_select_items). Runs under bash (3.2 on macOS);
# not dash.
#
# Each method lives in methods/<id>.sh and defines:
#   cim_<id>_command    command whose presence makes the method selectable
#   cim_<id>_installed  exit 0 when Claude Code is installed this way
#   cim_<id>_detail     extra text for display (may print nothing)
#   cim_<id>_install    install the latest release
#   cim_<id>_update     update an existing install
#   cim_<id>_uninstall  remove it, following the official instructions
#
# To add a method, write methods/<id>.sh and append <id> below.
# Commands follow https://code.claude.com/docs/en/setup.
# ============================================================

# Display order; the first entry is the officially recommended method
CLAUDE_INSTALL_METHODS="native brew npm apt dnf"

CLAUDE_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _cim_m in $CLAUDE_INSTALL_METHODS; do
    . "$CLAUDE_INSTALL_DIR/methods/$_cim_m.sh"
done
unset _cim_m

# Usage: cim_in_list WORD "list of words"
cim_in_list() {
    case " $2 " in
        *" $1 "*) return 0 ;;
    esac
    return 1
}

# Methods Claude Code is currently installed with (space-separated)
cim_detected() {
    local m out
    out=""
    for m in $CLAUDE_INSTALL_METHODS; do
        "cim_${m}_installed" && out="$out $m"
    done
    printf '%s\n' "${out# }"
}

# Methods to offer: selectable here, or already installed
# Usage: cim_choices "$DETECTED"
cim_choices() {
    local m out
    out=""
    for m in $CLAUDE_INSTALL_METHODS; do
        if command_exists "$("cim_${m}_command")" || cim_in_list "$m" "$1"; then
            out="$out $m"
        fi
    done
    printf '%s\n' "${out# }"
}

# Print how Claude Code is installed and every claude on PATH.
# Usage: cim_report "$DETECTED"
cim_report() {
    local m d p v count
    count=0
    for m in $1; do
        d=$("cim_${m}_detail")
        print_info "Installed via: $m${d:+ ($d)}"
        count=$((count + 1))
    done
    [ "$count" -eq 0 ] && print_info "Claude Code is not installed by any known method ($CLAUDE_INSTALL_METHODS)"

    if type -ap claude >/dev/null 2>&1; then
        print_info "claude on PATH (the first one runs):"
        # awk drops repeats of a directory listed twice in PATH
        type -ap claude | awk '!seen[$0]++' | while IFS= read -r p; do
            v=$("$p" --version 2>/dev/null | head -n 1)
            print_info "  $p  ${v:-(does not run)}"
        done
    fi

    if [ "$count" -gt 1 ]; then
        print_warning "Multiple installations found; keep only one"
        print_info "  https://code.claude.com/docs/en/troubleshoot-install#check-for-conflicting-installations"
    fi
}
