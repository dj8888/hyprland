# hyprland config files

## Table of Contents

-   [Installation](#installation)
-   [One-time setup (per install)](#one-time-setup-per-install)
-   [Dependencies](#dependencies)
-   [Hybrid GPU (Intel + NVIDIA PRIME)](#hybrid-gpu-intel--nvidia-prime)
-   [Speech-to-Text, Text-to-Speech, and Ponti (local voice AI)](#speech-to-text-text-to-speech-and-ponti-local-voice-ai)
-   [buildPDF](#buildpdf)
-   [tmux-file-picker](#tmux-file-picker)
-   [Claude Code Profiles](#claude-code-profiles)

## Installation

> Install the required dependencies based on your system manually and clone the repo in ~/.config/

### One-time setup (per install)

After cloning on a new system, symlink the pacman hook so Dolphin (and other KDE apps) get the correct applications menu and MIME defaults on Hyprland:

```bash
sudo mkdir -p /etc/pacman.d/hooks
sudo ln -sf ~/.config/pacman/hooks/arch-applications-menu.hook /etc/pacman.d/hooks/
```

Install `archlinux-xdg-menu` if you use Dolphin. Optional: add the options in `pacman/pacman.conf.snippet` to `/etc/pacman.conf`; if you need 32-bit packages (e.g. Steam, hybrid NVIDIA), enable `[multilib]` per `pacman/pacman.multilib.snippet`. See **[pacman/hooks/README.md](pacman/hooks/README.md)** for details.

## Dependencies

*(Packages used by this config. “Optional / extra” = not required for keybinds/scripts but useful or installed on the reference system.)*

### Essential Hyprland
- **hyprland**
- **hyprpaper** (static wallpapers)
- **hyprlock** (lock screen)
- **hypridle** (idle/DPMS)
- **hyprshot** (screenshots; keybinds `mainMod+N` / `mainMod+Shift+N`)
- **xdg-desktop-portal-hyprland** (screen sharing, file pickers)
- **wev** (input debugging; optional)

*Note: hyprnotify is not used in this config (exec-once is commented out). You can uninstall it if you use swaync for notifications.*

### Hyprland plugins (hyprpm)
- **hyprpm** (plugin manager; bundled with Hyprland). This config uses **hyprexpo** (workspace overview; gesture and `mainMod+TAB`). Install with:
  ```bash
  hyprpm add https://github.com/hyprland-community/hyprexpo
  ```

### Session / UI
- **waybar** (bar)
- **swaync** (notifications; gesture + `mainMod+M`)
- **swayosd** (volume/brightness on-screen display)
- **wofi** (app launcher, dmenu for cliphist/emoji)
- **wlogout** (logout menu; `mainMod+Shift+L`)
- **kitty** (terminal)
- **tmux**, **zsh**, **yazi**
  - **tmux-sessionizer**: `tns` (shell alias) launches it; in tmux use **`prefix + s`** to open it in a new window. (`~/.config/hypr/scripts` is on `PATH` via `zsh/.zprofile`.)
  - **tmux-file-picker**: fuzzy file/dir picker inside tmux popups. See [tmux-file-picker](#tmux-file-picker) below. Requires **fzf** and **fd**.
- **wl-clipboard** (required by cliphist and wofi-emoji; provides `wl-copy`)
- **cliphist** (clipboard history; `mainMod+V`)
- **wtype** (types selected text; required by wofi-emoji; `mainMod+.`)
- **playerctl** (media keys: play/pause, next, prev)
- **ly** (display manager; optional if you start Hyprland another way)

### Wallpaper scripts
- **mpvpaper** (live/video wallpapers)
- **jq** — lightweight CLI JSON processor. Used by `wallpaper_common.sh` to read monitor names from `hyprctl monitors -j` so mpvpaper can target each display. (Arch: `jq`)

### Tooling
- **dolphin** (file manager; `mainMod+F`)
- **tree**, **fzf**, **brightnessctl**
- **Notetaker / notes** (`mainMod+E`, `mainMod+Shift+E`):
  - [nvim](https://github.com/dj8888/.config-nvim) (recommended). In nvim: **`<leader>pd`** builds PDF from the current Markdown file using **buildPDF** (Mermaid diagram support; see [buildPDF](#buildpdf) below). Daily notes (`note-*.md`) build into `~/Documents/notes/pdf/` on save via **buildNote**.
  - **pandoc-cli** (or pandoc), **texlive-latexextra**, **texlive-xetex**, **texlive-fontsrecommended**
  - **zathura**, **zathura-pdf-poppler**

### Theming
- **qt6ct**, **qt5ct** (Qt theming)
- **kvantum** (e.g. theme: [Space](https://github.com/EliverLara/Space-kde))
- **nwg-look** (e.g. theme: [Orchis](https://github.com/vinceliuice/Orchis-theme)). This config uses the black variant; from the Orchis repo run:
  ```bash
  ./install.sh -t grey -c dark -s standard -l --tweaks black submenu
  ```
- **bibata-cursor-theme** — cursor theme in use: **Bibata-Original-Classic** (size 24; set in `hypr/hyprland.conf` via `HYPRCURSOR_THEME` / `XCURSOR_THEME`)
- **Cursor (IDE)** — color theme: **Black Italic** ([jaakko.black](https://github.com/Jaakkko/vscode-black-theme))
- **noto-fonts**, **noto-fonts-cjk**, **noto-fonts-extra**
- **ttf-fira-code**, **otf-font-awesome**
- **lsd** (fancy `ls`)
- **fastfetch** (system info at login / on demand; config in `fastfetch/`)

### Optional / extra
*Not required by this config’s keybinds or scripts; handy for a full desktop or other workflows.*

- **Android:** android-tools (adb, file transfer, debugging)
- **Bluetooth:** blueman, bluez, bluez-utils
- **Monitors / tuning:** btop, htop, nvtop, powertop
- **Network:** networkmanager, network-manager-applet, iwd (nm-applet is commented in config but useful for tray)
- **Audio:** pipewire, pipewire-alsa, pipewire-pulse, pavucontrol (needed for sound at all), **qpwgraph** (PipeWire graph GUI for audio routing)
- **Laptop:** thermald (thermal throttling)
- **Browsers / apps:** google-chrome, discord, spotify, mpv
- **Image viewer (XDG default):** sxiv — set as default for images in `mimeapps.list`; with the pacman hook and `kbuildsycoca6` at session start, Dolphin respects these defaults on Hyprland
- **Misc:** git, wget, tldr, man-pages, gdu
- **ASUS laptops:** asusctl, rog-control-center (keybinds for these are commented out in config)

---

## Hybrid GPU (Intel + NVIDIA PRIME)

This config targets **Intel iGPU as primary** (compositor, desktop, video decode) with **NVIDIA dGPU for PRIME offload** only when requested. The dGPU stays idle (low power) until you launch apps with `prime-run`. Applicable to laptops and desktops with Intel + NVIDIA.

### 1. Pacman and drivers

- **Enable multilib** if needed for `lib32-nvidia-utils`: add the `[multilib]` block from [pacman/pacman.multilib.snippet](pacman/pacman.multilib.snippet) to `/etc/pacman.conf`, then `sudo pacman -Sy`.
- Install NVIDIA and Vulkan packages:
  ```bash
  sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings nvidia-prime vulkan-intel vulkan-tools lib32-nvidia-utils
  ```

### 2. NVIDIA runtime power management

- Create `/etc/modprobe.d/nvidia-power.conf`:
  ```
  options nvidia NVreg_DynamicPowerManagement=0x02
  ```
- Rebuild initramfs: `sudo mkinitcpio -P`
- Enable and start: `sudo systemctl enable --now nvidia-powerd`

### 3. Hyprland (compositor on Intel)

The repo’s `hypr/hyprland.conf` already sets env vars so the compositor and desktop run on the Intel GPU; Vulkan apps can still offload to NVIDIA when launched with `prime-run`. **Do not** set `__NV_PRIME_RENDER_OFFLOAD=1` globally, or the dGPU will stay active.

Key ideas (see `hypr/hyprland.conf`): `LIBVA_DRIVER_NAME=iHD`, `GBM_BACKEND=intel-drm`, `WLR_DRM_DEVICES` pointing at the Intel DRM device (e.g. `/dev/dri/card0` or `card2` — check with `ls /dev/dri/` and pick the Intel card), and `__VK_LAYER_NV_optimus=NVIDIA_only` for offload.

### 4. Verify

- **Compositor on Intel:** `glxinfo | grep renderer` → expect Mesa Intel.
- **NVIDIA idle:** `nvidia-smi` → expect low power state (e.g. P8), no unwanted processes.
- **Runtime PM:** Check `power/control` and `power/runtime_status` under your NVIDIA PCI device (e.g. `/sys/bus/pci/devices/.../power/...`).

### 5. Launch apps on the dGPU

Use PRIME offload only when needed:

```bash
prime-run <app>
```

Examples: `prime-run steam`, `prime-run rpcs3`, `prime-run blender`.

### 6. Optional: RPCS3 and gamepad

- Install: `sudo pacman -S rpcs3`. Run with `prime-run rpcs3`. Install PS3 firmware via **File → Install Firmware** (download `PS3UPDAT.PUP` from Sony).
- In RPCS3: **PPU/SPU Decoder → LLVM**, **Renderer → Vulkan**, choose the NVIDIA device, **Shader Mode → Async**. Add games via **File → Add Games** (e.g. after extracting an ISO so the folder contains `PS3_GAME/` and `PS3_DISC.SFB`).
- Gamepad: install `jstest-gtk` and `game-devices-udev`, then **Pads → Configure Pads** (e.g. Handler **Evdev**, device `js0`), map to DualShock layout.

### 7. Debugging GPU usage

- See what’s using the dGPU: `nvidia-smi`; find processes: `sudo fuser -v /dev/nvidia*`.
- Monitor GPUs: **nvtop** (and optionally **qpwgraph** for PipeWire audio routing).

**Summary:** Compositor and desktop on Intel; video decode on Intel; games/Steam/RPCS3/Blender on NVIDIA via `prime-run`. dGPU stays in low power when not in use.

---

## Speech-to-Text, Text-to-Speech, and Ponti (local voice AI)

Lightweight, fully local voice stack for Hyprland: dictation (faster-whisper) → Kokoro TTS, plus **Ponti**, a voice-driven LLM assistant on top of `ollama` (gemma3:4b). Scripts live in `hypr/scripts/`.

The dGPU stays in low-power idle until a script needs it. `faster-whisper-server` and `ollama serve` are **lazy-loaded** on demand (with `prime-run`) and unloaded once the action completes — see [Lazy loading & dGPU power](#lazy-loading--dgpu-power) below.

### Keybindings

| Key | Script | Description |
|-----|--------|-------------|
| `Super+T` | `tts.sh` | Speak clipboard via Kokoro → mpv. Pressing again stops and restarts. |
| `Super+U` | `stt-toggle.sh` | **Dictation toggle.** 1st press: warm whisper + start recording (1s prep). 2nd press: stop, transcribe, type at cursor + clipboard, unload whisper. |
| `Super+A` | `ponti-ai-local.sh oneshot` | **Ponti — one-shot.** Voice question, single answer, no memory. Toggle: 1st press records, 2nd press transcribes → asks gemma3:4b → speaks reply, then unloads ollama + whisper. |
| `Super+Shift+A` | `ponti-ai-local.sh chat` | **Ponti — conversation.** Same toggle, but keeps chat history at `~/.local/state/ponti/conversation.json`. Auto-resets after 10 min idle. Say "bye ponti" / "end conversation" / "goodbye" to end and unload. |
| `Super+Ctrl+A` | `ponti-end.sh` | **Stop Ponti** manually — clear conversation, unload ollama + whisper. |
| `Super+X` | `swaync-client -t` | Toggle the notification panel. (Moved from `Super+A` to free that key for Ponti.) |

### Ponti modes & conversation state

- **oneshot** (`Super+A`) — every press is a fresh turn with no prior context. Use it for quick questions ("what's my battery", "what time is it in Lisbon"). After the reply, ollama is stopped so the dGPU can idle.
- **chat** (`Super+Shift+A`) — multi-turn. The full message history is persisted to `~/.local/state/ponti/conversation.json`. ollama is kept warm between turns so follow-ups are fast. The conversation auto-resets the next time you start chat after `$CHAT_IDLE_TIMEOUT` seconds of inactivity (default `600` = 10 min). To end deliberately, either say a farewell phrase or press `Super+Ctrl+A`.

The voice end-trigger is regex-matched (case-insensitive) against the transcript: phrases like *bye*, *goodbye*, *end conversation*, *stop ponti*, *exit*, *see you* (optionally followed by *ponti / chat / conversation / talking*). When detected, Ponti speaks a farewell, deletes the conversation file, and unloads both services.

#### Safe word

Ponti's persona is, deliberately, a lot. If you need her to drop the bit and just answer cleanly — formal tone, no sass, no flirting, no opinions — include the word **`penumbra`** anywhere in the prompt. That single response will be direct and professional; the next message without it snaps her back to full Ponti. The word is chosen so the medium whisper model reliably catches it and it doesn't accidentally trigger in normal conversation.

### System context (fastfetch)

Ponti's system prompt embeds a curated snapshot from `fastfetch --logo none --pipe true -s <modules>` so it knows about the machine. Current modules:

```
title:os:host:chassis:kernel:uptime:cpu:gpu:memory:swap:disk:battery:poweradapter:
display:de:wm:theme:icons:cursor:font:shell:terminal:locale:datetime:localip:wifi:sound
```

This includes both GPUs, battery + AC state, display panel, Wi-Fi SSID and signal, sound device, locale, current date/time, GTK/Qt themes, icons, cursor, and fonts. Tweak the `structure` variable in `ponti-ai-local.sh:system_context()` to add/remove modules — see `fastfetch --list-modules`. Avoid `weather` and `publicip` (they roundtrip the network on every press).

### Lazy loading & dGPU power

This config targets Intel iGPU for the compositor and offloads only AI workloads to NVIDIA via `prime-run`. To keep the dGPU in low-power idle whenever possible:

| Service | When it starts | When it stops |
|---------|---------------|---------------|
| `faster-whisper-server` (~1.3 GiB VRAM) | When STT or Ponti is triggered, in parallel with recording so it warms up while you talk. | Right after transcription completes (set `STT_KEEP_WHISPER=1` to skip). |
| `ollama serve` (~2.4 GiB VRAM for gemma3:4b) | When Ponti is triggered. | After replying in oneshot mode. In chat mode it stays loaded until you say a farewell or press `Super+Ctrl+A`. |

The shared lib `hypr/scripts/ai-services.sh` provides `start_/wait_/ensure_/stop_whisper` and the same set for `ollama`. Both use `prime-run` so the dGPU is the target.

**VRAM headroom note (NVIDIA T1200, 4 GiB):** whisper-medium + gemma3:4b together use ~3.7 GiB. That works, but there's only ~390 MiB free, so heavier models will OOM. The lazy-unload behavior keeps you from holding both in VRAM when not in use.

### Installation (Arch Linux)

1. **System packages**

   ```bash
   sudo pacman -S sox wl-clipboard ydotool mpv jq
   ```

2. **ydotool daemon** (required for typing at cursor)

   ydotool needs access to `/dev/uinput`. Add yourself to the `input` group and fix the ACL (brltty strips group access on Arch):

   ```bash
   sudo usermod -aG input $USER   # re-login after
   echo 'KERNEL=="uinput", RUN+="/usr/bin/setfacl -m g:input:rw /dev/%k"' | sudo tee /etc/udev/rules.d/99-uinput.rules
   sudo udevadm control --reload-rules && sudo udevadm trigger
   ```

   Then start the daemon (add to Hyprland autostart):
   ```bash
   ydotoold &
   # or in hyprland.conf:
   # exec-once = ydotoold
   ```

3. **Kokoro TTS**

   Kokoro requires Python <3.13. Arch ships Python 3.14+, so `pip install` won't work directly. Use **uv** instead — it's a fast Python package/tool manager (like pipx but also manages Python versions itself):

   ```bash
   sudo pacman -S uv              # install uv
   uv python install 3.12         # download an isolated Python 3.12
   uv tool install kokoro-tts --python 3.12   # installs kokoro-tts into its own venv
   ```

   `uv tool install` is equivalent to `pipx install` — it puts the `kokoro-tts` binary on your PATH without touching your system Python. The `--python 3.12` flag tells uv which Python version to use for the isolated environment.

   Then download the model files:

   ```bash
   mkdir -p ~/.local/share/kokoro-tts && cd ~/.local/share/kokoro-tts
   wget https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/kokoro-v1.0.onnx
   wget https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/voices-v1.0.bin
   ```

   The `tts.sh` script looks for models in `KOKORO_DIR` (default: `~/.local/share/kokoro-tts`), so no extra config needed.

4. **STT backend — faster-whisper** (x86 Linux with NVIDIA GPU)

   ```bash
   uv tool install faster-whisper-server
   ```

   **Fix missing pyproject.toml** (bug in the installed package — run once):
   ```bash
   echo -e '[project]\nversion = "0.0.0"' > ~/.local/share/uv/tools/faster-whisper-server/lib/python3.12/site-packages/pyproject.toml
   ```

   **CUDA 12 → 13 compatibility** (Arch ships CUDA 13, faster-whisper expects 12 — create symlinks once):
   ```bash
   sudo ln -s /opt/cuda/lib64/libcublas.so.13   /opt/cuda/lib64/libcublas.so.12
   sudo ln -s /opt/cuda/lib64/libcublasLt.so.13 /opt/cuda/lib64/libcublasLt.so.12
   sudo ln -s /opt/cuda/lib64/libcudart.so.13   /opt/cuda/lib64/libcudart.so.12
   sudo ldconfig
   ```

   The server is **lazy-loaded** by the scripts (see `ai-services.sh`); no autostart is needed. To run manually:
   ```bash
   LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH prime-run faster-whisper-server --port 9001 Systran/faster-whisper-medium
   ```

   First run downloads the model (~1.5 GB for `medium`). For CPU-only (no NVIDIA), replace `prime-run` with `CUDA_VISIBLE_DEVICES=""`.

   **Apple Silicon alternative:** install `parakeet-mlx` so it's on `PATH`; scripts auto-detect it and skip the HTTP API.

5. **LLM backend — ollama + gemma3:4b** (required for Ponti)

   ```bash
   sudo pacman -S ollama       # or: yay -S ollama-cuda
   ollama pull gemma3:4b
   ```

   ollama is **lazy-started** as `prime-run ollama serve` by `ponti-ai-local.sh`. To run manually:
   ```bash
   prime-run ollama serve
   ```

   If you also want the systemd service to coexist, leave `ollama.service` disabled so the scripts own the lifecycle.

### Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KOKORO_DIR` | `~/.local/share/kokoro-tts` | Directory with Kokoro model files |
| `KOKORO_VOICE` | `af_bella:40,af_nicole:60` | Kokoro voice name or blend (`name:weight,name:weight` — two voices max). See `kokoro-tts --help-voices`. |
| `KOKORO_SPEED` | `0.92` | Speech speed (1.0 = default). Slightly slow reads more sultry. |
| `KOKORO_LANG` | `en-us` | Kokoro language code. |
| `WHISPER_PORT` | `9001` | Port faster-whisper-server listens on |
| `WHISPER_MODEL` | `Systran/faster-whisper-medium` | Model name passed to faster-whisper-server |
| `WHISPER_URL` | `http://127.0.0.1:$WHISPER_PORT` | Base URL for the STT service |
| `STT_NOTIFY` | `0` | Set to `1` for desktop notifications during single-shot STT |
| `STT_KEEP_WHISPER` | `0` | Set to `1` to skip unloading whisper after transcription |
| `OLLAMA_URL` | `http://127.0.0.1:11434` | ollama base URL |
| `OLLAMA_MODEL` | `gemma3:4b` | Model Ponti queries |
| `PONTI_STATE_DIR` | `~/.local/state/ponti` | Directory for the chat-mode conversation file |
| `CHAT_IDLE_TIMEOUT` | `600` | Seconds before a chat-mode session is auto-reset on next invocation |

### Scripts (`hypr/scripts/`)

| File | Purpose |
|------|---------|
| `ai-services.sh` | Shared lib: `start_/wait_/ensure_/stop_whisper` and same for ollama. Sourced by the others. |
| `tts.sh` | Kokoro → mpv. |
| `stt.sh` | Single-shot dictation (fixed `RECORD_SECONDS`, default 10s). |
| `stt-push.sh` / `stt-stop.sh` / `stt-toggle.sh` | Push-to-talk dictation. `stt-push` warms whisper in parallel with recording. |
| `ponti-ai-local.sh [oneshot\|chat]` | Voice agent toggle. Builds a fastfetch-based system prompt and pipes the transcript to gemma3:4b → TTS. |
| `ponti-end.sh` | Manually end any Ponti session: clears conversation history, unloads whisper + ollama. |

### Testing

```bash
# TTS:
~/.config/hypr/scripts/tts.sh "hello world"

# Dictation toggle:
~/.config/hypr/scripts/stt-toggle.sh   # press once, talk, press again

# Ponti one-shot (records, transcribes, asks gemma3:4b, speaks reply):
~/.config/hypr/scripts/ponti-ai-local.sh oneshot   # press once, talk, press again

# Ponti chat (same, but keeps history at ~/.local/state/ponti/conversation.json):
~/.config/hypr/scripts/ponti-ai-local.sh chat
```

---

## buildPDF

The `hypr/scripts/buildPDF` script builds PDFs from Markdown (with Mermaid diagram support). In nvim, **`<leader>pd`** runs it on the current buffer and opens the PDF in Zathura. Setup is documented in a separate file: **[buildPDF.md](buildPDF.md)**.

---

## Claude Code Profiles

Context-based account switching so work (`~/indecimal`) and personal code never share a Claude session. Auth tokens, history, and project data are fully isolated per profile. Config in `zsh/claude-profiles.zsh`.

### One-time login (per install)

```bash
# Personal — run from anywhere outside ~/indecimal
claude-personal /login

# Work — run from inside ~/indecimal (or use the alias)
claude-work /login
```

### How it works

The `claude()` shell function checks `pwd` on every invocation and sets `CLAUDE_CONFIG_DIR` accordingly:

| cwd | Profile | Config dir |
|-----|---------|------------|
| `~/indecimal/**` | work | `~/.config/claude/work/` |
| anywhere else | personal | `~/.config/claude/personal/` |

The work profile prints a red **[WORK PROFILE]** warning to stderr before launching.

Use the aliases to force a profile regardless of directory:

```bash
claude-personal   # always personal
claude-work       # always work
```

### What git tracks

Only `settings.json` (theme, effort level, etc.) is committed per profile. Sessions, auth tokens, history, projects, cache, and plans are gitignored.

---

## tmux-file-picker

Fuzzy file and directory picker that pastes the selected path directly into the active tmux pane. Keybindings are in `tmux/tmux.conf`.

### Installation

```bash
curl -Lo ~/.local/bin/tmux-file-picker https://raw.githubusercontent.com/raine/tmux-file-picker/main/tmux-file-picker
chmod +x ~/.local/bin/tmux-file-picker
```

### Dependencies

- **fzf** — fuzzy finder (`sudo pacman -S fzf`)
- **fd** — fast file search, required by tmux-file-picker (`yay -S fd`)

### Keybindings (tmux)

| Binding | Action |
|---------|--------|
| `prefix + f` | Search all files in current directory |
| `prefix + Ctrl+g` | Git-tracked / modified files only |
| `prefix + Ctrl+r` | Directories only |
