#!/usr/bin/env bash
# Push-to-talk STT: start recording (hold or press again to stop via stt-stop.sh).
# Notify on start. Requires same deps as stt.sh; run stt-stop.sh to stop and transcribe.

PUSH_WAV="${TMPDIR:-/tmp}/stt-push.wav"
PUSH_PID="${TMPDIR:-/tmp}/stt-push.pid"

if [[ -f "$PUSH_PID" ]]; then
  # Already recording; stop is handled by stt-stop.sh
  exit 0
fi

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
notify-send -t 30000 "STT" "Recording…"
