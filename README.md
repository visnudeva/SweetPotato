# SweetPotato

Lightweight Sway theme for Arch-based systems (including Archcraft/swayfx).

![SweetPotato wallpaper](SweetPotato.png)

Colors: **#a73b50** potato red · **#f79b29** potato orange · **#1d1f21** charcoal

## Install

```bash
git clone https://github.com/visnudeva/SweetPotato.git
cd SweetPotato
chmod +x install.sh
./install.sh
```

Pick **FR** (AZERTY) or **US** (QWERTY) when asked. Re-login once so close buttons and PATH fixes apply fully.

## Useful binds

| Bind | Action |
|------|--------|
| `Mod+Return` | Terminal (foot) |
| `Mod+Space` | App launcher |
| `Mod+l` | Lock (swaylock) |
| `Mod+Shift+e` | Exit Sway |
| `Mod+Shift+c` | Reload config |

`Mod` is usually the Super/Windows key.

## What’s included

- Sway configs (FR + US)
- Charcoal GTK accents over Adwaita-dark
- swaylock, foot, mako, Geany color scheme
- Firefox Save As fix (`xdg-desktop-portal-gtk` PATH)
- Glycin SVG loader tweak for Papirus on low-RAM machines

## Switch keyboard layout later

```bash
cp ~/.config/sway/config-fr ~/.config/sway/config   # French
cp ~/.config/sway/config-us ~/.config/sway/config   # US
```

Then `Mod+Shift+c` to reload.
