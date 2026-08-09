# SweetPotato — agent / maintainer notes

Desktop theme + installer for Arch-based systems. The ISO that ships this theme is **SweetPotatOs** (sibling repo). Full ISO / SourceForge / archiso notes live there: `../SweetPotatOs/NOTES.md`.

## Role

- Source of truth for: sway, gtk, foot, mako, swaylock, fastfetch, wallpapers, GTK theme, `install.sh`.
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
- Live ISO turns caffeine on by default (injected in SweetPotatOs sync); installed systems follow this repo’s sway config.
