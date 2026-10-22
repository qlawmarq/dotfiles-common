# Step: install / update the Claude Code CLI
#
# Sourced by the claude module's steps/cli.sh in dotfiles-macos and
# dotfiles-linux. Shows how Claude Code is installed, lets the user
# pick a method (CLAUDE_INSTALL_METHOD=<id> skips the question), then
# offers to remove installs made with other methods: the official
# troubleshooting guide says to keep only one.

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

DETECTED=$(cim_detected)
cim_report "$DETECTED"

CHOICES=$(cim_choices "$DETECTED")
if [ -z "$CHOICES" ]; then
    print_warning "No install method available - skipping Claude Code CLI install"
    return 0
fi

METHOD="${CLAUDE_INSTALL_METHOD:-}"
if [ -z "$METHOD" ]; then
    # Same test as the dispatcher: without a terminal, report only
    if [ ! -t 0 ]; then
        print_info "Not a terminal - skipped (set CLAUDE_INSTALL_METHOD to one of: $CHOICES)"
        return 0
    fi
    smart_select_items --single \
        "Claude Code install method (installed: ${DETECTED:-none}; select none to skip)" $CHOICES
    METHOD="$SELECTED_ITEMS"
    if [ -z "$METHOD" ]; then
        print_info "Skipped"
        return 0
    fi
fi

if ! cim_in_list "$METHOD" "$CHOICES"; then
    print_error "Install method '$METHOD' is not available here (available: $CHOICES)"
    return 1
fi

# Under WSL this can be a Windows binary (/mnt/c/...)
CMD=$("cim_${METHOD}_command")
print_info "Using $CMD: $(command -v "$CMD")"

if cim_in_list "$METHOD" "$DETECTED"; then
    print_info "Updating Claude Code via $METHOD..."
    ACTION=update
else
    print_info "Installing Claude Code via $METHOD..."
    ACTION=install
fi
if ! "cim_${METHOD}_${ACTION}"; then
    print_error "Claude Code $ACTION via $METHOD failed"
    return 1
fi
print_success "Claude Code $ACTION via $METHOD completed"

for m in $DETECTED; do
    [ "$m" = "$METHOD" ] && continue
    if confirm "Also installed via $m. Remove that installation?"; then
        if "cim_${m}_uninstall"; then
            print_success "Removed the $m installation"
        else
            print_error "Removing the $m installation failed"
        fi
    fi
done

cim_report "$(cim_detected)"
