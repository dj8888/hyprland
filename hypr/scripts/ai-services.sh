#!/usr/bin/env bash
# ai-services.sh — shared helpers for lazy-loading whisper + ollama on the dGPU.
# Source from other scripts: . "$(dirname "$0")/ai-services.sh"

WHISPER_PORT="${WHISPER_PORT:-9001}"
WHISPER_MODEL="${WHISPER_MODEL:-Systran/faster-whisper-medium}"
WHISPER_URL="${WHISPER_URL:-http://127.0.0.1:$WHISPER_PORT}"
WHISPER_LOG="${WHISPER_LOG:-/tmp/whisper-server.log}"

OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"
OLLAMA_LOG="${OLLAMA_LOG:-/tmp/ollama-serve.log}"

notify_ai() { notify-send -a "Ponti" "$@"; }

_whisper_ready() {
  curl -sf --max-time 1 "$WHISPER_URL/openapi.json" >/dev/null 2>&1
}

_ollama_ready() {
  curl -sf --max-time 1 "$OLLAMA_URL/api/tags" >/dev/null 2>&1
}

start_whisper() {
  _whisper_ready && return 0
  notify_ai -t 2000 "Whisper" "Loading model on dGPU…"
  nohup bash -c "LD_LIBRARY_PATH=/opt/cuda/lib64:\$LD_LIBRARY_PATH prime-run faster-whisper-server --port $WHISPER_PORT $WHISPER_MODEL" >"$WHISPER_LOG" 2>&1 &
  disown
}

wait_whisper() {
  local timeout="${1:-40}"
  for _ in $(seq 1 $((timeout * 2))); do
    _whisper_ready && return 0
    sleep 0.5
  done
  notify_ai -u critical "Whisper" "Did not become ready in ${timeout}s"
  return 1
}

ensure_whisper() {
  _whisper_ready && return 0
  start_whisper
  wait_whisper "${1:-40}"
}

stop_whisper() {
  if pgrep -f "faster-whisper-server" >/dev/null 2>&1; then
    notify_ai -t 1500 "Whisper" "Unloading"
    pkill -f "faster-whisper-server" 2>/dev/null || true
  fi
}

start_ollama() {
  _ollama_ready && return 0
  notify_ai -t 2000 "Ollama" "Starting on dGPU…"
  nohup prime-run ollama serve >"$OLLAMA_LOG" 2>&1 &
  disown
}

wait_ollama() {
  local timeout="${1:-30}"
  for _ in $(seq 1 $((timeout * 2))); do
    _ollama_ready && return 0
    sleep 0.5
  done
  notify_ai -u critical "Ollama" "Did not become ready in ${timeout}s"
  return 1
}

ensure_ollama() {
  _ollama_ready && return 0
  start_ollama
  wait_ollama "${1:-30}"
}

stop_ollama() {
  if pgrep -f "ollama serve" >/dev/null 2>&1; then
    notify_ai -t 1500 "Ollama" "Unloading"
    pkill -f "ollama serve" 2>/dev/null || true
  fi
}
