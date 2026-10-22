# Native installer, the officially recommended method.
# Launcher: ~/.local/bin/claude, a symlink into ~/.local/share/claude/versions/

CIM_NATIVE_BIN="$HOME/.local/bin/claude"

cim_native_command() { echo curl; }

# The troubleshooting guide identifies a native install by this path
cim_native_installed() { [ -e "$CIM_NATIVE_BIN" ] || [ -L "$CIM_NATIVE_BIN" ]; }

cim_native_detail() { echo "$CIM_NATIVE_BIN"; }

# pipefail: otherwise a failed download pipes nothing into bash and succeeds
cim_native_install() { ( set -o pipefail; curl -fsSL https://claude.ai/install.sh | bash ); }

# Full path: an earlier claude on PATH (e.g. a stale mise shim) must not answer
cim_native_update() { "$CIM_NATIVE_BIN" update; }

cim_native_uninstall() { rm -f "$CIM_NATIVE_BIN" && rm -rf "$HOME/.local/share/claude"; }
