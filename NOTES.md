# SweetPotato — agent / maintainer notes

Desktop theme + installer for Arch-based systems. The ISO that ships this theme is **SweetPotatOs** (sibling repo). Full ISO / SourceForge / archiso notes live there: `../SweetPotatOs/NOTES.md`.

## Role

- Source of truth for: **Swirl** compositor config under `~/.config/swirl/` (repo dir `swirl/`), gtk, **foot** (default terminal), mako, swaylock, fastfetch, wallpapers, GTK theme, `install.sh`.
- Do **not** also ship `~/.config/sway/` — Swirl checks that path **first** and would ignore `~/.config/swirl`. Keep `include /etc/sway/config.d/*` (package drop-ins). `swaylock` stays `~/.config/swaylock`.
- Default terminal: **foot** (`foot/foot.ini`, `[colors-dark]` + `alpha=1.0` for foot ≥1.26). `Mod+Return` / applauncher / networkmanager-dmenu point at foot.
- Ly: `default_input = password`.
- Status bar polls every 3s (`swirl/scripts/status.sh`).
- Session: bluetooth unblock + one-shot `tips.sh`.
- **Mod+m** / `expand.sh`: toggle focused column full width ↔ 50/50 pair layout (`set_size`, not fullscreen).
- Wallpaper: `ensure-wallpaper.sh` must not replace a saved `wallpaper.conf` path with the UsefulBinds fallback.
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
- Live ISO turns caffeine on by default (injected in SweetPotatOs sync); installed systems follow this repo’s Swirl config.

## FSB100

- `swirl/scripts/fsb100.sh`: when a fullscreen media window is focused (mpv/vlc/firefox/… or a media-ish title), set backlight to 100% and restore the previous level on exit.
- Must inspect the **innermost** focused IPC node (the window). Output/workspace also have `focused: true`; using the first match makes FSB100 a no-op.
- Also treat layout-fullscreen (window fills the output) because Swirl’s `fullscreen layout` does not set `fullscreen_mode`.
- On by default (`exec fsb100.sh on`). Toggle with **Mod+Shift+b**. Laptop backlight via `brightnessctl` only.

## Swirl

- Layout block + `scripts/autotile.lua` require Swirl (stock Sway will reject those commands).
- CSD wrappers: `bin/swirl` for `~/.local/bin`.
- Session desktop: `wayland-sessions/swirl.desktop` (+ Ly curated `/etc/ly/wayland-sessions`).
- Stock `sway.desktop` is removed on install; the Arch `sway` package stays only for swaybar/swaymsg/swaynag.
- `install.sh` installs the `sway` package for tools, then installs `swirl` from pacman if available, else builds from GitHub into `/usr/local`.
