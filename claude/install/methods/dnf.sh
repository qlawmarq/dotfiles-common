# Anthropic's signed rpm repository (Fedora, RHEL), latest channel.
# Needs sudo; dnf asks to confirm the signing key on first install, so run
# from a terminal.

CIM_DNF_REPO="/etc/yum.repos.d/claude-code.repo"

cim_dnf_command() { echo dnf; }

# The official docs give no detection command; this is the rpm database
cim_dnf_installed() { command_exists rpm && rpm -q claude-code >/dev/null 2>&1; }

cim_dnf_detail() { :; }

cim_dnf_install() {
    sudo tee "$CIM_DNF_REPO" >/dev/null <<'REPO' || return 1
[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/latest
enabled=1
gpgcheck=1
gpgkey=https://downloads.claude.ai/keys/claude-code.asc
REPO
    print_info "Accept the key only if its fingerprint is 31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE"
    sudo dnf install claude-code
}

cim_dnf_update() { sudo dnf upgrade claude-code; }

cim_dnf_uninstall() { sudo dnf remove claude-code && sudo rm -f "$CIM_DNF_REPO"; }
