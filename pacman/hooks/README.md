# Pacman (dotfiles)

This directory is **tracked in dotfiles** so hooks and preferred options are the same on every install.

- **hooks/** – pacman hooks (must be symlinked into `/etc/pacman.d/hooks/` on each machine).
- **pacman.conf.snippet** – options to reapply in `/etc/pacman.conf` on new installs (Color, ILoveCandy).
- **pacman.multilib.snippet** – `[multilib]` section to enable if you need 32-bit packages (e.g. Steam, Wine, lib32-nvidia-utils). See the snippet; uncomment/add the block in `/etc/pacman.conf` as needed.

## One-time setup (per install)

**1. Hooks** – so pacman runs the hook from this repo:

```bash
sudo mkdir -p /etc/pacman.d/hooks
sudo ln -sf ~/.config/pacman/hooks/arch-applications-menu.hook /etc/pacman.d/hooks/
```

**2. Pacman options (Color, ILoveCandy)** – ensure these lines exist in the `[options]` section of `/etc/pacman.conf` (see `../pacman.conf.snippet`). On a fresh install, add them if missing.

**3. Multilib (optional)** – if you need 32-bit packages (e.g. for Steam, Wine, or hybrid NVIDIA setups with `lib32-nvidia-utils`), enable the `[multilib]` section in `/etc/pacman.conf` as shown in `../pacman.multilib.snippet`. Then run `sudo pacman -Sy`.

## Hooks

| Hook | Purpose |
|------|--------|
| **arch-applications-menu.hook** | On install/upgrade of `archlinux-xdg-menu`, creates `/etc/xdg/menus/applications.menu` → `arch-applications.menu` so Dolphin (and other KDE apps) resolve MIME defaults on Hyprland. |

## Files that stay the same across installs (tracked here)

- `arch-applications-menu.hook` – hook definition (tracked in this repo)
- `~/.config/mimeapps.list` – default apps (e.g. mpv for video, sxiv for images); tracked in dotfiles
- Hyprland `exec-once` runs `kbuildsycoca6 --noincremental` at session start so Dolphin’s cache stays in sync

## Dependencies

- **arch-applications-menu.hook**: install `archlinux-xdg-menu` so the menu file exists:
  ```bash
  sudo pacman -S archlinux-xdg-menu
  ```
