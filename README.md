# hyprland config files

## Table of Contents

-   [Installation](#installation)
-   [One-time setup (per install)](#one-time-setup-per-install)
-   [Dependencies](#dependencies)
-   [Hybrid GPU (Intel + NVIDIA PRIME)](#hybrid-gpu-intel--nvidia-prime)
-   [Speech-to-Text and Text-to-Speech](#speech-to-text-and-text-to-speech)
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

## Speech-to-Text and Text-to-Speech

Lightweight, local STT (faster-whisper) and TTS (Kokoro) workflows for Hyprland. Scripts live in `hypr/scripts/`.

### Keybindings

| Key | Script | Description |
|-----|--------|-------------|
| `Super+T` | `tts.sh` | Speak clipboard aloud via Kokoro → mpv. Pressing again stops current playback and starts fresh. Notifies on play. |
| `Super+U` | `stt-toggle.sh` | **Toggle STT** — first press starts recording (1s prep delay so you can move hands away), second press stops and transcribes. Text is typed at cursor and copied to clipboard. |

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

4. **STT backend — faster-whisper** (recommended for x86 Linux)

   ```bash
   uv tool install faster-whisper-server
   ```

   Start the server (runs on port 9001, OpenAI-compatible API):
   ```bash
   CUDA_VISIBLE_DEVICES="" faster-whisper-server --port 9001 Systran/faster-whisper-small
   ```

   `CUDA_VISIBLE_DEVICES=""` forces CPU mode — required unless you have CUDA libraries installed (`sudo pacman -S cuda`). First run downloads the model (~500 MB for `small`).

   For autostart, add to `hyprland.conf`:
   ```ini
   exec-once = CUDA_VISIBLE_DEVICES="" faster-whisper-server --port 9001 Systran/faster-whisper-small
   ```

   **Apple Silicon alternative:** install `parakeet-mlx` so it's on `PATH`; scripts auto-detect it and skip the HTTP API.

### Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KOKORO_DIR` | `~/.local/share/kokoro-tts` | Directory with Kokoro model files |
| `PARAKEET_URL` | `http://127.0.0.1:9001/v1/audio/transcriptions` | STT service endpoint |
| `STT_MODEL` | `Systran/faster-whisper-base` | Model name sent to the STT service |
| `STT_NOTIFY` | `0` | Set to `1` for desktop notifications during STT |

### Testing

```bash
# TTS (should speak the words and show a notification):
~/.config/hypr/scripts/tts.sh "hello world"

# STT walkie-talkie (needs faster-whisper-server running):
~/.config/hypr/scripts/stt-push.sh   # start recording
~/.config/hypr/scripts/stt-stop.sh   # stop + transcribe + type
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
