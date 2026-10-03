# SweetPotato — agent / maintainer notes

Desktop theme + installer for Arch-based systems. The ISO that ships this theme is **SweetPotatOs** (sibling repo). Full ISO / SourceForge / archiso notes live there: `../SweetPotatOs/NOTES.md`.

## Role

- Source of truth for: **Swirl** compositor config under `~/.config/swirl/` (repo dir `swirl/`), gtk, **foot** (default terminal), mako, swaylock, fastfetch, wallpapers, GTK theme, `install.sh`.
- Do **not** also ship `~/.config/sway/` — Swirl checks that path **first** and would ignore `~/.config/swirl`. Keep `include /etc/sway/config.d/*` (package drop-ins). `swaylock` stays `~/.config/swaylock`.
- User overrides: `~/.config/swirl/config.d/user` — seeded once (install / materialize seed-only); loaded last from main config. Never clobber on update. Whole-file forks also live under `~/.config/sweetpotatos/user_edits/`.
- Default terminal: **foot** (`foot/foot.ini`, `[colors-dark]` + `alpha=1.0` for foot ≥1.26). `Mod+Return` / applauncher / networkmanager-dmenu point at foot.
- Interactive shell: `install.sh` installs **fish**. `foot/foot.ini` sets `shell=/usr/bin/fish`, so opening the terminal starts fish. Login stays bash. Scripts stay bash.
- Image viewer: `swayimg/init.lua` sets `overlay = false` and `decoration = true`. swayimg 5.x reads `init.lua` only. On Sway it otherwise floats over the focused window (`overlay`) and turns the server border off, so the corners stay square.
- Close window: `Mod+q` and `Escape`. Escape runs `escape.sh`: if `wmenu` is open (app launcher, Wi-Fi, wallpaper), it closes that menu and leaves the window alone. Otherwise it closes the focused window. Resize mode still binds Escape to leave the mode.
- Move window: `Mod+Shift+1`…`0` and the French number-row symbols (`Mod+Shift+ampersand` … `agrave`). A French layout types `1` as Shift+`&`, so the US keysym alone never fires. The bind also follows the window onto that workspace.
- Ly: `default_input = password`.
- Status bar polls every 3s (`swirl/scripts/status.sh`).
- Session: bluetooth unblock + `tips.sh` every login (points at Mod+? cheatsheet).
- **Mod+m** / `expand.sh`: toggle focused column full width ↔ 50/50 pair layout (`set_size`, not fullscreen).
- Cheatsheet: `cheatsheet.sh` + `cheatsheet.txt`; floating foot via `app_id=sweetpotato-cheatsheet` (`Mod+?`).
- Wallpaper: `ensure-wallpaper.sh` must not replace a saved `wallpaper.conf` path with the SpoNeon fallback. Default is `SpoNeon.png`; do not ship UsefulBinds/BindsBG.
- Compositor binary is **swirl**; bar / IPC / nag stay stock **swaybar** / **swaymsg** / **swaynag** (from the Arch `sway` package).
- SweetPotatOs runs `sync-theme.sh` to mirror these files into the live ISO airootfs.

## Fastfetch

- Config: `fastfetch/config.jsonc` → `SPLogo.png` with `logo.type: chafa` (colored ASCII potato from the PNG; works in foot). Keep `SPLogo.asc` only as a last-resort file.
- Keep `SPLogo.png` (colored potato) as the source of truth. ASCII `SPLogo.asc` is a last-resort fallback file, not the primary logo.

## Lid close

- `systemd/logind.conf.d/lid-sleep.conf` installed by `install.sh` as `/etc/systemd/logind.conf.d/50-sweetpotato-lid-sleep.conf`.
- Remove any leftover `do-not-suspend.conf` that ignores lid switch (it overrides our drop-in by name sort order).

## Caffeine

- `swirl/scripts/caffeine.sh`: idle inhibit only; lid suspend stays enabled.
- Power off goes through `swirl/scripts/poweroff.sh`, which drops that idle lock before `systemctl poweroff`. Leaving the lock held can stop the machine with the power light on and no wake. The lock also drops on lid sleep, then comes back after wake. Do not inhibit `sleep`, `shutdown`, or `handle-lid-switch`.
- Live ISO turns caffeine on by default (injected in SweetPotatOs sync); installed systems follow this repo’s Swirl config.

## Brightness

- Laptop backlight via plain `brightnessctl` (`swirl/scripts/brightness.sh`). Keys: `XF86MonBrightnessUp/Down`. Keep this simple — do not add `-n` (`--min-value`) or FSB100-style clampers.
- **FSB100 removed** — it falsely treated maximized windows as fullscreen and re-clamped to 100%, breaking brightness keys.

## Swirl

- Layout block + `scripts/autotile.lua` require Swirl (stock Sway will reject those commands).
- CSD wrappers: `bin/swirl` for `~/.local/bin`.
- Session desktop: `wayland-sessions/swirl.desktop` (+ Ly curated `/etc/ly/wayland-sessions`).
- Stock `sway.desktop` is removed on install; the Arch `sway` package stays only for swaybar/swaymsg/swaynag.
- `install.sh` installs the `sway` package for tools, then installs `swirl` from pacman if available, else builds from GitHub into `/usr/local`.
