# SweetPotato, give the sweetness back to the potatoes

<table>
  <tr>
    <td>
      <strong>A light Sway arch-based setup and a theme to revive slow and old potatoes PCs
<br>
    </td>
    <td>
  <img src="assets/SweetPotatOs.png" alt="SweetPotato" width="220">
</td>
  </tr>
</table>

Lightweight Sway theme for Arch-based systems.

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
| `Mod+n` | Wi‑Fi / NetworkManager |
| `Mod+Space` | App launcher |
| `Mod+w` | Web browser (firefox) |
| `Mod+f` | file manager (thunar) |
| `Mod+e` | IDE (geany) |
| `Mod+Return` | Terminal (foot) |
| `Mod+Shift+w` | Wallpaper selector |
| `Print` | Screenshot → `~/Pictures/Screenshots` (+ clipboard) |
| `Mod+Shift+Print` | Region screenshot |
| `Mod+Print` | Screen record toggle (region + audio → `~/Videos`) |
| `Mod+q` | Kill focused window |
| `Mod+number` | Change workspaces |
| `Mod+l` | Lock (swaylock) |
| `Mod+Shift+e` | Exit Sway |
| `Mod+o` | Power off |
| `Mod+Shift+c` | Reload config |

`Mod` is usually the Super/Windows key.

## What’s included

- Sway configs (FR + US)
- Charcoal GTK accents over Adwaita-dark
- swaylock, foot, mako, Geany color scheme
- Wi‑Fi menu via `networkmanager-dmenu` (`Mod+n`)
- Polkit udisks rules so Disks can write ISOs to USB on Sway
- Firefox Save As fix (`xdg-desktop-portal-gtk` PATH)
- Glycin SVG loader tweak for Papirus on low-RAM machines

## Switch keyboard layout later

```bash
cp ~/.config/sway/config-fr ~/.config/sway/config   # French
cp ~/.config/sway/config-us ~/.config/sway/config   # US
```

Then `Mod+Shift+c` to reload.
