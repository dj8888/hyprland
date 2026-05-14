#!/usr/bin/env bash
# Single-shot STT: record N seconds → transcribe → type at cursor + clipboard.
# Lazy-loads whisper in parallel with recording, unloads after.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/ai-services.sh"

RECORD_SECONDS="${RECORD_SECONDS:-10}"
PARAKEET_URL="${PARAKEET_URL:-$WHISPER_URL/v1/audio/transcriptions}"
STT_MODEL="${STT_MODEL:-$WHISPER_MODEL}"
NOTIFY="${STT_NOTIFY:-0}"
STT_KEEP_WHISPER="${STT_KEEP_WHISPER:-0}"
WORK_DIR="${TMPDIR:-/tmp}/stt-$$"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

mkdir -p "$WORK_DIR"
WAV="$WORK_DIR/rec.wav"

# Kick whisper load in parallel with recording.
start_whisper

if command -v sox &>/dev/null; then
  RECORDER=(sox -q -d -t wav -c 1 -r 16000 -b 16 "$WAV" trim 0 "$RECORD_SECONDS")
elif command -v ffmpeg &>/dev/null; then
  RECORDER=(ffmpeg -y -loglevel error -f pulse -i default -ar 16000 -ac 1 -t "$RECORD_SECONDS" "$WAV")
else
  echo "stt: need sox or ffmpeg for recording" >&2
  exit 1
fi

[[ "$NOTIFY" == "1" ]] && notify-send -t 2000 "STT" "Recording ${RECORD_SECONDS}s…"

if ! "${RECORDER[@]}" 2>/dev/null; then
  [[ "$NOTIFY" == "1" ]] && notify-send -u critical "STT" "Mic unavailable"
  exit 1
fi

[[ -s "$WAV" ]] || { echo "stt: no audio captured" >&2; exit 1; }

[[ "$NOTIFY" == "1" ]] && notify-send -t 2000 "STT" "Transcribing…"
wait_whisper 40 || exit 1

TEXT=""
if command -v parakeet-mlx &>/dev/null; then
  TEXT=$(parakeet-mlx "$WAV" --output-format txt 2>/dev/null || true)
else
  TEXT=$(curl -sf --max-time 30 -X POST "$PARAKEET_URL" \
    -F "file=@$WAV" \
    -F "model=$STT_MODEL" \
    2>/dev/null | jq -r '.text // empty') || true
fi

[[ "$STT_KEEP_WHISPER" = "1" ]] || stop_whisper

TEXT=$(printf '%s' "$TEXT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[[ -n "$TEXT" ]] || { echo "stt: empty transcription" >&2; exit 0; }

printf '%s' "$TEXT" | wl-copy
if command -v ydotool &>/dev/null; then
  SOCK="${YDOTOOL_SOCKET:-${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/.ydotool_socket}"
  YDOTOOL_SOCKET="$SOCK" ydotool type -- "$TEXT"
fi

[[ "$NOTIFY" == "1" ]] && notify-send -t 3000 "STT" "Inserted: ${TEXT:0:60}${TEXT:+…}"
