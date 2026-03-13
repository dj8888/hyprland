# hyprland config files

## Table of Contents

-   [Installation](#installation)
-   [One-time setup (per install)](#one-time-setup-per-install)
-   [Dependencies](#dependencies)
-   [buildPDF](#buildpdf)

## Installation

> Install the required dependencies based on your system manually and clone the repo in ~/.config/

### One-time setup (per install)

After cloning on a new system, symlink the pacman hook so Dolphin (and other KDE apps) get the correct applications menu and MIME defaults on Hyprland:

```bash
sudo mkdir -p /etc/pacman.d/hooks
sudo ln -sf ~/.config/pacman/hooks/arch-applications-menu.hook /etc/pacman.d/hooks/
```

Install `archlinux-xdg-menu` if you use Dolphin. Optional: add the options in `pacman/pacman.conf.snippet` to `/etc/pacman.conf`. See **[pacman/hooks/README.md](pacman/hooks/README.md)** for details.

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
- **wl-clipboard** (required by cliphist)
- **cliphist** (clipboard history; `mainMod+V`)
- **wtype** (used by wofi-emoji script; `mainMod+.`)
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
- **bibata-cursor-theme** (Bibata Original Classic)
- **noto-fonts**, **noto-fonts-cjk**, **noto-fonts-extra**
- **ttf-fira-code**, **otf-font-awesome**
- **lsd** (fancy `ls`)

### Optional / extra
*Not required by this config’s keybinds or scripts; handy for a full desktop or other workflows.*

- **Android:** android-tools (adb, file transfer, debugging)
- **Bluetooth:** blueman, bluez, bluez-utils
- **Monitors / tuning:** btop, htop, nvtop, powertop
- **Network:** networkmanager, network-manager-applet, iwd (nm-applet is commented in config but useful for tray)
- **Audio:** pipewire, pipewire-alsa, pipewire-pulse, pavucontrol (needed for sound at all)
- **Laptop:** thermald (thermal throttling)
- **Browsers / apps:** google-chrome, discord, spotify, mpv
- **Image viewer (XDG default):** sxiv — set as default for images in `mimeapps.list`; with the pacman hook and `kbuildsycoca6` at session start, Dolphin respects these defaults on Hyprland
- **Misc:** git, wget, tldr, man-pages, gdu
- **ASUS laptops:** asusctl, rog-control-center (keybinds for these are commented out in config)

---

## buildPDF

The `hypr/scripts/buildPDF` script builds PDFs from Markdown (with Mermaid diagram support). In nvim, **`<leader>pd`** runs it on the current buffer and opens the PDF in Zathura. Setup is documented in a separate file: **[buildPDF.md](buildPDF.md)**.
