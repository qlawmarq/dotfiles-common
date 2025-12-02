#!/bin/bash

# ====================
# Claude Code Notification Script
# ====================
# This script sends notifications based on Claude Code hook events.
# It reads JSON input from stdin and sends notifications via configured method.

# Default configuration
NOTIFICATION_TYPE="local"
LOCAL_SOUND_NAME="Glass"
WEBHOOK_URL=""

# Load configuration if exists
CONFIG_FILE="$HOME/.claude/hooks/notify-config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Read JSON input from stdin
INPUT=$(cat)

# Extract hook event name
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "Unknown"')

# Determine message based on hook event
case "$HOOK_EVENT" in
    "Notification")
        # For Notification events, extract the message field
        MESSAGE=$(echo "$INPUT" | jq -r '.message // "Notification from Claude Code"')
        ;;
    "Stop")
        # For Stop events, use a completion message
        MESSAGE="作業が完了しました。"
        ;;
    *)
        # For other events, use a generic message
        MESSAGE="Event: $HOOK_EVENT"
        ;;
esac

# Send notification based on configured type
case "$NOTIFICATION_TYPE" in
    "local")
        # Send macOS notification
        osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\" sound name \"$LOCAL_SOUND_NAME\""
        echo "[ローカル通知] $MESSAGE" >&2
        ;;
    "webhook")
        # Send webhook notification
        if [ -n "$WEBHOOK_URL" ]; then
            curl -s -X POST -d "$MESSAGE" "$WEBHOOK_URL" >/dev/null 2>&1
            echo "[Webhook通知] $MESSAGE" >&2
        else
            echo "[ERROR] Webhook URL is not configured" >&2
            exit 1
        fi
        ;;
    *)
        echo "[ERROR] Unknown notification type: $NOTIFICATION_TYPE" >&2
        exit 1
        ;;
esac

exit 0
