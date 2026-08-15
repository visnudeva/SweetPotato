https://github.com/user-attachments/assets/7967621b-1456-4c81-bf9a-e54fdbd8f000

# SweetPotato, bring the sweetness back to the potatoes

<p align="center">
  <img src="assets/Screenshot.png" alt="SweetPotato desktop" width="920"
       style="border-radius: 12px; max-width: 100%; height: auto;">
</p>

<table>
  <tr>
    <td>
      <strong>A light Swirl arch-based setup and a theme to revive slow and old potatoes PCs
<br>
    </td>
    <td>
  <img src="assets/SweetPotatOs.png" alt="SweetPotato" width="220">
</td>
  </tr>
</table>

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
| `Mod+l` | Lock screen |
| `Mod+c` | Caffeine toggle (no sleep / idle lock) |
| `Mod+Shift+b` | FSB100 toggle (fullscreen media → max brightness) |
| `Mod+Shift+e` | Exit Swirl |
| `Mod+o` | Power off |
| `Mod+Shift+c` | Reload config |

`Mod` is usually the Super/Windows key.

## Default apps

| Role | App |
|------|-----|
| Browser | Firefox |
| Files | Thunar |
| Editor | Geany |
| Terminal | foot |
| Video | mpv + yt-dlp |
| Image edit | GIMP |
| Music | Audacious |
| PDF | mupdf |
| Images | swayimg |
| Flatpaks | Bazaar (+ flatpak) |
| Disks | GNOME Disks |

## What’s included

- Swirl compositor configs (FR + US) — scrolling columns + autotile  
  (lives in `~/.config/swirl/`; Swirl also still reads `/etc/sway/config.d` drop-ins)
- Status bar / IPC / nag via system tools (`swaybar`, `swaymsg`, `swaynag`)
- Charcoal GTK accents over Adwaita-dark
- Screen lock, foot terminal, mako, Geany color scheme
- Wi‑Fi menu via `networkmanager-dmenu` (`Mod+n`)
- FSB100: fullscreen players/browsers jump to max backlight, then restore (`Mod+Shift+b`)
- Polkit udisks rules so Disks can write ISOs to USB on Swirl
- Firefox Save As fix (`xdg-desktop-portal-gtk` PATH)
- Glycin SVG loader tweak for Papirus on low-RAM machines

### Gestures

| Gesture | Action |
|---------|--------|
| 3-finger left / right | Scroll the window strip |
| 4-finger up / down | Next / previous workspace |

## Switch keyboard layout later

```bash
cp ~/.config/swirl/config-fr ~/.config/swirl/config   # French
cp ~/.config/swirl/config-us ~/.config/swirl/config   # US
```

Then `Mod+Shift+c` to reload.
