#!/usr/bin/env bash
# Stop push-to-talk recording, wait for whisper to be ready, transcribe,
# type at cursor + clipboard, then unload whisper.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/ai-services.sh"

PARAKEET_URL="${PARAKEET_URL:-$WHISPER_URL/v1/audio/transcriptions}"
STT_MODEL="${STT_MODEL:-$WHISPER_MODEL}"
PUSH_WAV="${TMPDIR:-/tmp}/stt-push.wav"
PUSH_PID="${TMPDIR:-/tmp}/stt-push.pid"
STT_KEEP_WHISPER="${STT_KEEP_WHISPER:-0}"  # set 1 to skip stop_whisper

cleanup() { rm -f "$PUSH_WAV" "$PUSH_PID"; }
trap cleanup EXIT

[[ -f "$PUSH_PID" ]] || { echo "stt-stop: not recording" >&2; exit 0; }

PID=$(cat "$PUSH_PID")
kill "$PID" 2>/dev/null || true
rm -f "$PUSH_PID"
sleep 0.5
[[ -s "$PUSH_WAV" ]] || { notify-send -u low "STT" "No audio captured"; exit 0; }

notify-send -t 2000 "STT" "Transcribing…"
wait_whisper 40 || exit 1

TEXT=""
if command -v parakeet-mlx &>/dev/null; then
  TEXT=$(parakeet-mlx "$PUSH_WAV" --output-format txt 2>/dev/null || true)
else
  TEXT=$(curl -sf --max-time 30 -X POST "$PARAKEET_URL" \
    -F "file=@$PUSH_WAV" \
    -F "model=$STT_MODEL" \
    2>/dev/null | jq -r '.text // empty') || true
fi

[[ "$STT_KEEP_WHISPER" = "1" ]] || stop_whisper

TEXT=$(printf '%s' "$TEXT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[[ -n "$TEXT" ]] || { notify-send -u low "STT" "Empty transcription"; exit 0; }

printf '%s' "$TEXT" | wl-copy
sleep 0.5
if command -v ydotool &>/dev/null; then
  SOCK="${YDOTOOL_SOCKET:-${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/.ydotool_socket}"
  YDOTOOL_SOCKET="$SOCK" ydotool type -- "$TEXT"
fi
notify-send -t 3000 "STT" "Inserted: ${TEXT:0:60}${TEXT:+…}"
