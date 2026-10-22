# Anthropic's signed apt repository (Debian, Ubuntu), latest channel.
# Needs sudo; run from a terminal.

CIM_APT_KEY="/etc/apt/keyrings/claude-code.asc"
CIM_APT_LIST="/etc/apt/sources.list.d/claude-code.list"
CIM_APT_FINGERPRINT="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"

cim_apt_command() { echo apt; }

# The official docs give no detection command; this is the dpkg package state
cim_apt_installed() {
    command_exists dpkg-query || return 1
    [ "$(dpkg-query -W -f='${Status}' claude-code 2>/dev/null)" = "install ok installed" ]
}

cim_apt_detail() { :; }

cim_apt_install() {
    if ! command_exists curl || ! command_exists gpg; then
        sudo apt install curl gnupg || return 1
    fi
    sudo install -d -m 0755 /etc/apt/keyrings || return 1
    sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o "$CIM_APT_KEY" || return 1
    if ! gpg --show-keys --with-colons "$CIM_APT_KEY" 2>/dev/null \
        | awk -F: '$1 == "fpr" { print $10 }' | grep -qx "$CIM_APT_FINGERPRINT"; then
        print_error "Signing key fingerprint is not $CIM_APT_FINGERPRINT - aborting"
        sudo rm -f "$CIM_APT_KEY"
        return 1
    fi
    echo "deb [signed-by=$CIM_APT_KEY] https://downloads.claude.ai/claude-code/apt/latest latest main" \
        | sudo tee "$CIM_APT_LIST" >/dev/null || return 1
    sudo apt update && sudo apt install claude-code
}

cim_apt_update() { sudo apt update && sudo apt upgrade claude-code; }

cim_apt_uninstall() { sudo apt remove claude-code && sudo rm -f "$CIM_APT_LIST" "$CIM_APT_KEY"; }
