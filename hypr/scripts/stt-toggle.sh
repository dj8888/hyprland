#!/usr/bin/env bash
# Toggle STT recording: start if idle, stop + transcribe if recording.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUSH_PID="${TMPDIR:-/tmp}/stt-push.pid"

if [[ -f "$PUSH_PID" ]]; then
  "$SCRIPT_DIR/stt-stop.sh"
else
  "$SCRIPT_DIR/stt-push.sh"
fi
