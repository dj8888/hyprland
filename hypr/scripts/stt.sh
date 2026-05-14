#!/usr/bin/env bash
# Speech-to-text: record mic → Parakeet → type at cursor (ydotool) and clipboard (wl-copy).
# Requires: sox or ffmpeg, wl-clipboard, ydotool; Parakeet ASR service or parakeet-mlx.

set -e
RECORD_SECONDS="${RECORD_SECONDS:-10}"
PARAKEET_URL="${PARAKEET_URL:-http://127.0.0.1:9001/v1/audio/transcriptions}"
STT_MODEL="${STT_MODEL:-Systran/faster-whisper-medium}"
NOTIFY="${STT_NOTIFY:-0}"
WORK_DIR="${TMPDIR:-/tmp}/stt-$$"
RECORDING_PID_FILE="${TMPDIR:-/tmp}/stt-recording.pid"

cleanup() {
  rm -rf "$WORK_DIR"
  rm -f "$RECORDING_PID_FILE"
}
trap cleanup EXIT

mkdir -p "$WORK_DIR"
WAV="$WORK_DIR/rec.wav"

# --- Recording ---
if command -v sox &>/dev/null; then
  RECORDER=(sox -q -d -t wav -c 1 -r 16000 -b 16 "$WAV" trim 0 "$RECORD_SECONDS")
elif command -v ffmpeg &>/dev/null; then
  RECORDER=(ffmpeg -y -loglevel error -f pulse -i default -ar 16000 -ac 1 -t "$RECORD_SECONDS" "$WAV")
else
  echo "stt: need sox or ffmpeg for recording" >&2
  exit 1
fi

if [[ "$NOTIFY" == "1" ]]; then
  notify-send -t 2000 "STT" "Recording ${RECORD_SECONDS}s…"
fi

if ! "${RECORDER[@]}" 2>/dev/null; then
  if [[ "$NOTIFY" == "1" ]]; then
    notify-send -u critical "STT" "Mic unavailable or recording failed"
  fi
  echo "stt: recording failed (check mic)" >&2
  exit 1
fi

[[ -f "$WAV" && -s "$WAV" ]] || {
  echo "stt: no audio captured" >&2
  exit 1
}

if [[ "$NOTIFY" == "1" ]]; then
  notify-send -t 2000 "STT" "Transcribing…"
fi

# --- Transcription ---
TEXT=""
if command -v parakeet-mlx &>/dev/null; then
  TEXT=$(parakeet-mlx "$WAV" --output-format txt 2>/dev/null || true)
else
  TEXT=$(curl -sf --max-time 30 -X POST "$PARAKEET_URL" \
    -F "file=@$WAV" \
    -F "model=$STT_MODEL" \
    2>/dev/null | jq -r '.text // empty') || true
fi

if [[ -z "$TEXT" ]]; then
  if [[ "$NOTIFY" == "1" ]]; then
    notify-send -u critical "STT" "Parakeet unavailable or empty (service or parakeet-mlx)"
  fi
  echo "stt: Parakeet not available or empty (start service or install parakeet-mlx)" >&2
  exit 1
fi

TEXT=$(echo -n "$TEXT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[[ -n "$TEXT" ]] || {
  echo "stt: empty transcription" >&2
  exit 0
}

# --- Output: clipboard and type ---
printf '%s' "$TEXT" | wl-copy
if command -v ydotool &>/dev/null; then
  if [[ -S /tmp/ydotool_socket ]]; then
    YDOTOOL_SOCKET=/tmp/ydotool_socket ydotool type -- "$TEXT"
  else
    ydotool type -- "$TEXT"
  fi
fi

if [[ "$NOTIFY" == "1" ]]; then
  notify-send -t 3000 "STT" "Inserted: ${TEXT:0:60}${TEXT:+…}"
fi
