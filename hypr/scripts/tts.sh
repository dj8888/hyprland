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

# ONNX Runtime 1.26 needs CUDA 12 + cuDNN 9 libs. Arch ships CUDA 13 system-wide,
# so we rely on the CUDA-12 wheels installed inside the kokoro venv. Build a
# LD_LIBRARY_PATH pointing at every nvidia/*/lib dir in the venv.
KOKORO_VENV="${KOKORO_VENV:-$HOME/.local/share/uv/tools/kokoro-tts}"
KOKORO_NVIDIA_LIBS=""
if [[ -d "$KOKORO_VENV/lib/python3.12/site-packages/nvidia" ]]; then
  KOKORO_NVIDIA_LIBS=$(printf '%s:' "$KOKORO_VENV"/lib/python3.12/site-packages/nvidia/*/lib | sed 's/:$//')
fi

# Run kokoro on the dGPU via prime-run + CUDA ORT provider. Falls back to CPU
# if the GPU run fails (missing kernel, OOM, no card visible to the offload
# context). Set KOKORO_PROVIDER=CPUExecutionProvider to force CPU.
run_kokoro() {
  local provider="$1"
  if [[ "$provider" = "CUDAExecutionProvider" ]] && command -v prime-run &>/dev/null; then
    if [[ -d "$KOKORO_DIR" ]]; then
      (cd "$KOKORO_DIR" && \
        LD_LIBRARY_PATH="${KOKORO_NVIDIA_LIBS}:/opt/cuda/lib64:${LD_LIBRARY_PATH:-}" \
        ONNX_PROVIDER="$provider" \
        prime-run kokoro-tts - "$OUT" "${KOKORO_ARGS[@]}" <<<"$TEXT") 2>/dev/null
    else
      LD_LIBRARY_PATH="${KOKORO_NVIDIA_LIBS}:/opt/cuda/lib64:${LD_LIBRARY_PATH:-}" \
      ONNX_PROVIDER="$provider" \
      prime-run kokoro-tts - "$OUT" "${KOKORO_ARGS[@]}" <<<"$TEXT" 2>/dev/null
    fi
  else
    if [[ -d "$KOKORO_DIR" ]]; then
      (cd "$KOKORO_DIR" && ONNX_PROVIDER="$provider" \
        kokoro-tts - "$OUT" "${KOKORO_ARGS[@]}" <<<"$TEXT") 2>/dev/null
    else
      ONNX_PROVIDER="$provider" \
      kokoro-tts - "$OUT" "${KOKORO_ARGS[@]}" <<<"$TEXT" 2>/dev/null
    fi
  fi
}

KOKORO_PROVIDER="${KOKORO_PROVIDER:-CUDAExecutionProvider}"
run_kokoro "$KOKORO_PROVIDER" || true
if [[ ! -s "$OUT" && "$KOKORO_PROVIDER" != "CPUExecutionProvider" ]]; then
  notify-send -t 2000 "TTS" "GPU failed, falling back to CPU"
  run_kokoro "CPUExecutionProvider" || true
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
