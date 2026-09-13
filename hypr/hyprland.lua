-- Hyprland configuration (Lua format).
-- Migrated from hyprland.conf; the .conf format is removed in Hyprland 0.57.
-- Reference: https://wiki.hypr.land/Configuring/Start/
-- Stubs for editor completion: /usr/share/hypr/stubs/hl.meta.lua

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "3840x2400@60.0", position = "0x0", scale = 2.0 })
-- hl.monitor({ output = "eDP-1", mode = "3840x2400@59.99", position = "0x0", scale = 2, bitdepth = 10, cm = "hdr" })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.0", position = "960x-1080", scale = 1.0 })

-------------
---- HDR ----
-------------

-- hl.env("ENABLE_HDR_WSI", "1")
-- hl.env("KWIN_DRM_ALLOW_NVIDIA_COLORSPACE", "1")
-- hl.config({ render = { cm_fs_passthrough = 1 } })

------------------
---- WORKSPACES --
------------------

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", persistent = true })
end

for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
end

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi -i --show drun"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/defaultwallpaper.sh")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpm reload") -- load all hyprpm plugins
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("hyprnotify")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("ydotoold")
    -- faster-whisper-server is lazy-loaded by stt/ponti scripts (~/.config/hypr/scripts/ai-services.sh)
    -- hl.exec_cmd("asusctl aura static -c 22fd3d")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("HYPRCURSOR_THEME", "Bibata-Original-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Original-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_MENU_PREFIX", "arch-")

-- For styling
-- hl.env("QT_QPA_PLATFORM", "wayland")
-- hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Prefer Nvidia
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- hl.env("GBM_BACKEND", "nvidia-drm")

-- Hybrid GPU setup (Intel compositor + NVIDIA offload)
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("GBM_BACKEND", "intel-drm")
hl.env("WLR_DRM_DEVICES", "/dev/dri/card2")

-- Allow NVIDIA PRIME offload
-- disable __NV_PRIME_RENDER_OFFLOAD to use the intel compositor and prevent random apps from using the nvidia gpu
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 4, -- 20

        border_size = 2,

        col = {
            -- active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            active_border   = "rgba(000000ff)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        active_opacity   = 1.0,
        inactive_opacity = 0.82,

        shadow = {
            enabled = false,
            -- range        = 4,
            -- render_power = 3,
            -- color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 2,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear" })

hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
        -- pseudotile is no longer a dwindle option (Hyprland 0.55); pseudotiling is toggled
        -- via the `pseudo` dispatcher (mainMod + P below)
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },

    -- vfr moved from misc to debug in Hyprland 0.55 (default is already true)
    debug = {
        vfr = true, -- variable frame rendering; only rerender on change, saves cpu cycles on laptops
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0.5, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            -- drag_lock         = true,
            disable_while_typing = true,
        },
    },

    gestures = {
        workspace_swipe_cancel_ratio = 0.15,
    },
})

-- Built-in 1:1 workspace swiping (v0.51.0+)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- 3-up: hycov window overview (hyprexpo replacement; swipe up again or pick a window to close)
hl.gesture({ fingers = 3, direction = "up", action = function()
    hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch hycov:toggleoverview"))
end })
hl.gesture({ fingers = 3, direction = "down", action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
end })
hl.gesture({ fingers = 4, direction = "left", action = function()
    hl.dispatch(hl.dsp.exec_cmd("swaync-client -op"))
end })
hl.gesture({ fingers = 4, direction = "right", action = function()
    hl.dispatch(hl.dsp.exec_cmd("swaync-client -cp"))
end })

-- Example per-device config
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

-----------------
---- PLUGINS ----
-----------------

-- hyprexpo (workspace expo) was retired from official hyprland-plugins.
-- Replaced with hycov (window overview), a patched fork vendored as a submodule at
-- hypr/plugins/hycov, ported to Hyprland 0.55.2.
-- Loaded here rather than via exec-once so its config keys exist when hl.config runs
-- (`hyprctl keyword` does not work under the Lua config manager).
hl.plugin.load("/home/dj/.config/hypr/plugins/hycov/build/libhycov.so")

-- Applied on start rather than at parse time: the plugin's config keys only exist once it
-- has registered them, and `hl.plugin.load` is a no-op under `Hyprland --verify-config`.
hl.on("hyprland.start", function()
    pcall(hl.config, {
        plugin = {
            hycov = {
                overview_gappo      = 60, -- gap from screen edge
                overview_gappi      = 24, -- gap between windows
                enable_click_action = 1,  -- left-click to focus, right-click to close in overview
                click_in_cursor     = 1,  -- pick target window by cursor position
                enable_gesture      = 0,  -- gesture handled natively via the 3-up gesture above
                auto_exit           = 1,  -- leave overview automatically when no windows remain
            },
        },
    })
end)

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN",  hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",       hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exit())
hl.bind(mainMod .. " + F",       hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",       hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",       hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + I",       hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.layout("swapsplit"))

-- extra additions:
hl.bind(mainMod .. " + W",   hl.dsp.exec_cmd("google-chrome-stable"))
-- window overview (hyprexpo replacement)
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprctl dispatch hycov:toggleoverview"))
hl.bind("ALT + TAB",         hl.dsp.exec_cmd("~/.config/hypr/scripts/window-switcher.sh"))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"),           { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"),           { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"),              { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),              { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---- Custom keybindings ----

hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("~/.config/waybar/restart.sh"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaperpicker.sh"))
hl.bind(mainMod .. " + Period",    hl.dsp.exec_cmd("~/.config/hypr/scripts/wofi-emoji"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty --title notetaker_window -e ~/.config/hypr/scripts/notetaker.sh"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd("ls -r ~/Documents/notes/pdf/*.pdf | head -n1 | xargs zathura"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- fullscreen
hl.bind(mainMod .. " + M",         hl.dsp.window.fullscreen({ mode = "maximized" }))  -- maximise
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/togglelivewall.sh"))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd("swaync-client -t"))

-- TTS / STT
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/tts.sh"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("~/.config/hypr/scripts/stt-toggle.sh"))

-- Ponti - local voice AI (STT -> ollama gemma3:4b -> TTS)
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd("~/.config/hypr/scripts/ponti-ai-local.sh oneshot"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("~/.config/hypr/scripts/ponti-ai-local.sh chat"))
hl.bind(mainMod .. " + CTRL + A",  hl.dsp.exec_cmd("~/.config/hypr/scripts/ponti-end.sh"))

-- hyprlock
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("wlogout"))

-- hyprshot
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("hyprshot -z -m region --clipboard-only"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("hyprshot -z -m region -o ~/Pictures/screenshots"))

-- asusctl for laptop
-- hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("asusctl -n"), { locked = true, repeating = true })
-- hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("asusctl -p"), { locked = true, repeating = true })
-- hl.bind("XF86Launch1",           hl.dsp.exec_cmd("rog-control-center"), { locked = true, repeating = true })
-- hl.bind("XF86Launch4",           hl.dsp.exec_cmd("~/.config/hypr/scripts/profile_control.sh"), { locked = true, repeating = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Suppress maximize requests
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland dragging
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Floating window size (4k): 720x480

-- Notetaker (kitty --title notetaker_window)
hl.window_rule({
    name  = "float-notetaker",
    match = { initial_title = "notetaker_window" },
    float = true,
    size  = "960 540",
})

-- Note preview only (zathura when opened from ~/Documents/notes/pdf/ - Super+Shift+E)
hl.window_rule({
    name  = "float-note-preview",
    match = { class = [[(zathura|Zathura|org\.pwmt\.zathura)]], title = [[(.*notes/pdf.*)]] },
    float = true,
    size  = "960 540",
})

-- Dolphin
hl.window_rule({
    name  = "float-dolphin",
    match = { class = [[(dolphin|org\.kde\.dolphin)]] },
    float = true,
    size  = "960 720",
})

-- File pickers (Nautilus, GTK Open/Save)
hl.window_rule({
    name  = "float-file-pickers",
    match = { class = [[(nautilus|org\.gnome\.Nautilus|xdg-desktop-portal-gtk)]] },
    float = true,
    size  = "960 540",
})
hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = [[(Open File|Save File|Choose File|Select File|File Upload|All Files)]] },
    float = true,
    size  = "960 540",
})

-- sxiv
hl.window_rule({
    name  = "float-sxiv",
    match = { class = "[sS]xiv" },
    float = true,
    size  = "960 720",
})

-- Network Manager
hl.window_rule({
    name  = "float-nm-connection-editor",
    match = { class = "[nN]m-connection-editor" },
    float = true,
    size  = "960 540",
})
hl.window_rule({
    name  = "float-network-connections",
    match = { title = [[(Network Connections|nmtui)]] },
    float = true,
    size  = "960 540",
})

-- Pavucontrol
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = [[([pP]avucontrol|org\.pulseaudio\.pavucontrol)]] },
    float = true,
    size  = "960 540",
})

-- Bluetooth (Blueman)
hl.window_rule({
    name  = "float-blueman",
    match = { class = "[bB]lueman-manager" },
    float = true,
    size  = "960 540",
})
hl.window_rule({
    name  = "float-bluetooth-dialog",
    match = { title = "(Bluetooth)" },
    float = true,
    size  = "960 540",
})

-- qpwgraph (PipeWire graph)
hl.window_rule({
    name  = "float-qpwgraph",
    match = { class = [[(qpwgraph|org\.rncbc\.qpwgraph)]] },
    float = true,
    size  = "960 720",
})

-- gnome calculator
hl.window_rule({
    name  = "float-calculator",
    match = { class = [[(Calculator|org\.gnome\.Calculator)]] },
    float = true,
    size  = "480 720",
})

-- mpv
hl.window_rule({
    name  = "float-mpv",
    match = { class = "(mpv)" },
    float = true,
    size  = "960 540",
})
