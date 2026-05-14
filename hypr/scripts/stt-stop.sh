#!/usr/bin/env bash
# Stop push-to-talk recording and transcribe (same logic as stt.sh).
# Requires: stt.sh in same directory (sourced or run); same deps.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARAKEET_URL="${PARAKEET_URL:-http://127.0.0.1:9001/v1/audio/transcriptions}"
STT_MODEL="${STT_MODEL:-Systran/faster-whisper-medium}"
PUSH_WAV="${TMPDIR:-/tmp}/stt-push.wav"
PUSH_PID="${TMPDIR:-/tmp}/stt-push.pid"

cleanup() {
  rm -f "$PUSH_WAV" "$PUSH_PID"
}
trap cleanup EXIT

if [[ ! -f "$PUSH_PID" ]]; then
  echo "stt-stop: not recording" >&2
  exit 0
fi

PID=$(cat "$PUSH_PID")
kill "$PID" 2>/dev/null || true
rm -f "$PUSH_PID"
sleep 0.5
[[ -f "$PUSH_WAV" && -s "$PUSH_WAV" ]] || {
  notify-send -u low "STT" "No audio captured"
  exit 0
}

notify-send -t 2000 "STT" "Transcribing…"

TEXT=""
if command -v parakeet-mlx &>/dev/null; then
  TEXT=$(parakeet-mlx "$PUSH_WAV" --output-format txt 2>/dev/null || true)
else
  TEXT=$(curl -sf --max-time 30 -X POST "$PARAKEET_URL" \
    -F "file=@$PUSH_WAV" \
    -F "model=$STT_MODEL" \
    2>/dev/null | jq -r '.text // empty') || true
fi

TEXT=$(echo -n "$TEXT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[[ -n "$TEXT" ]] || {
  notify-send -u low "STT" "Empty transcription"
  exit 0
}

printf '%s' "$TEXT" | wl-copy
sleep 0.5
if command -v ydotool &>/dev/null; then
  if [[ -S /tmp/ydotool_socket ]]; then
    YDOTOOL_SOCKET=/tmp/ydotool_socket ydotool type -- "$TEXT"
  else
    ydotool type -- "$TEXT"
  fi
fi
notify-send -t 3000 "STT" "Stopped. Inserted: ${TEXT:0:60}${TEXT:+…}"
