#!/usr/bin/env bash
# Manually end any Ponti chat session: clear history, unload whisper + ollama.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/ai-services.sh"

STATE_DIR="${PONTI_STATE_DIR:-$HOME/.local/state/ponti}"
rm -f "$STATE_DIR/conversation.json"
rm -f /tmp/ponti-oneshot-rec.pid /tmp/ponti-chat-rec.pid
rm -f /tmp/ponti-oneshot-rec.wav /tmp/ponti-chat-rec.wav
stop_whisper
stop_ollama
notify-send -a "Ponti" -t 2500 "Ponti" "Stopped. Conversation cleared."
