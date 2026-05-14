#!/usr/bin/env bash
# Push-to-talk STT: start recording AND start loading whisper in parallel.
# Stop with stt-stop.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/ai-services.sh"

PUSH_WAV="${TMPDIR:-/tmp}/stt-push.wav"
PUSH_PID="${TMPDIR:-/tmp}/stt-push.pid"

if [[ -f "$PUSH_PID" ]]; then
  exit 0  # already recording; stt-stop.sh handles teardown
fi

# Kick off whisper load in the background — it warms up while you talk.
start_whisper

notify-send -t 1000 "STT" "Get ready…"
sleep 1

if command -v sox &>/dev/null; then
  sox -q -d -t wav -c 1 -r 16000 -b 16 "$PUSH_WAV" &
elif command -v ffmpeg &>/dev/null; then
  ffmpeg -y -loglevel error -f pulse -i default -ar 16000 -ac 1 -f wav "$PUSH_WAV" &
else
  echo "stt-push: need sox or ffmpeg" >&2
  exit 1
fi
echo $! > "$PUSH_PID"
notify-send -t 1500 "STT" "Recording…"
