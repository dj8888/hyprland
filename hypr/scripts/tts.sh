#!/usr/bin/env bash
# Text-to-speech: clipboard or argument → Kokoro TTS → mpv.
# Requires: wl-clipboard, kokoro-tts (uv tool), mpv.

TTS_PID_FILE="${TMPDIR:-/tmp}/tts.pid"
WORK_DIR="${TMPDIR:-/tmp}/tts-$$"
KOKORO_DIR="${KOKORO_DIR:-$HOME/.local/share/kokoro-tts}"
KOKORO_VOICE="${KOKORO_VOICE:-af_bella:40,af_nicole:60}"
KOKORO_SPEED="${KOKORO_SPEED:-0.92}"
KOKORO_LANG="${KOKORO_LANG:-en-us}"

# Kill any running TTS playback
if [[ -f "$TTS_PID_FILE" ]]; then
  OLD_PID=$(cat "$TTS_PID_FILE")
  kill "$OLD_PID" 2>/dev/null || true
  rm -f "$TTS_PID_FILE"
fi

cleanup() {
  rm -rf "$WORK_DIR"
  rm -f "$TTS_PID_FILE"
}
trap cleanup EXIT

mkdir -p "$WORK_DIR"
OUT="$WORK_DIR/out.wav"

if [[ -n "$*" ]]; then
  TEXT="$*"
else
  TEXT=$(wl-paste -n 2>/dev/null || true)
fi

# Strip markdown / characters that TTS reads literally (asterisks, underscores,
# backticks, leading hashes, link syntax). Keep punctuation that shapes prosody.
TEXT=$(printf '%s' "$TEXT" \
  | sed -E 's/\[([^]]+)\]\([^)]+\)/\1/g' \
  | sed -E 's/[*_`]+//g' \
  | sed -E 's/^[[:space:]]*#+[[:space:]]*//g' \
  | sed -E 's/[[:space:]]+/ /g')

[[ -n "$TEXT" ]] || {
  notify-send -u low "TTS" "No text (clipboard empty)"
  echo "tts: no text (use clipboard or pass as arguments)" >&2
  exit 1
}

PREVIEW_GEN="${TEXT:0:60}"
[[ ${#TEXT} -gt 60 ]] && PREVIEW_GEN+="…"
notify-send -t 1500 "TTS" "Generating: $PREVIEW_GEN"

if ! command -v kokoro-tts &>/dev/null; then
  notify-send -u critical "TTS" "kokoro-tts not found"
  echo "tts: kokoro-tts not found (pip install kokoro-tts)" >&2
  exit 1
fi

if ! command -v mpv &>/dev/null; then
  notify-send -u critical "TTS" "mpv not found"
  echo "tts: mpv not found" >&2
  exit 1
fi

KOKORO_ARGS=(--format wav --voice "$KOKORO_VOICE" --speed "$KOKORO_SPEED" --lang "$KOKORO_LANG")
if [[ -d "$KOKORO_DIR" ]]; then
  (cd "$KOKORO_DIR" && printf '%s' "$TEXT" | kokoro-tts - "$OUT" "${KOKORO_ARGS[@]}") 2>/dev/null || true
else
  printf '%s' "$TEXT" | kokoro-tts - "$OUT" "${KOKORO_ARGS[@]}" 2>/dev/null || true
fi

[[ -f "$OUT" && -s "$OUT" ]] || {
  notify-send -u critical "TTS" "Kokoro produced no audio (check model files)"
  echo "tts: Kokoro produced no audio (check model files in KOKORO_DIR)" >&2
  exit 1
}

PREVIEW="${TEXT:0:50}"
[[ ${#TEXT} -gt 50 ]] && PREVIEW+="…"
notify-send -t 4000 "TTS" "Speaking: $PREVIEW"

mpv --no-terminal --no-video "$OUT" 2>/dev/null &
MPV_PID=$!
echo $MPV_PID > "$TTS_PID_FILE"
wait $MPV_PID
