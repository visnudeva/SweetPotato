# SweetPotato — agent / maintainer notes

Desktop theme + installer for Arch-based systems. The ISO that ships this theme is **SweetPotatOs** (sibling repo). Full ISO / SourceForge / archiso notes live there: `../SweetPotatOs/NOTES.md`.

## Role

- Source of truth for: **Swirl** compositor config (still under `~/.config/sway/`), gtk, foot, mako, swaylock, fastfetch, wallpapers, GTK theme, `install.sh`.
- Compositor binary is **swirl**; bar / IPC / nag stay stock **swaybar** / **swaymsg** / **swaynag** (from the Arch `sway` package).
- SweetPotatOs runs `sync-theme.sh` to mirror these files into the live ISO airootfs.

## Fastfetch

- Config: `fastfetch/config.jsonc` → `~/.config/fastfetch/SPLogo.asc` (`type: file`).
- PNG exists for other uses; do not make chafa/PNG the primary logo (falls back to Arch builtin in foot).
- Keep `SPLogo.asc` in sync with SweetPotatOs after regenerating.

## Lid close

- `systemd/logind.conf.d/lid-sleep.conf` installed by `install.sh` as `/etc/systemd/logind.conf.d/50-sweetpotato-lid-sleep.conf`.
- Remove any leftover `do-not-suspend.conf` that ignores lid switch (it overrides our drop-in by name sort order).

## Caffeine

- `sway/scripts/caffeine.sh`: idle inhibit only; lid suspend stays enabled.
- Live ISO turns caffeine on by default (injected in SweetPotatOs sync); installed systems follow this repo’s sway/Swirl config.

## FSB100

- `sway/scripts/fsb100.sh`: when a fullscreen media window is focused (mpv/vlc/firefox/… or a media-ish title), set backlight to 100% and restore the previous level on exit.
- On by default (`exec fsb100.sh on`). Toggle with **Mod+Shift+b**. Laptop backlight via `brightnessctl` only.

## Swirl

- Layout block + `scripts/autotile.lua` require Swirl (stock Sway will reject those commands).
- CSD wrappers: `bin/swirl` for `~/.local/bin`.
- Session desktop: `wayland-sessions/swirl.desktop` (+ Ly curated `/etc/ly/wayland-sessions`).
- Stock `sway.desktop` is removed on install; the Arch `sway` package stays only for swaybar/swaymsg/swaynag.
- `install.sh` installs the `sway` package for tools, then installs `swirl` from pacman if available, else builds from GitHub into `/usr/local`.
