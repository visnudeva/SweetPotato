#!/usr/bin/env bash
# SweetPotato — Swirl theme installer for Arch-based distros
# Compositor: swirl (https://github.com/visnudeva/swirl). Tools: stock swaybar/swaymsg/swaynag.
# Colors: #a73b50 (potato red) · #f79b29 (potato orange)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKGROUNDS_DIR="${SCRIPT_DIR}/backgrounds"
WALLPAPER_DEFAULT="UsefulBinds.png"
WALLPAPER_DST_DIR="${HOME}/.local/share/backgrounds"
WALLPAPER_DST="${WALLPAPER_DST_DIR}/${WALLPAPER_DEFAULT}"

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
# Official-repo packages (sway for swaybar/swaymsg/swaynag; swirl is separate)
# ----------------------------------------
PACMAN_PKGS=(
  # compositor tooling (bar / IPC / nag come from the sway package)
  sway
  swaybg
  swayidle
  swaylock
  lua
  # apps / tools used by config
  foot
  wmenu
  j4-dmenu-desktop
  jq
  grim
  slurp
  wf-recorder
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
  networkmanager-dmenu
  blueman
  bluez
  bluez-utils
  # desktop essentials often forgotten on Wayland
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
  gnome-themes-extra
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
  xfce-polkit
  wireless_tools
  libnotify
  fastfetch
  chafa
  # TUI login (replaces SDDM when enabled)
  ly
)

echo
echo -e "${RED}  SweetPotato${NC} ${ORANGE}installer${NC}"
echo "  Lightweight Swirl theme for Arch-based systems"
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
    info "sway already present ($(pacman -Q sway)) — keeping for swaybar/swaymsg/swaynag"
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
# Swirl compositor (not in official repos)
# ----------------------------------------
install_swirl() {
  if need_cmd swirl || [[ -x /usr/bin/swirl ]] || [[ -x /usr/local/bin/swirl ]]; then
    ok "swirl already installed ($(command -v swirl 2>/dev/null || echo /usr/local/bin/swirl))"
    return 0
  fi
  if pacman -Ss '^swirl$' 2>/dev/null | grep -q '^[^ ]*/swirl '; then
    info "Installing swirl from pacman..."
    ${SUDO} pacman -S --needed --noconfirm swirl
    ok "swirl package installed"
    return 0
  fi
  info "Building swirl from source into /usr/local..."
  local build_dir="${TMPDIR:-/tmp}/sweetpotato-swirl-build"
  ${SUDO} pacman -S --needed --noconfirm meson ninja gcc pkgconf wayland-protocols \
    wlroots json-c pango cairo gdk-pixbuf2 pcre2 libevdev lua scdoc 2>/dev/null || true
  rm -rf "${build_dir}"
  git clone --depth 1 https://github.com/visnudeva/swirl.git "${build_dir}/src"
  meson setup "${build_dir}/build" "${build_dir}/src" \
    --prefix=/usr/local \
    -D sd-bus-provider=libsystemd \
    -D werror=false \
    -D b_ndebug=true \
    -D scrollbar=false \
    -D scrollnag=false \
    -D swaymsg=false
  ninja -C "${build_dir}/build"
  ${SUDO} ninja -C "${build_dir}/build" install
  ${SUDO} mkdir -p /usr/local/share/wayland-sessions
  ${SUDO} install -Dm644 "${SCRIPT_DIR}/wayland-sessions/swirl.desktop" \
    /usr/local/share/wayland-sessions/swirl.desktop
  rm -rf "${build_dir}"
  ok "swirl installed to /usr/local"
}
install_swirl

# ----------------------------------------
# Deploy configs
# ----------------------------------------
info "Deploying SweetPotato configs..."

mkdir -p \
  "${HOME}/.config/sway/scripts" \
  "${HOME}/.config/swaylock" \
  "${HOME}/.config/foot" \
  "${HOME}/.config/fastfetch" \
  "${HOME}/.config/gtk-3.0" \
  "${HOME}/.config/gtk-4.0" \
  "${HOME}/.config/xsettingsd" \
  "${HOME}/.config/mako" \
  "${HOME}/.config/networkmanager-dmenu" \
  "${HOME}/.themes" \
  "${HOME}/.local/share/backgrounds" \
  "${HOME}/Pictures/Screenshots" \
  "${HOME}/Videos"

# Wallpapers (default UsefulBinds + extras for Mod+Shift+w)
mkdir -p "${WALLPAPER_DST_DIR}"
if [[ -d "${BACKGROUNDS_DIR}" ]]; then
  cp -f "${BACKGROUNDS_DIR}/"*.png "${WALLPAPER_DST_DIR}/"
  if [[ -d /usr/share/backgrounds/sway ]]; then
    ${SUDO} cp -f "${BACKGROUNDS_DIR}/"*.png /usr/share/backgrounds/sway/ || true
  fi
  ok "Wallpapers installed (default: ${WALLPAPER_DEFAULT})"
elif [[ -f "${SCRIPT_DIR}/SweetPotato.png" ]]; then
  cp -f "${SCRIPT_DIR}/SweetPotato.png" "${WALLPAPER_DST_DIR}/SweetPotato.png"
  WALLPAPER_DST="${WALLPAPER_DST_DIR}/SweetPotato.png"
  ok "Wallpaper installed (legacy SweetPotato.png)"
else
  warn "No wallpapers found in ${BACKGROUNDS_DIR}"
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
cp -f "${SCRIPT_DIR}/sway/scripts/wallpaper.sh" "${HOME}/.config/sway/scripts/wallpaper.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/record.sh" "${HOME}/.config/sway/scripts/record.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/screenshot.sh" "${HOME}/.config/sway/scripts/screenshot.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/ensure-wallpaper.sh" "${HOME}/.config/sway/scripts/ensure-wallpaper.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/caffeine.sh" "${HOME}/.config/sway/scripts/caffeine.sh"
cp -f "${SCRIPT_DIR}/sway/scripts/autotile.lua" "${HOME}/.config/sway/scripts/autotile.lua"
chmod +x \
  "${HOME}/.config/sway/scripts/status.sh" \
  "${HOME}/.config/sway/scripts/apply-theme.sh" \
  "${HOME}/.config/sway/scripts/volume.sh" \
  "${HOME}/.config/sway/scripts/brightness.sh" \
  "${HOME}/.config/sway/scripts/media.sh" \
  "${HOME}/.config/sway/scripts/applauncher.sh" \
  "${HOME}/.config/sway/scripts/wallpaper.sh" \
  "${HOME}/.config/sway/scripts/record.sh" \
  "${HOME}/.config/sway/scripts/screenshot.sh" \
  "${HOME}/.config/sway/scripts/ensure-wallpaper.sh" \
  "${HOME}/.config/sway/scripts/caffeine.sh"
# Persist wallpaper choice (include file must exist for sway)
if [[ ! -f "${HOME}/.config/sway/wallpaper.conf" ]]; then
  printf 'output * bg "%s" fill\n' "${WALLPAPER_DST}" \
    > "${HOME}/.config/sway/wallpaper.conf"
fi
ok "Swirl config (${KB_LAYOUT}) installed (~/.config/sway)"

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
cp -f "${SCRIPT_DIR}/bin/swirl" "${HOME}/.local/bin/swirl"
cp -f "${SCRIPT_DIR}/bin/sway" "${HOME}/.local/bin/sway"
chmod +x "${HOME}/.local/bin/swirl" "${HOME}/.local/bin/sway"
mkdir -p "${HOME}/.local/share/wayland-sessions"
cp -f "${SCRIPT_DIR}/wayland-sessions/swirl.desktop" \
  "${HOME}/.local/share/wayland-sessions/swirl.desktop"
if [[ -f /etc/environment ]] && grep -q '^LD_PRELOAD=/usr/lib/libgtk-nocsd.so' /etc/environment; then
  ${SUDO} sed -i \
    's|^LD_PRELOAD=/usr/lib/libgtk-nocsd.so|# LD_PRELOAD=/usr/lib/libgtk-nocsd.so  # disabled by SweetPotato (close buttons)|' \
    /etc/environment || true
  ok "Disabled system gtk-nocsd in /etc/environment (re-login for close buttons)"
else
  ok "gtk-nocsd already disabled or absent"
fi
ok "CSD swirl wrapper installed (~/.local/bin/swirl)"


# Foot
cp -f "${SCRIPT_DIR}/foot/foot.ini" "${HOME}/.config/foot/foot.ini"
ok "Foot themed"

# Fastfetch — ASCII SPLogo (chafa/PNG needs cell pixel size; falls back to Arch otherwise)
mkdir -p "${HOME}/.config/fastfetch"
cp -f "${SCRIPT_DIR}/fastfetch/config.jsonc" "${HOME}/.config/fastfetch/config.jsonc"
cp -f "${SCRIPT_DIR}/fastfetch/SPLogo.png" "${HOME}/.config/fastfetch/SPLogo.png"
cp -f "${SCRIPT_DIR}/fastfetch/SPLogo.asc" "${HOME}/.config/fastfetch/SPLogo.asc"
${SUDO} install -Dm644 "${SCRIPT_DIR}/fastfetch/SPLogo.png" \
  /usr/local/share/sweetpotatos/SPLogo.png
${SUDO} install -Dm644 "${SCRIPT_DIR}/fastfetch/SPLogo.asc" \
  /usr/local/share/sweetpotatos/SPLogo.asc
ok "Fastfetch logo (SPLogo) installed"

# Lid close → suspend (logind)
${SUDO} install -Dm644 "${SCRIPT_DIR}/systemd/logind.conf.d/lid-sleep.conf" \
  /etc/systemd/logind.conf.d/50-sweetpotato-lid-sleep.conf
${SUDO} systemctl restart systemd-logind 2>/dev/null || true
ok "Lid close suspend enabled (logind)"

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

# Polkit — allow wheel to manage disks (gnome-disks ISO restore on Swirl)
${SUDO} install -Dm644 "${SCRIPT_DIR}/polkit/49-sweetpotato-udisks.rules" \
  /etc/polkit-1/rules.d/49-sweetpotato-udisks.rules
${SUDO} systemctl restart polkit 2>/dev/null || true
# Polkit agent (gnome preferred, xfce fallback — Archcraft / Sway)
mkdir -p "${HOME}/.config/systemd/user"
cp -f "${SCRIPT_DIR}/systemd/user/polkit-gnome-authentication-agent-1.service" \
  "${HOME}/.config/systemd/user/polkit-gnome-authentication-agent-1.service"
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable --now polkit-gnome-authentication-agent-1.service 2>/dev/null || true
if ! id -nG "${USER}" 2>/dev/null | grep -qw wheel; then
  ${SUDO} usermod -aG wheel "${USER}" 2>/dev/null || true
  warn "Added ${USER} to wheel — re-login for disk permissions"
fi
ok "Polkit udisks rules installed (wheel can restore ISO to USB)"

# NetworkManager dmenu (Wi‑Fi menu — swaybar tray clicks are a no-op)
cp -f "${SCRIPT_DIR}/networkmanager-dmenu/config.ini" \
  "${HOME}/.config/networkmanager-dmenu/config.ini"
ok "networkmanager-dmenu themed (Mod+n)"

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
echo "  Reload swirl:  Mod+Shift+c"
echo "  Lock screen:   Mod+l"
echo "  App menu:      Mod+Space"
echo "  Login screen:  Ly (reboot after install) — select Swirl session"
echo "  Switch layout later:"
echo "    cp ~/.config/sway/config-fr ~/.config/sway/config   # French"
echo "    cp ~/.config/sway/config-us ~/.config/sway/config   # US"
echo "  Then Mod+Shift+c to reload."
echo
echo "  Re-login once so close buttons (CSD) and PATH fixes apply fully."
echo
