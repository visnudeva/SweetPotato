#!/usr/bin/env bash
# SweetPotato — Sway theme installer for Arch-based distros
# Colors: #a73b50 (potato red) · #f79b29 (potato orange)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_SRC="${SCRIPT_DIR}/SweetPotato.png"
WALLPAPER_DST="${HOME}/.local/share/backgrounds/SweetPotato.png"

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

info()  { echo -e "${ORANGE}[*]${NC} $*"; }
ok()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${RED}[!]${NC} $*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# ----------------------------------------
# Official-repo packages (no swayfx)
# ----------------------------------------
PACMAN_PKGS=(
  # compositor stack
  sway
  swaybg
  swayidle
  swaylock
  # apps / tools used by config
  foot
  wmenu
  j4-dmenu-desktop
  grim
  slurp
  wl-clipboard
  thunar
  thunar-volman
  thunar-archive-plugin
  gvfs
  gvfs-mtp
  gvfs-smb
  nwg-look
  firefox
  geany
  gnome-disk-utility
  # media / creative
  swayimg
  mpv
  mpv-mpris
  mupdf
  audacious
  audacious-plugins
  cava
  gimp
  # audio / portals
  pipewire
  pipewire-pulse
  wireplumber
  pavucontrol
  xdg-desktop-portal
  xdg-desktop-portal-wlr
  xdg-desktop-portal-gtk
  bubblewrap
  # hardware helpers
  brightnessctl
  playerctl
  # networking / bluetooth (potato daily drivers)
  networkmanager
  network-manager-applet
  blueman
  bluez
  bluez-utils
  # desktop essentials often forgotten on sway
  mako
  udiskie
  mousepad
  file-roller
  xdg-user-dirs
  qt6-wayland
  btop
  cliphist
  wlsunset
  gammastep
  flatpak
  bazaar
  # theming / fonts / icons / gtk
  gtk3
  gtk4
  papirus-icon-theme
  capitaine-cursors
  xsettingsd
  xfconf
  dconf
  noto-fonts
  noto-fonts-emoji
  # session helpers
  xorg-xwayland
  polkit-gnome
  wireless_tools
  libnotify
  # TUI login (replaces SDDM when enabled)
  ly
)

echo
echo -e "${RED}  SweetPotato${NC} ${ORANGE}installer${NC}"
echo "  Lightweight Sway theme for Arch-based systems"
echo

# ----------------------------------------
# Keyboard layout choice
# ----------------------------------------
KB_LAYOUT=""
while [[ -z "${KB_LAYOUT}" ]]; do
  echo "Keyboard layout:"
  echo "  1) fr  (AZERTY — workspace binds: & é \" ' ( - è _ ç à)"
  echo "  2) us  (QWERTY — workspace binds: 1 2 3 4 5 6 7 8 9 0)"
  read -r -p "Choose [1/2]: " choice
  case "${choice}" in
    1|fr|FR) KB_LAYOUT="fr" ;;
    2|us|US) KB_LAYOUT="us" ;;
    *) warn "Invalid choice." ;;
  esac
done
ok "Keyboard: ${KB_LAYOUT}"

# ----------------------------------------
# Privilege helper
# ----------------------------------------
SUDO=""
if [[ "${EUID}" -ne 0 ]]; then
  if need_cmd sudo; then
    SUDO="sudo"
  else
    warn "Need root or sudo to install packages."
    exit 1
  fi
fi

# ----------------------------------------
# Install pacman packages
# ----------------------------------------
info "Installing packages with pacman..."

# Do not pull sway if swayfx (or another provider) already satisfies it
INSTALL_PKGS=()
for pkg in "${PACMAN_PKGS[@]}"; do
  if [[ "${pkg}" == "sway" ]] && pacman -Q sway >/dev/null 2>&1; then
    info "sway already present ($(pacman -Q sway)) — skipping package install"
    continue
  fi
  if pacman -Q "${pkg}" >/dev/null 2>&1; then
    continue
  fi
  INSTALL_PKGS+=("${pkg}")
done

if ((${#INSTALL_PKGS[@]})); then
  ${SUDO} pacman -S --needed --noconfirm "${INSTALL_PKGS[@]}"
  ok "Pacman packages installed"
else
  ok "All pacman packages already installed"
fi

# ----------------------------------------
# Deploy configs
# ----------------------------------------
info "Deploying SweetPotato configs..."

mkdir -p \
  "${HOME}/.config/sway/scripts" \
  "${HOME}/.config/swaylock" \
  "${HOME}/.config/foot" \
  "${HOME}/.config/gtk-3.0" \
  "${HOME}/.config/gtk-4.0" \
  "${HOME}/.config/xsettingsd" \
  "${HOME}/.config/mako" \
  "${HOME}/.themes" \
  "${HOME}/.local/share/backgrounds" \
  "${HOME}/Pictures/Screenshots"

# Wallpaper
if [[ -f "${WALLPAPER_SRC}" ]]; then
  cp -f "${WALLPAPER_SRC}" "${WALLPAPER_DST}"
  # Also drop a copy where stock sway backgrounds live (best-effort)
  if [[ -d /usr/share/backgrounds/sway ]]; then
    ${SUDO} cp -f "${WALLPAPER_SRC}" /usr/share/backgrounds/sway/SweetPotato.png || true
  fi
  ok "Wallpaper installed"
else
  warn "Wallpaper missing: ${WALLPAPER_SRC}"
fi

# Sway config (FR = config, US = config-us)
if [[ "${KB_LAYOUT}" == "us" ]]; then
  cp -f "${SCRIPT_DIR}/sway/config-us" "${HOME}/.config/sway/config"
else
  cp -f "${SCRIPT_DIR}/sway/config" "${HOME}/.config/sway/config"
fi
# Keep both layouts available for later switching
cp -f "${SCRIPT_DIR}/sway/config" "${HOME}/.config/sway/config-fr"
cp -f "${SCRIPT_DIR}/sway/config-us" "${HOME}/.config/sway/config-us"
cp -f "${SCRIPT_DIR}/sway/scripts/status.sh" "${HOME}/.config/sway/scripts/status.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/apply-theme.sh" "${HOME}/.config/sway/scripts/apply-theme.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/volume.sh" "${HOME}/.config/sway/scripts/volume.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/brightness.sh" "${HOME}/.config/sway/scripts/brightness.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/media.sh" "${HOME}/.config/sway/scripts/media.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/applauncher.sh" "${HOME}/.config/sway/scripts/applauncher.sh"
chmod +x \
  "${HOME}/.config/sway/scripts/status.sh" \
  "${HOME}/.config/sway/scripts/apply-theme.sh" \
  "${HOME}/.config/sway/scripts/volume.sh" \
  "${HOME}/.config/sway/scripts/brightness.sh" \
  "${HOME}/.config/sway/scripts/media.sh" \
  "${HOME}/.config/sway/scripts/applauncher.sh"
ok "Sway config (${KB_LAYOUT}) installed"

# Swaylock — plain dark grey, large indicator (no background image)
cp -f "${SCRIPT_DIR}/swaylock/config" "${HOME}/.config/swaylock/config"
ok "Swaylock themed"

# Portals — FileChooser via gtk (Firefox Save As); capture via wlr
mkdir -p "${HOME}/.config/xdg-desktop-portal"
cp -f "${SCRIPT_DIR}/xdg-desktop-portal/sway-portals.conf" \
  "${HOME}/.config/xdg-desktop-portal/sway-portals.conf"
cp -f "${SCRIPT_DIR}/xdg-desktop-portal/sway-portals.conf" \
  "${HOME}/.config/xdg-desktop-portal/wlroots-portals.conf"
cp -f "${SCRIPT_DIR}/xdg-desktop-portal/sway-portals.conf" \
  "${HOME}/.config/xdg-desktop-portal/swayfx-portals.conf"
cp -f "${SCRIPT_DIR}/xdg-desktop-portal/sway-portals.conf" \
  "${HOME}/.config/xdg-desktop-portal/portals.conf"
ok "xdg-desktop-portal FileChooser routed to gtk"

# Portal-gtk needs a real PATH (broken session PATH → bwrap/glycin crash → Firefox Save As dead)
mkdir -p "${HOME}/.config/systemd/user/xdg-desktop-portal-gtk.service.d"
cp -f "${SCRIPT_DIR}/systemd/user/xdg-desktop-portal-gtk.service.d/override.conf" \
  "${HOME}/.config/systemd/user/xdg-desktop-portal-gtk.service.d/override.conf"
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user reset-failed xdg-desktop-portal-gtk 2>/dev/null || true
systemctl --user restart xdg-desktop-portal-gtk xdg-desktop-portal 2>/dev/null || true
ok "xdg-desktop-portal-gtk PATH fixed for file chooser"

# Firefox — prefer portal file picker
FF_PROF="$(find "${HOME}/.config/mozilla/firefox" "${HOME}/.mozilla/firefox" -maxdepth 1 -type d -name '*.default*' 2>/dev/null | head -1 || true)"
if [[ -n "${FF_PROF}" ]]; then
  cat > "${FF_PROF}/user.js" << 'EOF'
// SweetPotato — use XDG portal file picker (xdg-desktop-portal-gtk)
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal", 1);
EOF
  ok "Firefox portal file-picker prefs set"
fi


# Restore GTK CSD (close buttons) if a distro forced gtk-nocsd in /etc/environment
mkdir -p "${HOME}/.config/environment.d" "${HOME}/.local/bin"
sed "s|%HOME%|${HOME}|g" \
  "${SCRIPT_DIR}/environment.d/90-sweetpotato-csd.conf" \
  > "${HOME}/.config/environment.d/90-sweetpotato-csd.conf"
cp -f "${SCRIPT_DIR}/bin/sway" "${HOME}/.local/bin/sway"
chmod +x "${HOME}/.local/bin/sway"
if [[ -f /etc/environment ]] && grep -q '^LD_PRELOAD=/usr/lib/libgtk-nocsd.so' /etc/environment; then
  ${SUDO} sed -i \
    's|^LD_PRELOAD=/usr/lib/libgtk-nocsd.so|# LD_PRELOAD=/usr/lib/libgtk-nocsd.so  # disabled by SweetPotato (close buttons)|' \
    /etc/environment || true
  ok "Disabled system gtk-nocsd in /etc/environment (re-login for close buttons)"
else
  ok "gtk-nocsd already disabled or absent"
fi
ok "CSD sway wrapper installed (~/.local/bin/sway)"


# Foot
cp -f "${SCRIPT_DIR}/foot/foot.ini" "${HOME}/.config/foot/foot.ini"
ok "Foot themed"

# Geany — potato editor scheme (replaces Arc blue accents)
mkdir -p "${HOME}/.config/geany/colorschemes"
cp -f "${SCRIPT_DIR}/geany/colorschemes/sweetpotato.conf" \
  "${HOME}/.config/geany/colorschemes/sweetpotato.conf"
if [[ -f "${HOME}/.config/geany/geany.conf" ]]; then
  if grep -q '^color_scheme=' "${HOME}/.config/geany/geany.conf"; then
    sed -i 's/^color_scheme=.*/color_scheme=sweetpotato.conf/' \
      "${HOME}/.config/geany/geany.conf"
  else
    printf '\ncolor_scheme=sweetpotato.conf\n' >> "${HOME}/.config/geany/geany.conf"
  fi
else
  mkdir -p "${HOME}/.config/geany"
  printf '[geany]\ncolor_scheme=sweetpotato.conf\n' > "${HOME}/.config/geany/geany.conf"
fi
ok "Geany SweetPotato color scheme installed"

# Mako notifications
cp -f "${SCRIPT_DIR}/mako/config" "${HOME}/.config/mako/config"
ok "Mako themed"

# GTK theme + settings
cp -a "${SCRIPT_DIR}/themes/SweetPotato" "${HOME}/.themes/"
cp -f "${SCRIPT_DIR}/gtk-3.0/settings.ini" "${HOME}/.config/gtk-3.0/settings.ini"
cp -f "${SCRIPT_DIR}/gtk-3.0/gtk.css" "${HOME}/.config/gtk-3.0/gtk.css"
cp -f "${SCRIPT_DIR}/gtk-4.0/settings.ini" "${HOME}/.config/gtk-4.0/settings.ini"
cp -f "${SCRIPT_DIR}/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css"
cp -f "${SCRIPT_DIR}/xsettingsd/xsettingsd.conf" "${HOME}/.config/xsettingsd/xsettingsd.conf"
ok "GTK accents installed (base theme: Adwaita-dark + charcoal CSS)"

# Glycin SVG sandbox breaks Papirus icons on low-RAM / restricted bwrap setups
# (GTK then aborts and window chrome looks broken). Disable sandbox for SVG loaders.
mkdir -p "${HOME}/.local/share/glycin-loaders/2+/conf.d"
cp -f "${SCRIPT_DIR}/glycin-loaders/glycin-svg.conf" \
  "${HOME}/.local/share/glycin-loaders/2+/conf.d/glycin-svg.conf"
if [[ -d /usr/share/glycin-loaders/2+/conf.d ]]; then
  ${SUDO} cp -f "${SCRIPT_DIR}/glycin-loaders/glycin-svg.conf" \
    /usr/share/glycin-loaders/2+/conf.d/glycin-svg.conf || true
fi
ok "Glycin SVG loader configured for potato-friendly icon loading"

# Capitaine cursor name fallback (light / dark variants)
CURSOR_NAME="capitaine-cursors"
for candidate in capitaine-cursors capitaine-cursors-light; do
  if [[ -d "/usr/share/icons/${candidate}" ]] || [[ -d "${HOME}/.icons/${candidate}" ]]; then
    CURSOR_NAME="${candidate}"
    break
  fi
done
sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=${CURSOR_NAME}/" \
  "${HOME}/.config/gtk-3.0/settings.ini" \
  "${HOME}/.config/gtk-4.0/settings.ini"
sed -i "s/^Gtk\/CursorThemeName .*/Gtk\/CursorThemeName \"${CURSOR_NAME}\"/" \
  "${HOME}/.config/xsettingsd/xsettingsd.conf"
ok "Cursor theme: ${CURSOR_NAME}"
ok "Icons: Papirus-Dark (papirus-icon-theme)"

# Push theme into gsettings / xfconf / xsettingsd (Thunar reads these, not only settings.ini)
CURSOR="${CURSOR_NAME}" "${HOME}/.config/sway/scripts/apply-theme.sh"
ok "Theme applied to gsettings, xfconf, and xsettingsd"

# Ly — TUI login screen (SweetPotato charcoal / potato red)
if pacman -Q ly >/dev/null 2>&1; then
  if [[ -f /etc/ly/config.ini ]] && [[ -f "${SCRIPT_DIR}/ly/config.ini" ]]; then
    ${SUDO} cp -f /etc/ly/config.ini /etc/ly/config.ini.bak.sweetpotato 2>/dev/null || true
    ${SUDO} cp -f "${SCRIPT_DIR}/ly/config.ini" /etc/ly/config.ini
    ok "Ly themed (charcoal + potato red)"
  fi
  # Enable Ly on tty2; disable SDDM if present (takes effect on next boot)
  if systemctl list-unit-files sddm.service >/dev/null 2>&1; then
    ${SUDO} systemctl disable sddm.service 2>/dev/null || true
  fi
  ${SUDO} systemctl enable ly@tty2.service 2>/dev/null || true
  ok "Ly enabled on tty2 (reboot to use the login screen)"
else
  warn "ly not installed — skip login screen setup"
fi

# Enable lingering pipewire user services if available
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

echo
ok "SweetPotato install complete."
echo
echo "  Reload sway:   Mod+Shift+c"
echo "  Lock screen:   Mod+l"
echo "  App menu:      Mod+Space"
echo "  Login screen:  Ly (reboot after install) — select Sway session"
echo "  Switch layout later:"
echo "    cp ~/.config/sway/config-fr ~/.config/sway/config   # French"
echo "    cp ~/.config/sway/config-us ~/.config/sway/config   # US"
echo "  Then Mod+Shift+c to reload."
echo
echo "  Re-login once so close buttons (CSD) and PATH fixes apply fully."
echo
